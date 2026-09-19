import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/crypto/backend_public_key.dart';
import 'package:mesh_app/proto/emergency_message.pb.dart' as pb;
import 'package:sodium/sodium.dart' show SecureKey;

import 'support/host_sodium.dart';

/// FR-3 interop check on the developer PC, using the same libsodium the
/// backend loads.
///
/// Proves that:
///  1. what the app seals with the baked-in public key opens with the
///     backend's private key (backend/secrets/mesh-keys.properties).
///     seal_open fails if the two keys don't match.
///  2. the backend-sealed sample (genKeys output) opens in Dart, i.e. both
///     sides use the identical sealed-box format
void main() {
  final skip = HostSodium.unavailableReason;
  late HostSodium host;
  late SecureKey secretKey;
  late Uint8List publicKey;

  setUpAll(() async {
    if (skip != null) return;
    host = await HostSodium.load();
    secretKey = host.backendSecretKey();
    publicKey = base64Decode(backendPublicKeyBase64);
  });

  test('app-sealed payload opens with the backend private key', () {
    final payload = pb.EmergencyPayload(latitude: 13.0827, longitude: 80.2707, note: 'Leg injury');
    final sealed = host.seal(payload.writeToBuffer(), publicKey);

    expect(sealed.length, payload.writeToBuffer().length + 48);
    final opened = host.sodium.crypto.box.sealOpen(cipherText: sealed, publicKey: publicKey, secretKey: secretKey);
    expect(pb.EmergencyPayload.fromBuffer(opened).note, 'Leg injury');

    // What a relay phone sees: no plaintext note or coordinates in the bytes.
    expect(utf8.decode(sealed, allowMalformed: true), isNot(contains('Leg injury')));
  }, skip: skip);

  test('backend-sealed sample opens in Dart (same format both sides)', () {
    final sampleFile = File('${HostSodium.repo}/backend/secrets/sample-sealed-payload.txt');
    if (!sampleFile.existsSync()) return;
    final sealed = base64Decode(sampleFile.readAsStringSync().trim());
    final opened = host.sodium.crypto.box.sealOpen(cipherText: sealed, publicKey: publicKey, secretKey: secretKey);
    expect(pb.EmergencyPayload.fromBuffer(opened).latitude, closeTo(13.0827, 1e-9));
  }, skip: skip);
}
