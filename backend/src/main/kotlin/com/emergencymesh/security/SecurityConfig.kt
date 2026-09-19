package com.emergencymesh.security

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.crypto.factory.PasswordEncoderFactories
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.provisioning.InMemoryUserDetailsManager
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter

/**
 * - GET /api/health: public (gateway detection, FR-8).
 * - POST /api/messages: gateway phones, via X-API-Key (ROLE_GATEWAY).
 * - Everything else under /api: responders, via HTTP Basic (ROLE_RESPONDER).
 *   Incident data contains victims' locations, so it is never public (SRS 5.3).
 * - Anything else (dashboard page, H2 console in dev): open. The dashboard
 *   page itself holds no data; it logs in to fetch incidents.
 */
@Configuration
class SecurityConfig {

	@Bean
	fun passwordEncoder(): PasswordEncoder = PasswordEncoderFactories.createDelegatingPasswordEncoder()

	@Bean
	fun responderUsers(
		@Value("\${mesh.responder.username}") username: String,
		@Value("\${mesh.responder.password}") password: String,
		encoder: PasswordEncoder,
	): UserDetailsService = InMemoryUserDetailsManager(
		User.withUsername(username).password(encoder.encode(password)).roles("RESPONDER").build(),
	)

	@Bean
	fun filterChain(
		http: HttpSecurity,
		@Value("\${mesh.gateway.api-keys}") apiKeys: List<String>,
	): SecurityFilterChain {
		http
			.csrf { it.disable() } // stateless API: no cookies, so no CSRF surface
			.sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
			.headers { h -> h.frameOptions { it.sameOrigin() } } // H2 console uses frames
			.addFilterBefore(ApiKeyFilter(apiKeys), BasicAuthenticationFilter::class.java)
			.httpBasic { }
			.authorizeHttpRequests {
				it.requestMatchers(HttpMethod.GET, "/api/health").permitAll()
				it.requestMatchers(HttpMethod.POST, "/api/messages").hasRole("GATEWAY")
				it.requestMatchers("/api/**").hasRole("RESPONDER")
				it.anyRequest().permitAll()
			}
		return http.build()
	}
}
