package com.emergencymesh.config

import com.emergencymesh.entity.ResponderTeam
import com.emergencymesh.repository.ResponderTeamRepository
import org.springframework.boot.ApplicationRunner
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import java.time.Clock

@Configuration
class AppConfig {

	/** Injected so tests can control "now" for TTL checks. */
	@Bean
	fun clock(): Clock = Clock.systemUTC()

	/** Demo responder teams for FR-12, created once on an empty database. */
	@Bean
	fun seedTeams(teams: ResponderTeamRepository) = ApplicationRunner {
		if (teams.count() == 0L) {
			teams.saveAll(
				listOf(
					ResponderTeam("team-medical-a", "Medical Team Alpha", "North Zone", "+91-00000-00001"),
					ResponderTeam("team-rescue-b", "Search & Rescue Bravo", "Central Zone", "+91-00000-00002"),
					ResponderTeam("team-supply-c", "Supplies Unit Charlie", "South Zone", "+91-00000-00003"),
				),
			)
		}
	}
}
