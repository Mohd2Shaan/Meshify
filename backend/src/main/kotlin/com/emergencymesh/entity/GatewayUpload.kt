package com.emergencymesh.entity

import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import java.time.Instant

/**
 * ER: GatewayUpload (weak entity). One row per upload attempt, so if two
 * gateways upload the same message, both crossings are recorded.
 *
 * Holds messageId as a plain column rather than a foreign key, because
 * rejected uploads (e.g. expired messages) never create a Message row.
 */
@Entity
class GatewayUpload(
	@Id
	var uploadId: String,

	var messageId: String,

	@ManyToOne(optional = false)
	@JoinColumn(name = "gateway_device_id")
	var gatewayDevice: Device,

	var uploadTimestamp: Instant,

	@Enumerated(EnumType.STRING)
	var backendAckStatus: BackendAckStatus,
)
