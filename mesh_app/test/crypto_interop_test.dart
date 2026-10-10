import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/crypto/backend_public_key.dart';
import 'package:mesh_app/crypto/hq_signing_key.dart';
import 'package:mesh_app/crypto/notice_verifier.dart';
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
///  3. the HQ signing key baked into the app is the one the backend derives
///     from its private key, and real Ed25519 signatures verify (and forged
///     ones don't) through the app's NoticeVerifier
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

  test('app HQ signing key = key the backend derives; real signatures verify', () {
    final sodium = host.sodium;
    // Same derivation as Sodium.signingKeyPairFrom in the backend.
    final seed = sodium.crypto.genericHash(
      message: Uint8List.fromList(utf8.encode('meshify/hq-notice-signing/v1')),
      outLen: 32,
      key: secretKey,
    );
    final keyPair = sodium.crypto.sign.seedKeyPair(SecureKey.fromList(sodium, seed));
    expect(base64Encode(keyPair.publicKey), hqSigningPublicKeyBase64,
        reason: 'run ./gradlew genKeys in backend/ to refresh hq_signing_key.dart');

    final verifier = Ed25519NoticeVerifier.withSodium(sodium, base64Decode(hqSigningPublicKeyBase64));
    final body = pb.HqNotice(noticeId: 'n1', alert: pb.HqAlert(title: 'Evacuate')).writeToBuffer();
    final sig = sodium.crypto.sign.detached(message: body, secretKey: keyPair.secretKey);
    expect(verifier.verify(body, sig), isTrue);
    expect(verifier.verify(Uint8List.fromList(body)..[0] ^= 1, sig), isFalse);

    final stranger = sodium.crypto.sign.keyPair();
    expect(verifier.verify(body, sodium.crypto.sign.detached(message: body, secretKey: stranger.secretKey)),
        isFalse);
  }, skip: skip);
}
