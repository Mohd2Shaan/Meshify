import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/api/backend_client.dart';
import 'package:mesh_app/crypto/backend_public_key.dart';
import 'package:mesh_app/db/app_database.dart';
import 'package:mesh_app/models/emergency_message.dart';
import 'package:mesh_app/proto/emergency_message.pb.dart' as pb;
import 'package:mesh_app/services/gateway_uploader.dart';

import 'support/host_sodium.dart';

/// End to end on the PC: the app's real sealing, store, GatewayUploader and
/// BackendClient against a RUNNING backend. Only the radios are missing.
///
///   cd backend && ./gradlew bootRun --args='--spring.profiles.active=dev'
///   cd mesh_app && flutter test test/e2e_backend_test.dart
///
/// Skips itself when no backend answers on E2E_BACKEND (default localhost:8080).
void main() {
  final base = Platform.environment['E2E_BACKEND'] ?? 'http://localhost:8080';
  final skip = HostSodium.unavailableReason ?? _backendDown(base);

  test('sealed message stored on a relay phone reaches HQ and is readable there', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final host = await HostSodium.load();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final now = DateTime.now();
    final id = 'e2e-${newId()}';

    // As the origin phone seals it (FR-3) and a relay phone stores it (hop 2).
    final sealed = host.seal(
      pb.EmergencyPayload(latitude: 12.9716, longitude: 77.5946, note: '[TEST] e2e gateway upload')
          .writeToBuffer(),
      base64Decode(backendPublicKeyBase64),
    );
    await db.insertMessage(MessagesCompanion.insert(
      messageId: id,
      senderDeviceId: 'phone-A',
      type: NeedType.trapped,
      timestamp: now,
      ttlExpiry: now.add(const Duration(hours: 1)),
      hopCount: 2,
      priorityScore: 86,
      status: MessageStatus.relayed,
      sealedPayload: Uint8List.fromList(sealed),
      receivedAt: now,
      latitude: const Value(null),
      longitude: const Value(null),
    ));

    // FR-8 + FR-9 on the gateway.
    final client = BackendClient(BackendSettings(base, 'dev-gateway-key'));
    expect(await client.isReachable(), isTrue);
    final run = await GatewayUploader(db: db, deviceId: 'phone-C').uploadPending(client);
    expect(run.delivered, 1, reason: run.stoppedBecause);
    expect((await db.getMessage(id))!.status, MessageStatus.uploaded);
    expect((await db.uploadFor(id))!.backendAckStatus, 'ACKNOWLEDGED');

    // FR-10 / FR-11: HQ decrypted it into an incident.
    final auth = base64Encode(utf8.encode('responder:responder123'));
    final res = await Dio().get<List<dynamic>>('$base/api/incidents',
        options: Options(headers: {'Authorization': 'Basic $auth'}));
    final incident = res.data!.cast<Map<String, dynamic>>().firstWhere((i) => i['messageId'] == id);
    expect(incident['type'], 'TRAPPED');
    expect(incident['note'], '[TEST] e2e gateway upload');
    expect(incident['latitude'], closeTo(12.9716, 1e-9));
    expect(incident['hopCount'], 2);
    await db.close();
  }, skip: skip);
}

/// `skip:` must be known before the test runs, so this probe is synchronous.
String? _backendDown(String base) {
  final uri = Uri.parse(base);
  try {
    RawSynchronousSocket.connectSync(uri.host, uri.port).closeSync();
    return null;
  } on SocketException {
    return 'no backend running at $base';
  }
}
