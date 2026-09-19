package com.emergencymesh.entity

import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.OneToOne
import java.time.Instant

/** ER: IncidentRecord. What responders work from (FR-10 to FR-13). */
@Entity
class IncidentRecord(
	@Id
	var incidentId: String,

	@OneToOne(optional = false)
	@JoinColumn(name = "message_id", unique = true)
	var message: Message,

	@Enumerated(EnumType.STRING)
	var status: IncidentStatus = IncidentStatus.PENDING,

	/** mapLocation in the ER diagram, stored as two columns. */
	var latitude: Double,
	var longitude: Double,

	@Enumerated(EnumType.STRING)
	var severity: Severity,

	@ManyToOne
	@JoinColumn(name = "assigned_team_id")
	var assignedTeam: ResponderTeam? = null,

	var createdAt: Instant,
	var updatedAt: Instant,
)
