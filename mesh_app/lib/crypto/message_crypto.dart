import 'dart:typed_data';

/// FR-3: seals an EmergencyPayload so only Headquarters can open it.
///
/// Phones only ever seal. They never hold the backend's private key, so
/// relay phones cannot open anything they carry.
abstract class MessageCrypto {
  Future<Uint8List> seal(Uint8List plaintext);

  /// Short label shown in the UI/logs so it's obvious which mode is active.
  String get mode;
}

/// Development stand-in until Phase 5 (libsodium sealed box). Matches the
/// backend's mesh.crypto.mode=plaintext.
class PlaintextCrypto implements MessageCrypto {
  @override
  Future<Uint8List> seal(Uint8List plaintext) async => plaintext;

  @override
  String get mode => 'PLAINTEXT (dev)';
}
