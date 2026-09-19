package com.emergencymesh.crypto

import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.stereotype.Component

/**
 * Opens MeshPacket.sealed_payload back into EmergencyPayload bytes (FR-3,
 * server side). Only the backend ever holds the private key.
 */
interface PayloadDecryptor {
	fun open(sealed: ByteArray): ByteArray
}

/**
 * Development stand-in until Phase 5: the "sealed" payload is just the raw
 * EmergencyPayload bytes. Selected by mesh.crypto.mode=plaintext.
 */
@Component
@ConditionalOnProperty(name = ["mesh.crypto.mode"], havingValue = "plaintext")
class PlaintextPayloadDecryptor : PayloadDecryptor {
	init {
		LoggerFactory.getLogger(javaClass)
			.warn("mesh.crypto.mode=plaintext: payloads are NOT decrypted. Development only.")
	}

	override fun open(sealed: ByteArray): ByteArray = sealed
}
