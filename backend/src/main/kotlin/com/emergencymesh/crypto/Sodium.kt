package com.emergencymesh.crypto

import com.goterl.lazysodium.LazySodiumJava
import com.goterl.lazysodium.SodiumJava
import com.goterl.lazysodium.interfaces.Box

/**
 * libsodium via lazysodium (bundles the native library for Windows, Linux and
 * macOS). Sealed box = X25519 key exchange + XSalsa20-Poly1305, the same
 * primitive the app uses through sodium_libs.
 */
object Sodium {
	val lazy: LazySodiumJava by lazy { LazySodiumJava(SodiumJava()) }

	const val KEY_BYTES = Box.PUBLICKEYBYTES
	const val SEAL_OVERHEAD = Box.SEALBYTES

	/** Returns (publicKey, secretKey). */
	fun newKeyPair(): Pair<ByteArray, ByteArray> {
		val pk = ByteArray(Box.PUBLICKEYBYTES)
		val sk = ByteArray(Box.SECRETKEYBYTES)
		check(lazy.cryptoBoxKeypair(pk, sk)) { "crypto_box_keypair failed" }
		return pk to sk
	}

	/** An X25519 public key is derived from the secret key. */
	fun publicKeyOf(secretKey: ByteArray): ByteArray {
		val pk = ByteArray(Box.PUBLICKEYBYTES)
		check(lazy.cryptoScalarMultBase(pk, secretKey)) { "crypto_scalarmult_base failed" }
		return pk
	}

	/** crypto_box_seal: what a phone does. Used here only by tests and KeyGen. */
	fun seal(message: ByteArray, publicKey: ByteArray): ByteArray {
		val out = ByteArray(message.size + Box.SEALBYTES)
		check(lazy.cryptoBoxSeal(out, message, message.size.toLong(), publicKey)) { "crypto_box_seal failed" }
		return out
	}

	/** crypto_box_seal_open. Null if the box is corrupt or sealed for another key. */
	fun open(sealed: ByteArray, publicKey: ByteArray, secretKey: ByteArray): ByteArray? {
		if (sealed.size < Box.SEALBYTES) return null
		val out = ByteArray(sealed.size - Box.SEALBYTES)
		val ok = lazy.cryptoBoxSealOpen(out, sealed, sealed.size.toLong(), publicKey, secretKey)
		return if (ok) out else null
	}
}
