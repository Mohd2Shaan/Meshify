package com.emergencymesh.service

import com.emergencymesh.dto.IncidentDto
import com.emergencymesh.entity.IncidentRecord
import com.emergencymesh.entity.IncidentStatus
import com.emergencymesh.repository.IncidentRecordRepository
import com.emergencymesh.repository.ResponderTeamRepository
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.server.ResponseStatusException
import java.time.Clock

/** Responder-side operations: FR-11 (list), FR-12 (assign), FR-13 (status). */
@Service
class IncidentService(
	private val incidents: IncidentRecordRepository,
	private val teams: ResponderTeamRepository,
	private val notices: NoticeService,
	private val clock: Clock,
) {
	@Transactional(readOnly = true)
	fun list(statuses: Set<IncidentStatus>?): List<IncidentDto> {
		val rows = if (statuses.isNullOrEmpty()) {
			incidents.findAllByOrderByCreatedAtDesc()
		} else {
			incidents.findByStatusInOrderByCreatedAtDesc(statuses)
		}
		return rows.map { IncidentDto.from(it, notices.latestReceipt(it.message.messageId)) }
	}

	@Transactional
	fun assignTeam(incidentId: String, teamId: String?): IncidentDto {
		val incident = find(incidentId)
		incident.assignedTeam = teamId?.let {
			teams.findById(it).orElseThrow {
				ResponseStatusException(HttpStatus.NOT_FOUND, "team $it not found")
			}
		}
		incident.updatedAt = clock.instant()
		return changed(incident)
	}

	@Transactional
	fun updateStatus(incidentId: String, status: IncidentStatus): IncidentDto {
		val incident = find(incidentId)
		incident.status = status
		incident.updatedAt = clock.instant()
		return changed(incident)
	}

	/** Sends the sender a fresh receipt (status, team) and returns the updated DTO. */
	private fun changed(incident: IncidentRecord): IncidentDto {
		val receipt = notices.issueReceipt(incident)
		return IncidentDto.from(incident, receipt)
	}

	private fun find(id: String): IncidentRecord =
		incidents.findById(id).orElseThrow {
			ResponseStatusException(HttpStatus.NOT_FOUND, "incident $id not found")
		}
}
