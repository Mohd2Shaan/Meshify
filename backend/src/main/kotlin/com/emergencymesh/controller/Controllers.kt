package com.emergencymesh.controller

import com.emergencymesh.dto.AssignTeamRequest
import com.emergencymesh.dto.IncidentDto
import com.emergencymesh.dto.TeamDto
import com.emergencymesh.dto.UpdateStatusRequest
import com.emergencymesh.dto.UploadRequest
import com.emergencymesh.dto.UploadResponse
import com.emergencymesh.entity.BackendAckStatus
import com.emergencymesh.entity.IncidentStatus
import com.emergencymesh.repository.ResponderTeamRepository
import com.emergencymesh.service.IncidentService
import com.emergencymesh.service.MessageIngestionService
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
