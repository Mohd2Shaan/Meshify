package com.emergencymesh.service

import com.emergencymesh.crypto.NoticeSigner
import com.emergencymesh.entity.AlertLevel
import com.emergencymesh.entity.HqNoticeRecord
import com.emergencymesh.entity.IncidentRecord
import com.emergencymesh.entity.IncidentStatus
import com.emergencymesh.entity.NoticeKind
import com.emergencymesh.entity.ReceiptStatus
import com.emergencymesh.proto.DeliveryReceipt
import com.emergencymesh.proto.HqAlert
import com.emergencymesh.proto.HqNotice
import com.emergencymesh.repository.HqNoticeRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.time.Duration
import java.time.Instant
import java.util.UUID
import com.emergencymesh.proto.AlertLevel as ProtoAlertLevel
import com.emergencymesh.proto.ReceiptStatus as ProtoReceiptStatus

/**
 * HQ -> mesh notices. Every receipt and alert is signed once, stored, and
 * handed to gateways, which flood it to the phones.
 */
@Service
class NoticeService(
	private val notices: HqNoticeRepository,
	private val signer: NoticeSigner,
	private val clock: Clock,
) {
	/**
	 * Tells the sender where their incident stands. Called when it is created,
	 * and whenever a responder changes its status or team.
	 */
	@Transactional
	fun issueReceipt(incident: IncidentRecord): HqNoticeRecord {
		val status = when (incident.status) {
			IncidentStatus.PENDING -> ReceiptStatus.DELIVERED
			IncidentStatus.ACKNOWLEDGED -> ReceiptStatus.ACKNOWLEDGED
			IncidentStatus.RESOLVED -> ReceiptStatus.RESOLVED
		}
		val team = incident.assignedTeam?.teamName
		val receipt = DeliveryReceipt.newBuilder()
			.setMessageId(incident.message.messageId)
			.setStatus(ProtoReceiptStatus.valueOf(status.name))
			.setTeamName(team ?: "")
		return save(NoticeKind.RECEIPT, RECEIPT_TTL, { it.setReceipt(receipt) }) {
			it.messageId = incident.message.messageId
			it.receiptStatus = status
			it.teamName = team
		}
	}

	@Transactional
	fun issueAlert(level: AlertLevel, title: String, body: String, validFor: Duration): HqNoticeRecord {
		val alert = HqAlert.newBuilder()
			.setLevel(ProtoAlertLevel.valueOf(level.name))
			.setTitle(title)
			.setBody(body)
		return save(NoticeKind.ALERT, validFor, { it.setAlert(alert) }) {
			it.alertLevel = level
			it.alertTitle = title
			it.alertBody = body
		}
	}

	/**
	 * What a gateway should pass into the mesh: unexpired notices created after
	 * [since], minus receipts that a newer receipt for the same message replaces.
	 * Marks each as picked up, so the dashboard can show it reached the mesh.
	 */
	@Transactional
	fun forGateway(since: Instant): List<HqNoticeRecord> {
		val now = clock.instant()
		// Overlap so a notice committed while the previous poll ran isn't missed;
		// phones drop the repeats as duplicates.
		val rows = notices.findByCreatedAtAfterAndExpiresAtAfterOrderByCreatedAt(since.minus(POLL_OVERLAP), now)
		val latestReceipt = rows.filter { it.kind == NoticeKind.RECEIPT }
			.groupBy { it.messageId }
			.mapValues { (_, r) -> r.maxBy { it.createdAt }.noticeId }
		val result = rows.filter { it.kind != NoticeKind.RECEIPT || latestReceipt[it.messageId] == it.noticeId }
		result.filter { it.firstPickedUpAt == null }.forEach { it.firstPickedUpAt = now }
		return result
	}

	@Transactional(readOnly = true)
	fun recentAlerts(): List<HqNoticeRecord> = notices.findTop50ByKindOrderByCreatedAtDesc(NoticeKind.ALERT)

	@Transactional(readOnly = true)
	fun latestReceipt(messageId: String): HqNoticeRecord? = notices.findFirstByMessageIdOrderByCreatedAtDesc(messageId)

	private fun save(
		kind: NoticeKind,
		ttl: Duration,
		content: (HqNotice.Builder) -> Unit,
		describe: (HqNoticeRecord) -> Unit,
	): HqNoticeRecord {
		val now = clock.instant()
		val id = UUID.randomUUID().toString()
		val expiry = now.plus(ttl)
		val body = HqNotice.newBuilder()
			.setNoticeId(id)
			.setIssuedAtMs(now.toEpochMilli())
			.setExpiryMs(expiry.toEpochMilli())
			.also(content)
			.build()
			.toByteArray()
		val record = HqNoticeRecord(
			noticeId = id,
			kind = kind,
			createdAt = now,
			expiresAt = expiry,
			body = body,
			signature = signer.sign(body),
		)
		describe(record)
		return notices.save(record)
	}

	companion object {
		/** How long a receipt circulates looking for its sender. Same as a message's default TTL. */
		val RECEIPT_TTL: Duration = Duration.ofHours(6)
		val POLL_OVERLAP: Duration = Duration.ofSeconds(60)
	}
}
