package com.emergencymesh.security

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.web.filter.OncePerRequestFilter
import java.security.MessageDigest

/**
 * Authenticates gateway phones by the X-API-Key header (Tech Stack Report:
 * "Spring Security + API key"). A matching key grants ROLE_GATEWAY for this
 * request only; a missing or wrong key leaves the request anonymous.
 */
class ApiKeyFilter(apiKeys: Collection<String>) : OncePerRequestFilter() {

	private val keys = apiKeys.filter { it.isNotBlank() }.map { it.toByteArray() }

	override fun doFilterInternal(
		request: HttpServletRequest,
		response: HttpServletResponse,
		chain: FilterChain,
	) {
		val presented = request.getHeader(HEADER)?.toByteArray()
		// Constant-time comparison so the key can't be guessed byte by byte.
		if (presented != null && keys.any { MessageDigest.isEqual(it, presented) }) {
			val auth = UsernamePasswordAuthenticationToken(
				"gateway", null, listOf(SimpleGrantedAuthority("ROLE_GATEWAY")),
			)
			SecurityContextHolder.getContext().authentication = auth
		}
		chain.doFilter(request, response)
	}

	companion object {
		const val HEADER = "X-API-Key"
	}
}
