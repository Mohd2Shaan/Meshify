package com.emergencymesh

import com.emergencymesh.crypto.Sodium
import com.emergencymesh.proto.AlertLevel
import com.emergencymesh.proto.EmergencyPayload
import com.emergencymesh.proto.HqNotice
import com.emergencymesh.proto.ReceiptStatus
import com.jayway.jsonpath.JsonPath
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.httpBasic
import org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
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
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** HQ -> mesh notices: delivery receipts and broadcast alerts, signed with Ed25519. */
@SpringBootTest(properties = ["mesh.crypto.private-key=${ApiIntegrationTests.TEST_PRIVATE_KEY}"])
@ActiveProfiles("dev")
class NoticeIntegrationTests {

	companion object {
		private val testSecretKey = Base64.getDecoder().decode(ApiIntegrationTests.TEST_PRIVATE_KEY)

		/** What the app would have baked in for the test key. */
		val signingPublicKey: ByteArray = Sodium.signingKeyPairFrom(testSecretKey).first
	}

	@Autowired lateinit var context: WebApplicationContext
	lateinit var mvc: MockMvc

	@BeforeEach
	fun setUp() {
		mvc = MockMvcBuilders.webAppContextSetup(context).apply<DefaultMockMvcBuilder>(springSecurity()).build()
	}

	private val responder = httpBasic("responder", "responder123")
	private val b64 = Base64.getDecoder()

	private fun upload(messageId: String): String {
		val sealed = Sodium.seal(
			EmergencyPayload.newBuilder().setLatitude(13.0).setLongitude(80.0).build().toByteArray(),
			ApiIntegrationTests.testPublicKey,
		)
		val now = System.currentTimeMillis()
		val body = """
			{"messageId":"$messageId","senderDeviceId":"phone-a","gatewayDeviceId":"phone-c","type":"MEDICAL",
			 "timestampMs":$now,"ttlExpiryMs":${now + 3_600_000},
			 "hopCount":1,"sealedPayload":"${Base64.getEncoder().encodeToString(sealed)}"}
		""".trimIndent()
		val res = mvc.perform(
			post("/api/messages").header("X-API-Key", "dev-gateway-key")
				.contentType(MediaType.APPLICATION_JSON).content(body),
		).andExpect(status().isCreated).andReturn()
		return JsonPath.read(res.response.contentAsString, "$.incidentId")
	}

	private fun feedJson(since: Long = 0): String =
		mvc.perform(get("/api/notices").param("since", since.toString()).header("X-API-Key", "dev-gateway-key"))
			.andExpect(status().isOk).andReturn().response.contentAsString

	/** Fetches the gateway feed, checks every signature, and returns the decoded notices. */
	private fun feed(since: Long = 0): List<HqNotice> {
		val json = feedJson(since)
		val bodies: List<String> = JsonPath.read(json, "$.notices[*].body")
		val sigs: List<String> = JsonPath.read(json, "$.notices[*].signature")
		return bodies.zip(sigs).map { (body, sig) ->
			assertTrue(Sodium.verify(b64.decode(body), b64.decode(sig), signingPublicKey), "bad signature")
			HqNotice.parseFrom(b64.decode(body))
		}
	}

	private fun receiptsFor(messageId: String) = feed().filter { it.hasReceipt() && it.receipt.messageId == messageId }

	@Test
	fun `upload issues a signed DELIVERED receipt for the sender`() {
		val id = UUID.randomUUID().toString()
		upload(id)
		val receipt = receiptsFor(id).single()
		assertEquals(ReceiptStatus.DELIVERED, receipt.receipt.status)
		assertTrue(receipt.expiryMs > System.currentTimeMillis())
	}

	@Test
	fun `an altered notice or another key's signature fails verification`() {
		upload(UUID.randomUUID().toString())
		val json = feedJson()
		val body = b64.decode(JsonPath.read<List<String>>(json, "$.notices[*].body").last())
		val sig = b64.decode(JsonPath.read<List<String>>(json, "$.notices[*].signature").last())
		assertTrue(Sodium.verify(body, sig, signingPublicKey))

		val altered = HqNotice.parseFrom(body).toBuilder().setExpiryMs(Long.MAX_VALUE).build().toByteArray()
		assertFalse(Sodium.verify(altered, sig, signingPublicKey))

		val (_, otherSk) = Sodium.signingKeyPairFrom(Sodium.newKeyPair().second)
		assertFalse(Sodium.verify(body, Sodium.sign(body, otherSk), signingPublicKey))
	}

	@Test
	fun `assigning a team and acknowledging sends a newer receipt that replaces the old one`() {
		val id = UUID.randomUUID().toString()
		val incidentId = upload(id)
		mvc.perform(
			patch("/api/incidents/$incidentId/assign").with(responder)
				.contentType(MediaType.APPLICATION_JSON).content("""{"teamId":"team-medical-a"}"""),
		).andExpect(status().isOk).andExpect(jsonPath("$.receipt.teamName").value("Medical Team Alpha"))
		mvc.perform(
			patch("/api/incidents/$incidentId/status").with(responder)
				.contentType(MediaType.APPLICATION_JSON).content("""{"status":"ACKNOWLEDGED"}"""),
		).andExpect(status().isOk).andExpect(jsonPath("$.receipt.status").value("ACKNOWLEDGED"))

		// Gateways only get the latest receipt per message, not the whole history.
		val receipt = receiptsFor(id).single().receipt
		assertEquals(ReceiptStatus.ACKNOWLEDGED, receipt.status)
		assertEquals("Medical Team Alpha", receipt.teamName)

		mvc.perform(get("/api/incidents").with(responder))
			.andExpect(jsonPath("$[?(@.incidentId == '$incidentId')].receipt.pickedUpAt").isNotEmpty)
	}

	@Test
	fun `since skips notices the gateway already has`() {
		upload(UUID.randomUUID().toString())
		val later = System.currentTimeMillis() + 120_000 // beyond the server's overlap window
		assertTrue(feed(since = later).isEmpty())
	}

	@Test
	fun `responders broadcast an alert that gateways pick up`() {
		mvc.perform(
			post("/api/alerts").with(responder).contentType(MediaType.APPLICATION_JSON)
				.content("""{"level":"CRITICAL","title":"Evacuate North Zone","message":"Go to City School shelter now.","validForMinutes":60}"""),
		)
			.andExpect(status().isCreated)
			.andExpect(jsonPath("$.pickedUpAt").doesNotExist())

		val alert = feed().last { it.hasAlert() && it.alert.title == "Evacuate North Zone" }
		assertEquals(AlertLevel.CRITICAL, alert.alert.level)
		assertEquals("Go to City School shelter now.", alert.alert.body)

		mvc.perform(get("/api/alerts").with(responder))
			.andExpect(status().isOk)
			.andExpect(jsonPath("$[?(@.title == 'Evacuate North Zone')].pickedUpAt").isNotEmpty)
	}

	@Test
	fun `alert input is validated`() {
		fun create(json: String) =
			mvc.perform(post("/api/alerts").with(responder).contentType(MediaType.APPLICATION_JSON).content(json))
		create("""{"level":"INFO","title":"","message":"x"}""").andExpect(status().isBadRequest)
		create("""{"level":"INFO","title":"t","message":"${"x".repeat(281)}"}""").andExpect(status().isBadRequest)
		create("""{"title":"t","message":"x"}""").andExpect(status().isBadRequest)
		create("""{"level":"INFO","title":"t","message":"x","validForMinutes":1}""").andExpect(status().isBadRequest)
	}

	@Test
	fun `notices need a gateway key and alerts need a responder login`() {
		mvc.perform(get("/api/notices")).andExpect(status().isUnauthorized)
		mvc.perform(get("/api/notices").with(responder)).andExpect(status().isForbidden)
		mvc.perform(get("/api/alerts")).andExpect(status().isUnauthorized)
		mvc.perform(
			post("/api/alerts").header("X-API-Key", "dev-gateway-key").contentType(MediaType.APPLICATION_JSON)
				.content("""{"level":"INFO","title":"fake","message":"from a phone"}"""),
		).andExpect(status().isForbidden)
	}
}
