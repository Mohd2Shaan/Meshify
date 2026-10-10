package com.emergencymesh.crypto

import com.goterl.lazysodium.LazySodiumJava
import com.goterl.lazysodium.SodiumJava
import com.goterl.lazysodium.interfaces.Box
import com.goterl.lazysodium.interfaces.Sign

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

	/**
	 * Ed25519 signing keypair derived from [secretKey] (the X25519 key) with a
	 * keyed BLAKE2b hash. Domain-separated, so the encryption key itself is never
	 * used for signing, and there is still only one secret to back up and deploy.
	 * Returns (publicKey 32 B, secretKey 64 B).
	 */
	fun signingKeyPairFrom(secretKey: ByteArray): Pair<ByteArray, ByteArray> {
		val context = "meshify/hq-notice-signing/v1".toByteArray()
		val seed = ByteArray(Sign.SEEDBYTES)
		check(lazy.cryptoGenericHash(seed, seed.size, context, context.size.toLong(), secretKey, secretKey.size)) {
			"crypto_generichash failed"
		}
		val pk = ByteArray(Sign.PUBLICKEYBYTES)
		val sk = ByteArray(Sign.SECRETKEYBYTES)
		check(lazy.cryptoSignSeedKeypair(pk, sk, seed)) { "crypto_sign_seed_keypair failed" }
		return pk to sk
	}

	fun sign(message: ByteArray, signingSecretKey: ByteArray): ByteArray {
		val sig = ByteArray(Sign.BYTES)
		check(lazy.cryptoSignDetached(sig, message, message.size.toLong(), signingSecretKey)) { "crypto_sign failed" }
		return sig
	}

	fun verify(message: ByteArray, signature: ByteArray, signingPublicKey: ByteArray): Boolean =
		signature.size == Sign.BYTES &&
			lazy.cryptoSignVerifyDetached(signature, message, message.size, signingPublicKey)
}
