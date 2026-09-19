package com.emergencymesh

import com.emergencymesh.crypto.Sodium
import com.emergencymesh.proto.EmergencyPayload
import com.emergencymesh.repository.GatewayUploadRepository
import org.hamcrest.Matchers.hasItem
import org.hamcrest.Matchers.not
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.httpBasic
import org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.setup.DefaultMockMvcBuilder
import org.springframework.test.web.servlet.setup.MockMvcBuilders
import org.springframework.web.context.WebApplicationContext
import java.util.Base64
import java.util.UUID
import kotlin.test.assertEquals

@SpringBootTest(properties = ["mesh.crypto.private-key=${ApiIntegrationTests.TEST_PRIVATE_KEY}"])
@ActiveProfiles("dev")
class ApiIntegrationTests {

	companion object {
		/** Test-only key (bytes 1..32). Never used outside tests. */
		const val TEST_PRIVATE_KEY = "AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyA="
		val testPublicKey: ByteArray = Sodium.publicKeyOf(Base64.getDecoder().decode(TEST_PRIVATE_KEY))
	}

	@Autowired lateinit var context: WebApplicationContext
	@Autowired lateinit var uploads: GatewayUploadRepository
	lateinit var mvc: MockMvc

	@BeforeEach
	fun setUp() {
		mvc = MockMvcBuilders.webAppContextSetup(context)
			.apply<DefaultMockMvcBuilder>(springSecurity())
			.build()
	}

	// ---- helpers ---------------------------------------------------------------

	private fun plainPayload(lat: Double = 13.0827, lon: Double = 80.2707, note: String = "") =
		EmergencyPayload.newBuilder().setLatitude(lat).setLongitude(lon).setNote(note).build().toByteArray()

	/** What a phone sends: the EmergencyPayload sealed for the backend's key (FR-3). */
	private fun payload(lat: Double = 13.0827, lon: Double = 80.2707, note: String = "") =
		Base64.getEncoder().encodeToString(Sodium.seal(plainPayload(lat, lon, note), testPublicKey))

	private fun uploadJson(
		messageId: String = UUID.randomUUID().toString(),
		type: String = "MEDICAL",
		ttlExpiryMs: Long = System.currentTimeMillis() + 3_600_000,
		sealedPayload: String = payload(note = "leg injury"),
	) = """
		{
		  "messageId": "$messageId",
		  "senderDeviceId": "phone-a",
		  "gatewayDeviceId": "phone-c",
		  "type": "$type",
		  "timestampMs": ${System.currentTimeMillis()},
		  "ttlExpiryMs": $ttlExpiryMs,
		  "hopCount": 2,
		  "priorityScore": 97.5,
		  "sealedPayload": "$sealedPayload"
		}
	""".trimIndent()

	private fun upload(body: String, key: String? = "dev-gateway-key"): MockHttpServletRequestBuilder {
		val req = post("/api/messages").contentType(MediaType.APPLICATION_JSON).content(body)
		return if (key == null) req else req.header("X-API-Key", key)
	}

	private val responder = httpBasic("responder", "responder123")

	private fun createIncident(): String {
		val result = mvc.perform(upload(uploadJson())).andExpect(status().isCreated).andReturn()
		return Regex("\"incidentId\":\"([^\"]+)\"").find(result.response.contentAsString)!!.groupValues[1]
	}

	// ---- FR-9 / FR-10: gateway upload -----------------------------------------

	@Test
	fun `upload creates an incident with decrypted location and severity`() {
		val id = UUID.randomUUID().toString()
		mvc.perform(upload(uploadJson(messageId = id)))
			.andExpect(status().isCreated)
			.andExpect(jsonPath("$.ackStatus").value("ACKNOWLEDGED"))
			.andExpect(jsonPath("$.incidentId").isNotEmpty)

		mvc.perform(get("/api/incidents").with(responder))
			.andExpect(status().isOk)
			.andExpect(jsonPath("$[?(@.messageId == '$id')].latitude").value(13.0827))
			.andExpect(jsonPath("$[?(@.messageId == '$id')].note").value("leg injury"))
			.andExpect(jsonPath("$[?(@.messageId == '$id')].severity").value("HIGH"))
			.andExpect(jsonPath("$[?(@.messageId == '$id')].status").value("PENDING"))
	}

	@Test
	fun `same message via two uploads yields one incident and two upload records`() {
		val id = UUID.randomUUID().toString()
		val first = mvc.perform(upload(uploadJson(messageId = id))).andExpect(status().isCreated).andReturn()
		val incidentId = Regex("\"incidentId\":\"([^\"]+)\"").find(first.response.contentAsString)!!.groupValues[1]

		mvc.perform(upload(uploadJson(messageId = id)))
			.andExpect(status().isOk)
			.andExpect(jsonPath("$.ackStatus").value("DUPLICATE"))
			.andExpect(jsonPath("$.incidentId").value(incidentId))

		assertEquals(2, uploads.findByMessageId(id).size)
	}

	@Test
	fun `expired message is rejected`() {
		mvc.perform(upload(uploadJson(ttlExpiryMs = System.currentTimeMillis() - 1000)))
			.andExpect(status().isUnprocessableContent)
			.andExpect(jsonPath("$.ackStatus").value("REJECTED"))
			.andExpect(jsonPath("$.reason").value("expired"))
	}

	@Test
	fun `unreadable payload is a bad request`() {
		mvc.perform(upload(uploadJson(sealedPayload = "bm90LWEtcHJvdG9idWY="))) // "not-a-protobuf"
			.andExpect(status().isBadRequest)
	}

	@Test
	fun `unsealed plaintext payload is rejected`() {
		val plain = Base64.getEncoder().encodeToString(plainPayload(note = "not encrypted"))
		mvc.perform(upload(uploadJson(sealedPayload = plain))).andExpect(status().isBadRequest)
	}

	@Test
	fun `tampered sealed payload is rejected`() {
		val sealed = Sodium.seal(plainPayload(), testPublicKey)
		sealed[sealed.size - 1] = (sealed[sealed.size - 1].toInt() xor 1).toByte()
		mvc.perform(upload(uploadJson(sealedPayload = Base64.getEncoder().encodeToString(sealed))))
			.andExpect(status().isBadRequest)
	}

	@Test
	fun `payload sealed for a different key is rejected`() {
		val (otherPk, _) = Sodium.newKeyPair()
		val sealed = Base64.getEncoder().encodeToString(Sodium.seal(plainPayload(), otherPk))
		mvc.perform(upload(uploadJson(sealedPayload = sealed))).andExpect(status().isBadRequest)
	}

	@Test
	fun `out-of-range coordinates are a bad request`() {
		mvc.perform(upload(uploadJson(sealedPayload = payload(lat = 123.0))))
			.andExpect(status().isBadRequest)
	}

	@Test
	fun `missing fields are a bad request`() {
		mvc.perform(upload("""{"messageId": "x"}""")).andExpect(status().isBadRequest)
	}

	// ---- Security ---------------------------------------------------------------

	@Test
	fun `upload without or with a wrong API key is unauthorized`() {
		mvc.perform(upload(uploadJson(), key = null)).andExpect(status().isUnauthorized)
		mvc.perform(upload(uploadJson(), key = "wrong")).andExpect(status().isUnauthorized)
	}

	@Test
	fun `health is public, for gateway detection`() {
		mvc.perform(get("/api/health"))
			.andExpect(status().isOk)
			.andExpect(jsonPath("$.status").value("ok"))
	}

	@Test
	fun `incidents need a responder login, not a gateway key`() {
		mvc.perform(get("/api/incidents")).andExpect(status().isUnauthorized)
		mvc.perform(get("/api/incidents").header("X-API-Key", "dev-gateway-key")).andExpect(status().isForbidden)
		mvc.perform(get("/api/incidents").with(httpBasic("responder", "wrong"))).andExpect(status().isUnauthorized)
	}

	// ---- FR-11 / FR-12 / FR-13: dashboard --------------------------------------

	@Test
	fun `teams are seeded`() {
		mvc.perform(get("/api/teams").with(responder))
			.andExpect(status().isOk)
			.andExpect(jsonPath("$.length()").value(3))
	}

	@Test
	fun `assign and unassign a team`() {
		val id = createIncident()
		mvc.perform(
			patch("/api/incidents/$id/assign").with(responder)
				.contentType(MediaType.APPLICATION_JSON).content("""{"teamId": "team-rescue-b"}"""),
		)
			.andExpect(status().isOk)
			.andExpect(jsonPath("$.assignedTeam.teamName").value("Search & Rescue Bravo"))

		mvc.perform(
			patch("/api/incidents/$id/assign").with(responder)
				.contentType(MediaType.APPLICATION_JSON).content("""{"teamId": null}"""),
		)
			.andExpect(status().isOk)
			.andExpect(jsonPath("$.assignedTeam").doesNotExist())
	}

	@Test
	fun `unknown team or incident is not found`() {
		val id = createIncident()
		mvc.perform(
			patch("/api/incidents/$id/assign").with(responder)
				.contentType(MediaType.APPLICATION_JSON).content("""{"teamId": "nope"}"""),
		).andExpect(status().isNotFound)
		mvc.perform(
			patch("/api/incidents/nope/status").with(responder)
				.contentType(MediaType.APPLICATION_JSON).content("""{"status": "RESOLVED"}"""),
		).andExpect(status().isNotFound)
	}

	@Test
	fun `status update and status filter`() {
		val id = createIncident()
		mvc.perform(
			patch("/api/incidents/$id/status").with(responder)
				.contentType(MediaType.APPLICATION_JSON).content("""{"status": "RESOLVED"}"""),
		)
			.andExpect(status().isOk)
			.andExpect(jsonPath("$.status").value("RESOLVED"))

		mvc.perform(get("/api/incidents").param("status", "PENDING", "ACKNOWLEDGED").with(responder))
			.andExpect(status().isOk)
			.andExpect(jsonPath("$[*].incidentId", not(hasItem(id))))
	}
}
