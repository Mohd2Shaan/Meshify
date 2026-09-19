package com.emergencymesh.tools

import com.emergencymesh.crypto.Sodium
import com.emergencymesh.proto.EmergencyPayload
import java.io.File
import java.net.URI
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.util.Base64
import java.util.UUID

/**
 * `./gradlew seedDemo` (with the server running): posts a few TEST incidents
 * through the real gateway API, sealed exactly as a phone seals them. For
 * building and checking the dashboard without phones. Every note starts with
 * "[TEST]" so these can't be mistaken for real phone alerts.
 *
 * Args: [baseUrl] [centreLat] [centreLon]. Defaults: localhost:8080, Chennai.
 */
fun main(args: Array<String>) {
	val base = args.getOrElse(0) { "http://localhost:8080" }
	val lat0 = args.getOrNull(1)?.toDouble() ?: 13.0827
	val lon0 = args.getOrNull(2)?.toDouble() ?: 80.2707

	val keyLine = File("secrets/mesh-keys.properties").readLines()
		.first { it.startsWith("mesh.crypto.private-key=") }
	val sk = Base64.getDecoder().decode(keyLine.substringAfter("="))
	val pk = Sodium.publicKeyOf(sk)
	val apiKey = System.getenv("MESH_GATEWAY_API_KEYS")?.split(",")?.first() ?: "dev-gateway-key"

	data class Sample(val type: String, val dLat: Double, val dLon: Double, val hops: Int, val note: String)
	val samples = listOf(
		Sample("MEDICAL", 0.004, -0.006, 2, "Elderly man, chest pain"),
		Sample("TRAPPED", -0.007, 0.003, 3, "Family of 4 on rooftop, water rising"),
		Sample("SUPPLIES", 0.010, 0.008, 1, "Need drinking water for 12 people"),
		Sample("MEDICAL", -0.002, -0.011, 4, "Child with high fever"),
		Sample("STATUS", 0.006, 0.012, 1, "All safe at community hall"),
		Sample("TRAPPED", -0.012, -0.004, 2, ""),
	)
	val http = HttpClient.newHttpClient()
	val now = System.currentTimeMillis()
	for (s in samples) {
		val payload = EmergencyPayload.newBuilder()
			.setLatitude(lat0 + s.dLat).setLongitude(lon0 + s.dLon)
			.setNote("[TEST] ${s.note}".trim()).build()
		val sealed = Base64.getEncoder().encodeToString(Sodium.seal(payload.toByteArray(), pk))
		val body = """
			{"messageId":"test-${UUID.randomUUID()}","senderDeviceId":"seed-demo","gatewayDeviceId":"seed-demo",
			 "type":"${s.type}","timestampMs":${now - s.hops * 60_000},"ttlExpiryMs":${now + 6 * 3_600_000},
			 "hopCount":${s.hops},"priorityScore":0,"sealedPayload":"$sealed"}
		""".trimIndent()
		val res = http.send(
			HttpRequest.newBuilder(URI.create("$base/api/messages"))
				.header("Content-Type", "application/json").header("X-API-Key", apiKey)
				.POST(HttpRequest.BodyPublishers.ofString(body)).build(),
			HttpResponse.BodyHandlers.ofString(),
		)
		println("${s.type.padEnd(8)} -> ${res.statusCode()}")
	}
}
