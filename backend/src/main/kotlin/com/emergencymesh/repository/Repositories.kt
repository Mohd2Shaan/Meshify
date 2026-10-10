package com.emergencymesh.repository

import com.emergencymesh.entity.Device
import com.emergencymesh.entity.GatewayUpload
import com.emergencymesh.entity.HqNoticeRecord
import com.emergencymesh.entity.IncidentRecord
import com.emergencymesh.entity.IncidentStatus
import com.emergencymesh.entity.Message
import com.emergencymesh.entity.NoticeKind
import com.emergencymesh.entity.ResponderTeam
import org.springframework.data.jpa.repository.JpaRepository
import java.time.Instant

interface DeviceRepository : JpaRepository<Device, String>

interface MessageRepository : JpaRepository<Message, String>

interface GatewayUploadRepository : JpaRepository<GatewayUpload, String> {
	fun findByMessageId(messageId: String): List<GatewayUpload>
}

interface IncidentRecordRepository : JpaRepository<IncidentRecord, String> {
	fun findByMessageMessageId(messageId: String): IncidentRecord?
	fun findAllByOrderByCreatedAtDesc(): List<IncidentRecord>
	fun findByStatusInOrderByCreatedAtDesc(statuses: Collection<IncidentStatus>): List<IncidentRecord>
}

interface ResponderTeamRepository : JpaRepository<ResponderTeam, String>

interface HqNoticeRepository : JpaRepository<HqNoticeRecord, String> {
	fun findByCreatedAtAfterAndExpiresAtAfterOrderByCreatedAt(since: Instant, now: Instant): List<HqNoticeRecord>
	fun findTop50ByKindOrderByCreatedAtDesc(kind: NoticeKind): List<HqNoticeRecord>
	fun findFirstByMessageIdOrderByCreatedAtDesc(messageId: String): HqNoticeRecord?
}
