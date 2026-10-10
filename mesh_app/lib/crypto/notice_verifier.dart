import 'dart:convert';
import 'dart:typed_data';

import 'package:sodium_libs/sodium_libs.dart';

import 'hq_signing_key.dart';

/// Checks that a receipt or alert really came from Headquarters.
///
/// HQ signs every notice with Ed25519. A phone can't forge one: it would need
/// HQ's private key, which never leaves the backend. Without this check, any
/// phone could tell a victim "help is on the way", or broadcast a fake
/// evacuation order to the whole mesh.
abstract class NoticeVerifier {
  bool verify(Uint8List body, Uint8List signature);
}

class Ed25519NoticeVerifier implements NoticeVerifier {
  /// For tests that load libsodium on the PC (test/support/host_sodium.dart).
  Ed25519NoticeVerifier.withSodium(this._sodium, this._publicKey);

  final Sodium _sodium;
  final Uint8List _publicKey;

  static Future<Ed25519NoticeVerifier> create({String publicKeyBase64 = hqSigningPublicKeyBase64}) async {
    final sodium = await SodiumInit.init();
    final pk = base64Decode(publicKeyBase64);
    if (pk.length != sodium.crypto.sign.publicKeyBytes) {
      throw StateError('HQ signing key must be ${sodium.crypto.sign.publicKeyBytes} bytes');
    }
    return Ed25519NoticeVerifier.withSodium(sodium, pk);
  }

  @override
  bool verify(Uint8List body, Uint8List signature) {
    if (signature.length != _sodium.crypto.sign.bytes) return false;
    return _sodium.crypto.sign.verifyDetached(message: body, signature: signature, publicKey: _publicKey);
  }
}
