package com.emergencymesh.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Clock

/**
 * FR-8: phones call this to decide whether they are a gateway. Having
 * Wi-Fi/data isn't enough, the backend must actually be reachable. Public, and
 * reveals nothing.
 */
@RestController
class HealthController(private val clock: Clock) {

	@GetMapping("/api/health")
	fun health() = mapOf("status" to "ok", "time" to clock.instant().toString())
}
