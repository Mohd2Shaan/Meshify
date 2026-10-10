package com.emergencymesh.controller

import com.emergencymesh.dto.AlertDto
import com.emergencymesh.dto.AssignTeamRequest
import com.emergencymesh.dto.CreateAlertRequest
import com.emergencymesh.dto.IncidentDto
import com.emergencymesh.dto.NoticeFeed
import com.emergencymesh.dto.SignedNoticeDto
import com.emergencymesh.dto.TeamDto
import com.emergencymesh.dto.UpdateStatusRequest
import com.emergencymesh.dto.UploadRequest
import com.emergencymesh.dto.UploadResponse
import com.emergencymesh.entity.BackendAckStatus
import com.emergencymesh.entity.IncidentStatus
import com.emergencymesh.repository.ResponderTeamRepository
import com.emergencymesh.service.IncidentService
import com.emergencymesh.service.MessageIngestionService
import com.emergencymesh.service.NoticeService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.Clock
import java.time.Duration
import java.time.Instant
import java.util.Base64

/** Gateway uploads (FR-9, FR-10). Requires the X-API-Key header. */
@RestController
@RequestMapping("/api/messages")
class MessageController(private val ingestion: MessageIngestionService) {

	@PostMapping
	fun upload(@Valid @RequestBody req: UploadRequest): ResponseEntity<UploadResponse> {
		val res = ingestion.ingest(req)
		val status = when (res.ackStatus) {
			BackendAckStatus.ACKNOWLEDGED -> HttpStatus.CREATED
			BackendAckStatus.DUPLICATE -> HttpStatus.OK
			BackendAckStatus.REJECTED -> HttpStatus.UNPROCESSABLE_CONTENT
		}
		return ResponseEntity.status(status).body(res)
	}
}

/** Responder dashboard (FR-11, FR-12, FR-13). Requires responder login. */
@RestController
@RequestMapping("/api/incidents")
class IncidentController(private val incidents: IncidentService) {

	@GetMapping
	fun list(@RequestParam(required = false) status: Set<IncidentStatus>?): List<IncidentDto> =
		incidents.list(status)

	@PatchMapping("/{id}/assign")
	fun assign(@PathVariable id: String, @RequestBody req: AssignTeamRequest): IncidentDto =
		incidents.assignTeam(id, req.teamId)

	@PatchMapping("/{id}/status")
	fun status(@PathVariable id: String, @Valid @RequestBody req: UpdateStatusRequest): IncidentDto =
		incidents.updateStatus(id, req.status!!)
}

@RestController
@RequestMapping("/api/teams")
class TeamController(private val teams: ResponderTeamRepository) {

	@GetMapping
	fun list(): List<TeamDto> = teams.findAll().sortedBy { it.teamName }.map(TeamDto::from)
}

/** Gateways fetch receipts and alerts here and flood them into the mesh. Requires the X-API-Key header. */
@RestController
@RequestMapping("/api/notices")
class NoticeController(private val notices: NoticeService, private val clock: Clock) {

	@GetMapping
	fun feed(@RequestParam(defaultValue = "0") since: Long): NoticeFeed {
		val serverTime = clock.instant() // taken first, so nothing created during the query is skipped next time
		val b64 = Base64.getEncoder()
		return NoticeFeed(
			serverTime.toEpochMilli(),
			notices.forGateway(Instant.ofEpochMilli(since)).map {
				SignedNoticeDto(it.noticeId, b64.encodeToString(it.body), b64.encodeToString(it.signature))
			},
		)
	}
}

/** Broadcast alerts from the responder dashboard. Requires responder login. */
@RestController
@RequestMapping("/api/alerts")
class AlertController(private val notices: NoticeService) {

	@PostMapping
	fun create(@Valid @RequestBody req: CreateAlertRequest): ResponseEntity<AlertDto> {
		val n = notices.issueAlert(
			req.level!!, req.title!!.trim(), req.message!!.trim(), Duration.ofMinutes(req.validForMinutes.toLong()),
		)
		return ResponseEntity.status(HttpStatus.CREATED).body(AlertDto.from(n))
	}

	@GetMapping
	fun list(): List<AlertDto> = notices.recentAlerts().map(AlertDto::from)
}
