@TestOn('windows')
library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/crypto/backend_public_key.dart';
import 'package:mesh_app/proto/emergency_message.pb.dart' as pb;
import 'package:sodium/sodium.dart';
import 'package:sodium/sodium.ffi.dart';

/// FR-3 interop check on the developer PC, using the same libsodium the
/// backend loads (the DLL inside lazysodium-java's jar, from the Gradle cache).
///
/// Proves that:
///  1. what the app seals with the baked-in public key opens with the
///     backend's private key (backend/secrets/mesh-keys.properties)
///  2. the backend-sealed sample (genKeys output) opens in Dart, i.e. both
///     sides use the identical sealed-box format
///
/// (1) also proves the private key matches the public key compiled into the
/// app: seal_open fails if they differ.
///
/// Skips itself if the jar or the key files aren't on this machine.
void main() {
  final home = Platform.environment['USERPROFILE'] ?? '';
  final repo = Directory.current.parent.path;
  final keyFile = File('$repo/backend/secrets/mesh-keys.properties');
  final sampleFile = File('$repo/backend/secrets/sample-sealed-payload.txt');
  final jar = _findJar('$home/.gradle/caches/modules-2/files-2.1/com.goterl/lazysodium-java');

  final skip = jar == null
      ? 'lazysodium jar not in Gradle cache (build the backend once)'
      : !keyFile.existsSync()
          ? 'no backend key (run ./gradlew genKeys)'
          : null;

  late Sodium sodium;
  late SecureKey secretKey;
  late Uint8List publicKey;

  setUpAll(() async {
    if (skip != null) return;
    final dll = await _extractDll(jar!);
    sodium = await SodiumInit.init(() => DynamicLibrary.open(dll));
    final line = keyFile.readAsLinesSync().firstWhere((l) => l.startsWith('mesh.crypto.private-key='));
    secretKey = SecureKey.fromList(sodium, base64Decode(line.split('=').skip(1).join('=')));
    publicKey = base64Decode(backendPublicKeyBase64);
  });

  test('app-sealed payload opens with the backend private key', () {
    final payload = pb.EmergencyPayload(latitude: 13.0827, longitude: 80.2707, note: 'Leg injury');
    final sealed = sodium.crypto.box.seal(message: payload.writeToBuffer(), publicKey: publicKey);

    expect(sealed.length, payload.writeToBuffer().length + 48);
    final opened = sodium.crypto.box.sealOpen(cipherText: sealed, publicKey: publicKey, secretKey: secretKey);
    expect(pb.EmergencyPayload.fromBuffer(opened).note, 'Leg injury');

    // What a relay phone sees: no plaintext note or coordinates in the bytes.
    expect(utf8.decode(sealed, allowMalformed: true), isNot(contains('Leg injury')));
  }, skip: skip);

  test('backend-sealed sample opens in Dart (same format both sides)', () {
    if (!sampleFile.existsSync()) return;
    final sealed = base64Decode(sampleFile.readAsStringSync().trim());
    final opened = sodium.crypto.box.sealOpen(cipherText: sealed, publicKey: publicKey, secretKey: secretKey);
    expect(pb.EmergencyPayload.fromBuffer(opened).latitude, closeTo(13.0827, 1e-9));
  }, skip: skip);
}

String? _findJar(String dir) {
  final d = Directory(dir);
  if (!d.existsSync()) return null;
  for (final f in d.listSync(recursive: true)) {
    if (f.path.endsWith('lazysodium-java-5.1.4.jar')) return f.path;
  }
  return null;
}

Future<String> _extractDll(String jar) async {
  final out = Directory('${Directory.systemTemp.path}/mesh_sodium')..createSync(recursive: true);
  final dll = '${out.path}/libsodium.dll';
  if (!File(dll).existsSync()) {
    final r = await Process.run('tar', ['-xf', jar, '-C', out.path, 'windows64/libsodium.dll']);
    if (r.exitCode != 0) throw StateError('could not extract libsodium.dll: ${r.stderr}');
    File('${out.path}/windows64/libsodium.dll').copySync(dll);
  }
  return dll;
}
