package com.emergencymesh.service

import com.emergencymesh.crypto.PayloadDecryptor
import com.emergencymesh.dto.UploadRequest
import com.emergencymesh.dto.UploadResponse
import com.emergencymesh.entity.BackendAckStatus
import com.emergencymesh.entity.Device
import com.emergencymesh.entity.DeviceType
import com.emergencymesh.entity.GatewayUpload
import com.emergencymesh.entity.IncidentRecord
import com.emergencymesh.entity.Message
import com.emergencymesh.proto.EmergencyPayload
import com.emergencymesh.repository.DeviceRepository
import com.emergencymesh.repository.GatewayUploadRepository
import com.emergencymesh.repository.IncidentRecordRepository
import com.emergencymesh.repository.MessageRepository
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.server.ResponseStatusException
import java.time.Clock
import java.time.Instant
import java.util.Base64
import java.util.UUID

/**
 * FR-9 (receive a gateway upload) and FR-10 (turn it into an IncidentRecord).
 *
 * Idempotent per messageId: the same message can arrive through several
 * gateways, or be retried by one, and still yields exactly one incident.
 */
@Service
class MessageIngestionService(
	private val devices: DeviceRepository,
	private val messages: MessageRepository,
	private val uploads: GatewayUploadRepository,
	private val incidents: IncidentRecordRepository,
	private val decryptor: PayloadDecryptor,
	private val notices: NoticeService,
	private val clock: Clock,
) {
	@Transactional
	fun ingest(req: UploadRequest): UploadResponse {
		val now = clock.instant()
		val gateway = touchDevice(req.gatewayDeviceId, DeviceType.GATEWAY, now)

		// SRS 4.5: an expired message could send responders to stale information.
		if (Instant.ofEpochMilli(req.ttlExpiryMs).isBefore(now)) {
			val upload = recordUpload(req.messageId, gateway, now, BackendAckStatus.REJECTED)
			return UploadResponse(upload.uploadId, req.messageId, BackendAckStatus.REJECTED, null, "expired")
		}

		incidents.findByMessageMessageId(req.messageId)?.let { existing ->
			val upload = recordUpload(req.messageId, gateway, now, BackendAckStatus.DUPLICATE)
			return UploadResponse(upload.uploadId, req.messageId, BackendAckStatus.DUPLICATE, existing.incidentId)
		}

		val payload = openPayload(req.sealedPayload)
		val sender = touchDevice(req.senderDeviceId, DeviceType.USER_NODE, now)
		val message = messages.save(
			Message(
				messageId = req.messageId,
				senderDevice = sender,
				type = req.type!!,
				latitude = payload.latitude,
				longitude = payload.longitude,
				note = payload.note.takeIf { it.isNotBlank() },
				timestamp = Instant.ofEpochMilli(req.timestampMs),
				ttlExpiry = Instant.ofEpochMilli(req.ttlExpiryMs),
				hopCount = req.hopCount,
				priorityScore = req.priorityScore,
			),
		)
		val incident = incidents.save(
			IncidentRecord(
				incidentId = UUID.randomUUID().toString(),
				message = message,
				latitude = message.latitude,
				longitude = message.longitude,
				severity = message.type.severity,
				createdAt = now,
				updatedAt = now,
			),
		)
		notices.issueReceipt(incident) // tells the sender, through the mesh, that it arrived
		val upload = recordUpload(req.messageId, gateway, now, BackendAckStatus.ACKNOWLEDGED)
		return UploadResponse(upload.uploadId, req.messageId, BackendAckStatus.ACKNOWLEDGED, incident.incidentId)
	}

	private fun openPayload(base64: String): EmergencyPayload {
		val payload = try {
			EmergencyPayload.parseFrom(decryptor.open(Base64.getDecoder().decode(base64)))
		} catch (e: Exception) {
			throw ResponseStatusException(HttpStatus.BAD_REQUEST, "sealedPayload could not be opened", e)
		}
		if (payload.latitude !in -90.0..90.0 || payload.longitude !in -180.0..180.0) {
			throw ResponseStatusException(HttpStatus.BAD_REQUEST, "coordinates out of range")
		}
		return payload
	}

	private fun touchDevice(id: String, typeIfNew: DeviceType, now: Instant): Device {
		val device = devices.findById(id).orElseGet { Device(id, typeIfNew, lastSeenAt = now) }
		device.lastSeenAt = now
		if (typeIfNew == DeviceType.GATEWAY) device.deviceType = DeviceType.GATEWAY
		return devices.save(device)
	}

	private fun recordUpload(messageId: String, gateway: Device, now: Instant, status: BackendAckStatus) =
		uploads.save(GatewayUpload(UUID.randomUUID().toString(), messageId, gateway, now, status))
}
