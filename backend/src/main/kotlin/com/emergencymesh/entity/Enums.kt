package com.emergencymesh.entity

/** FR-1 need types; mirrors MessageType in proto/emergency_message.proto. */
enum class MessageType(val severity: Severity) {
	MEDICAL(Severity.HIGH),
	TRAPPED(Severity.HIGH),
	SUPPLIES(Severity.MEDIUM),
	STATUS(Severity.LOW),
}

/** FR-10 / FR-11: drives the dashboard pin colour. */
enum class Severity { HIGH, MEDIUM, LOW }

/** FR-13 lifecycle of an incident. */
enum class IncidentStatus { PENDING, ACKNOWLEDGED, RESOLVED }

enum class DeviceType { USER_NODE, RELAY, GATEWAY }

enum class BackendAckStatus { ACKNOWLEDGED, DUPLICATE, REJECTED }

enum class NoticeKind { RECEIPT, ALERT }

/** What a delivery receipt tells the sender. Mirrors ReceiptStatus in the .proto. */
enum class ReceiptStatus { DELIVERED, ACKNOWLEDGED, RESOLVED }

/** Broadcast alert level. Mirrors AlertLevel in the .proto. */
enum class AlertLevel { INFO, WARNING, CRITICAL }
