package com.emergencymesh.entity

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Id
import jakarta.persistence.Index
import jakarta.persistence.Table
import java.time.Instant

/**
 * A signed notice from HQ to the mesh: a delivery receipt for one message, or
 * a broadcast alert. Gateways fetch these and flood them to every phone.
 *
 * [body] and [signature] are stored exactly as signed, so every gateway relays
 * byte-identical copies. The other columns are a readable copy for the dashboard.
 */
@Entity
@Table(indexes = [Index(columnList = "createdAt"), Index(columnList = "messageId")])
class HqNoticeRecord(
	@Id
	var noticeId: String,

	@Enumerated(EnumType.STRING)
	var kind: NoticeKind,

	/** Receipts only: the message this is about. */
	var messageId: String? = null,

	@Enumerated(EnumType.STRING)
	var receiptStatus: ReceiptStatus? = null,
	var teamName: String? = null,

	@Enumerated(EnumType.STRING)
	var alertLevel: AlertLevel? = null,
	@Column(length = 80)
	var alertTitle: String? = null,
	@Column(length = 300)
	var alertBody: String? = null,

	var createdAt: Instant,
	var expiresAt: Instant,

	/** When a gateway first fetched it, i.e. when it entered the mesh. */
	var firstPickedUpAt: Instant? = null,

	@Column(length = 1024)
	var body: ByteArray,
	@Column(length = 64)
	var signature: ByteArray,
)
