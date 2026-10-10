package com.emergencymesh.crypto

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.util.Base64

/**
 * Signs HQ notices (delivery receipts, broadcast alerts) with Ed25519 so phones
 * can tell they really came from Headquarters. The keypair is derived from the
 * same private key as sealed-box decryption (MESH_PRIVATE_KEY), so there is no
 * second secret to manage. The public half is baked into the app by
 * `./gradlew genKeys` (mesh_app/lib/crypto/hq_signing_key.dart).
 */
@Component
class NoticeSigner(@Value("\${mesh.crypto.private-key:}") privateKeyBase64: String) {

	private val log = LoggerFactory.getLogger(javaClass)

	private val keys: Pair<ByteArray, ByteArray> = if (privateKeyBase64.isBlank()) {
		// Only reachable in plaintext debugging mode. Phones will reject these signatures.
		log.warn("No mesh.crypto.private-key: signing notices with a throwaway key that phones will reject.")
		Sodium.signingKeyPairFrom(Sodium.newKeyPair().second)
	} else {
		Sodium.signingKeyPairFrom(Base64.getDecoder().decode(privateKeyBase64.trim()))
	}

	val publicKey: ByteArray get() = keys.first

	init {
		log.info("HQ notice signing ready. Public key (must match the app): {}", Base64.getEncoder().encodeToString(publicKey))
	}

	fun sign(body: ByteArray): ByteArray = Sodium.sign(body, keys.second)
}
