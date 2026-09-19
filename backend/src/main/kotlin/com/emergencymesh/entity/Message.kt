package com.emergencymesh.entity

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import java.time.Instant

/** ER: Message. The emergency record as received (and decrypted) at Headquarters. */
@Entity
class Message(
	@Id
	var messageId: String,

	@ManyToOne(optional = false)
	@JoinColumn(name = "sender_device_id")
	var senderDevice: Device,

	@Enumerated(EnumType.STRING)
	var type: MessageType,

	var latitude: Double,
	var longitude: Double,

	/** Optional short note (SRS 3.3). Not in the ER diagram yet; see README. */
	@Column(length = 280)
	var note: String? = null,

	var timestamp: Instant,
	var ttlExpiry: Instant,
	var hopCount: Int,
	var priorityScore: Double,

	var status: String = "RECEIVED",
)
