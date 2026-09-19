package com.emergencymesh.crypto

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.stereotype.Component
import java.util.Base64

/**
 * Opens MeshPacket.sealed_payload back into EmergencyPayload bytes (FR-3,
 * server side). Only the backend ever holds the private key.
 */
interface PayloadDecryptor {
	/** Throws if the payload can't be opened. */
	fun open(sealed: ByteArray): ByteArray
}

/**
 * FR-3: libsodium sealed box. Phones seal with the public key baked into the
 * app. Only this private key can open, so relay phones never can.
 */
@Component
@ConditionalOnProperty(name = ["mesh.crypto.mode"], havingValue = "sealed", matchIfMissing = true)
class SealedBoxPayloadDecryptor(
	@Value("\${mesh.crypto.private-key:}") privateKeyBase64: String,
) : PayloadDecryptor {

	private val secretKey: ByteArray
	private val publicKey: ByteArray

	init {
		require(privateKeyBase64.isNotBlank()) {
			"mesh.crypto.private-key is not set. Run `./gradlew genKeys` once (writes " +
				"secrets/mesh-keys.properties), or set MESH_PRIVATE_KEY."
		}
		secretKey = Base64.getDecoder().decode(privateKeyBase64.trim())
		require(secretKey.size == Sodium.KEY_BYTES) { "mesh.crypto.private-key must be ${Sodium.KEY_BYTES} bytes" }
		publicKey = Sodium.publicKeyOf(secretKey)
		LoggerFactory.getLogger(javaClass).info(
			"Sealed-box decryption ready. Public key (must match the app): {}",
			Base64.getEncoder().encodeToString(publicKey),
		)
	}

	override fun open(sealed: ByteArray): ByteArray =
		Sodium.open(sealed, publicKey, secretKey)
			?: throw IllegalArgumentException("sealed box could not be opened (wrong key or tampered)")
}

/**
 * Debugging only: the "sealed" payload is the raw EmergencyPayload bytes.
 * Selected by mesh.crypto.mode=plaintext.
 */
@Component
@ConditionalOnProperty(name = ["mesh.crypto.mode"], havingValue = "plaintext")
class PlaintextPayloadDecryptor : PayloadDecryptor {
	init {
		LoggerFactory.getLogger(javaClass)
			.warn("mesh.crypto.mode=plaintext: payloads are NOT decrypted. Debugging only.")
	}

	override fun open(sealed: ByteArray): ByteArray = sealed
}
