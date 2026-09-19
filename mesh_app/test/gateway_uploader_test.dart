import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/api/backend_client.dart';
import 'package:mesh_app/db/app_database.dart';
import 'package:mesh_app/models/emergency_message.dart';
import 'package:mesh_app/services/gateway_uploader.dart';

/// Answers POST /api/messages from a script: messageId -> (status, body).
class FakeBackend implements HttpClientAdapter {
  final Map<String, (int, Map<String, Object?>)> answers = {};
  /// Default answer; like the real backend, each upload gets its own uploadId.
  (int, Map<String, Object?>) fallback = (201, {'ackStatus': 'ACKNOWLEDGED'});
  bool down = false;
  final List<Map<String, Object?>> received = [];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    if (down) {
      throw DioException.connectionError(requestOptions: o, reason: 'no route to host');
    }
    if (o.path == '/api/health') return _json(200, {'status': 'ok'});
    final data = Map<String, Object?>.from(o.data as Map);
    received.add({...data, 'X-API-Key': o.headers['X-API-Key']});
    final (status, json) = answers[data['messageId']] ?? fallback;
    return _json(status, {'uploadId': 'u-${data['messageId']}', ...json});
  }

  ResponseBody _json(int status, Map<String, Object?> json) => ResponseBody.fromString(
        jsonEncode(json),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  late AppDatabase db;
  late FakeBackend backend;
  late BackendClient client;
  late GatewayUploader uploader;
  final now = DateTime(2026, 9, 20, 12);

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    backend = FakeBackend();
    client = BackendClient(
      const BackendSettings('http://hq', 'dev-gateway-key'),
      dio: Dio(BaseOptions(validateStatus: (_) => true))..httpClientAdapter = backend,
    );
    uploader = GatewayUploader(db: db, deviceId: 'GW', clock: () => now);
  });

  tearDown(() => db.close());

  Future<void> store(String id, NeedType type,
      {MessageStatus status = MessageStatus.relayed, Duration ttl = const Duration(hours: 1), double score = 0}) {
    return db.insertMessage(MessagesCompanion.insert(
      messageId: id,
      senderDeviceId: 'A',
      type: type,
      timestamp: now.subtract(const Duration(minutes: 5)),
      ttlExpiry: now.add(ttl),
      hopCount: 2,
      priorityScore: score,
      status: status,
      sealedPayload: Uint8List.fromList([9, 9, 9]),
      receivedAt: now,
    ));
  }

  test('uploads pending messages most-urgent first, marks them uploaded, records D3', () async {
    await store('status-1', NeedType.status, score: 10);
    await store('medical-1', NeedType.medical, score: 100);
    await store('mine-1', NeedType.trapped, status: MessageStatus.created, score: 90);

    final run = await uploader.uploadPending(client);

    expect(run.delivered, 3);
    expect(backend.received.map((r) => r['messageId']), ['medical-1', 'mine-1', 'status-1']);
    expect(backend.received.first['X-API-Key'], 'dev-gateway-key');
    expect(backend.received.first['gatewayDeviceId'], 'GW');
    expect(backend.received.first['sealedPayload'], base64Encode([9, 9, 9]));
    expect(backend.received.first['type'], 'MEDICAL');
    expect((await db.getMessage('medical-1'))!.status, MessageStatus.uploaded);
    expect((await db.uploadFor('medical-1'))!.backendAckStatus, 'ACKNOWLEDGED');

    // Second run: nothing left to send.
    expect((await uploader.uploadPending(client)).attempted, 0);
  });

  test('a duplicate (already delivered by another gateway) also counts as delivered', () async {
    await store('m1', NeedType.medical);
    backend.answers['m1'] = (200, {'ackStatus': 'DUPLICATE', 'uploadId': 'u1'});
    await uploader.uploadPending(client);
    expect((await db.getMessage('m1'))!.status, MessageStatus.uploaded);
    expect((await db.uploadFor('m1'))!.backendAckStatus, 'DUPLICATE');
  });

  test('backend says expired (422) or unreadable (400): stop carrying it', () async {
    await store('late', NeedType.supplies);
    await store('bad', NeedType.supplies);
    backend.answers['late'] = (422, {'ackStatus': 'REJECTED', 'uploadId': 'u2', 'reason': 'expired'});
    backend.answers['bad'] = (400, {'detail': 'sealedPayload could not be opened'});

    final run = await uploader.uploadPending(client);
    expect(run.expired, 1);
    expect(run.rejected, 1);
    expect((await db.getMessage('late'))!.status, MessageStatus.expired);
    expect((await db.getMessage('bad'))!.status, MessageStatus.rejected);
  });

  test('network drop mid-run: stops, keeps the rest pending for next time', () async {
    await store('a', NeedType.medical, score: 100);
    await store('b', NeedType.status, score: 10);
    backend.down = true;

    final run = await uploader.uploadPending(client);
    expect(run.stoppedBecause, isNotNull);
    expect((await db.getMessage('a'))!.status, MessageStatus.relayed);

    backend.down = false;
    expect((await uploader.uploadPending(client)).delivered, 2);
  });

  test('wrong API key: stops at once and says so', () async {
    await store('a', NeedType.medical);
    await store('b', NeedType.medical);
    backend.fallback = (401, {});
    final run = await uploader.uploadPending(client);
    expect(run.unauthorized, isTrue);
    expect(backend.received, hasLength(1));
  });

  test('locally expired messages are never uploaded', () async {
    await store('old', NeedType.medical, ttl: const Duration(minutes: -1));
    expect((await uploader.uploadPending(client)).attempted, 0);
    expect(backend.received, isEmpty);
  });

  test('health check: reachable only when the backend answers', () async {
    expect(await client.isReachable(), isTrue);
    backend.down = true;
    expect(await client.isReachable(), isFalse);
  });
}
