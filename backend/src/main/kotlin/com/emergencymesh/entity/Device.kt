package com.emergencymesh.entity

import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Id
import java.time.Instant

/** ER: Device. Every phone the backend has heard of, as a sender or a gateway. */
@Entity
class Device(
	@Id
	var deviceId: String,

	@Enumerated(EnumType.STRING)
	var deviceType: DeviceType,

	var publicKey: String? = null,

	var lastSeenAt: Instant,
)
