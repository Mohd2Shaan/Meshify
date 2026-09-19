package com.emergencymesh.entity

import jakarta.persistence.Entity
import jakarta.persistence.Id

/** ER: ResponderTeam (FR-12). */
@Entity
class ResponderTeam(
	@Id
	var teamId: String,

	var teamName: String,
	var region: String,
	var contactInfo: String,
)
