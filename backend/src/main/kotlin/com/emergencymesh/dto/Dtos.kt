package com.emergencymesh.dto

import com.emergencymesh.entity.AlertLevel
import com.emergencymesh.entity.BackendAckStatus
import com.emergencymesh.entity.HqNoticeRecord
import com.emergencymesh.entity.IncidentRecord
import com.emergencymesh.entity.IncidentStatus
import com.emergencymesh.entity.MessageType
import com.emergencymesh.entity.ReceiptStatus
import com.emergencymesh.entity.ResponderTeam
import com.emergencymesh.entity.Severity
import jakarta.validation.constraints.Max
import jakarta.validation.constraints.Min
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Size
import java.time.Instant

/**
 * POST /api/messages body, sent by a gateway phone (FR-9).
 *
 * Mirrors MeshPacket's routing header. The private content (GPS, note) is
 * only inside [sealedPayload]: a base64 EmergencyPayload, encrypted from Phase 5.
 */
data class UploadRequest(
	@field:NotBlank val messageId: String,
	@field:NotBlank val senderDeviceId: String,
	@field:NotBlank val gatewayDeviceId: String,
	@field:NotNull val type: MessageType?,
	@field:Min(1) val timestampMs: Long,
	@field:Min(1) val ttlExpiryMs: Long,
	@field:Min(0) val hopCount: Int,
	val priorityScore: Double = 0.0,
	@field:NotBlank val sealedPayload: String,
)

data class UploadResponse(
	val uploadId: String,
	val messageId: String,
	val ackStatus: BackendAckStatus,
	val incidentId: String?,
	val reason: String? = null,
)

data class TeamDto(
	val teamId: String,
	val teamName: String,
	val region: String,
	val contactInfo: String,
) {
	companion object {
		fun from(t: ResponderTeam) = TeamDto(t.teamId, t.teamName, t.region, t.contactInfo)
	}
}

data class IncidentDto(
	val incidentId: String,
	val messageId: String,
	val type: MessageType,
	val severity: Severity,
	val status: IncidentStatus,
	val latitude: Double,
	val longitude: Double,
	val note: String?,
	val hopCount: Int,
	val reportedAt: Instant,
	val createdAt: Instant,
	val updatedAt: Instant,
	val assignedTeam: TeamDto?,
	/** The latest receipt sent back to the sender's phone, if any. */
	val receipt: ReceiptDto?,
) {
	companion object {
		fun from(i: IncidentRecord, receipt: HqNoticeRecord? = null) = IncidentDto(
			incidentId = i.incidentId,
			messageId = i.message.messageId,
			type = i.message.type,
			severity = i.severity,
			status = i.status,
			latitude = i.latitude,
			longitude = i.longitude,
			note = i.message.note,
			hopCount = i.message.hopCount,
			reportedAt = i.message.timestamp,
			createdAt = i.createdAt,
			updatedAt = i.updatedAt,
			assignedTeam = i.assignedTeam?.let(TeamDto::from),
			receipt = receipt?.let(ReceiptDto::from),
		)
	}
}

/** PATCH /api/incidents/{id}/assign. A null teamId unassigns (FR-12). */
data class AssignTeamRequest(val teamId: String?)

/** PATCH /api/incidents/{id}/status (FR-13). */
data class UpdateStatusRequest(@field:NotNull val status: IncidentStatus?)

/** What the sender's phone has been (or will be) told about their incident. */
data class ReceiptDto(
	val status: ReceiptStatus,
	val teamName: String?,
	val issuedAt: Instant,
	/** Null until a gateway has fetched it into the mesh. */
	val pickedUpAt: Instant?,
) {
	companion object {
		fun from(n: HqNoticeRecord) = ReceiptDto(n.receiptStatus!!, n.teamName, n.createdAt, n.firstPickedUpAt)
	}
}

/** POST /api/alerts: a broadcast from responders to every phone in the mesh. */
data class CreateAlertRequest(
	@field:NotNull val level: AlertLevel?,
	@field:NotBlank @field:Size(max = 60) val title: String?,
	// Kept short so the signed notice fits comfortably in one Bluetooth payload.
	@field:NotBlank @field:Size(max = 280) val message: String?,
	@field:Min(5) @field:Max(2880) val validForMinutes: Int = 360,
)

data class AlertDto(
	val alertId: String,
	val level: AlertLevel,
	val title: String,
	val message: String,
	val createdAt: Instant,
	val expiresAt: Instant,
	/** When a gateway first took it into the mesh; null while waiting for one. */
	val pickedUpAt: Instant?,
) {
	companion object {
		fun from(n: HqNoticeRecord) =
			AlertDto(n.noticeId, n.alertLevel!!, n.alertTitle!!, n.alertBody!!, n.createdAt, n.expiresAt, n.firstPickedUpAt)
	}
}

/** GET /api/notices: what a gateway should flood into the mesh. */
data class NoticeFeed(
	/** Pass back as `since` on the next poll. */
	val serverTimeMs: Long,
	val notices: List<SignedNoticeDto>,
)

/** Base64 of the exact signed bytes; the gateway relays them unchanged. */
data class SignedNoticeDto(val noticeId: String, val body: String, val signature: String)
