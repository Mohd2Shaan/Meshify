import 'dart:convert';
import 'dart:typed_data';

import 'package:sodium_libs/sodium_libs.dart';

import 'backend_public_key.dart';

/// FR-3: seals an EmergencyPayload so only Headquarters can open it.
///
/// Phones only ever seal. They never hold the backend's private key, so
/// relay phones cannot open anything they carry.
abstract class MessageCrypto {
  Future<Uint8List> seal(Uint8List plaintext);

  /// Short label shown in the UI/logs so it's obvious which mode is active.
  String get mode;
}

/// libsodium sealed box (crypto_box_seal): an ephemeral X25519 key exchange
/// with the backend's public key, then XSalsa20-Poly1305. Anonymous (the
/// sender has no key to leak) and tamper-evident. The sealed box is 48 bytes
/// longer than the plaintext.
class SealedBoxCrypto implements MessageCrypto {
  SealedBoxCrypto._(this._sodium, this._backendPublicKey);

  final Sodium _sodium;
  final Uint8List _backendPublicKey;

  static Future<SealedBoxCrypto> create({String publicKeyBase64 = backendPublicKeyBase64}) async {
    final sodium = await SodiumInit.init();
    final pk = base64Decode(publicKeyBase64);
    if (pk.length != sodium.crypto.box.publicKeyBytes) {
      throw StateError('backend public key must be ${sodium.crypto.box.publicKeyBytes} bytes');
    }
    return SealedBoxCrypto._(sodium, pk);
  }

  @override
  Future<Uint8List> seal(Uint8List plaintext) async =>
      _sodium.crypto.box.seal(message: plaintext, publicKey: _backendPublicKey);

  @override
  String get mode => 'libsodium sealed box';
}

/// No encryption. Only for unit tests on a PC, where the native libsodium
/// isn't loaded. Never used in the app.
class PlaintextCrypto implements MessageCrypto {
  @override
  Future<Uint8List> seal(Uint8List plaintext) async => plaintext;

  @override
  String get mode => 'PLAINTEXT (test only)';
}
