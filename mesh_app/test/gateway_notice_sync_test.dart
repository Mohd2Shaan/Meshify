import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/api/backend_client.dart';
import 'package:mesh_app/mesh/gateway_detector.dart';
import 'package:mesh_app/models/emergency_message.dart';
import 'package:mesh_app/models/hq_notice.dart';
import 'package:mesh_app/proto/emergency_message.pb.dart' as pb;
import 'package:mesh_app/services/background_service.dart';
import 'package:mesh_app/services/gateway_uploader.dart';

import 'fake_mesh.dart';

/// Like the real backend: every upload creates an incident and a signed
/// DELIVERED receipt; GET /api/notices returns notices issued after `since`.
class FakeHqServer implements HttpClientAdapter {
  final List<(int, (Uint8List, Uint8List))> issued = []; // (server time, notice)
  final List<int> sinceSeen = [];
  int clock = 1000;

  void issue((Uint8List, Uint8List) n) => issued.add((clock++, n));

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    switch (o.path) {
      case '/api/health':
        return _json(200, {'status': 'ok'});
      case '/api/messages':
        final id = (o.data as Map)['messageId'] as String;
        issue(FakeHq.receipt(id));
        return _json(201, {'uploadId': 'u-$id', 'ackStatus': 'ACKNOWLEDGED'});
      case '/api/notices':
        final since = int.parse('${o.queryParameters['since']}');
        sinceSeen.add(since);
        final now = clock++;
        return _json(200, {
          'serverTimeMs': now,
          'notices': [
            for (final (t, (b, s)) in issued)
              if (t > since) {'noticeId': 'n$t', 'body': base64Encode(b), 'signature': base64Encode(s)},
          ],
        });
    }
    return _json(404, {});
  }

  ResponseBody _json(int status, Object json) => ResponseBody.fromString(jsonEncode(json), status,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // BackgroundService's method channel

  final nodes = <FakeNode>[];
  late FakeHqServer hq;
  late GatewayDetector gateway;

  setUp(() => hq = FakeHqServer());

  tearDown(() async {
    gateway.dispose();
    for (final n in nodes) {
      await n.dispose();
    }
    nodes.clear();
  });

  GatewayDetector gatewayOn(FakeNode c) => gateway = GatewayDetector(
        db: c.db,
        uploader: GatewayUploader(db: c.db, deviceId: c.localId),
        service: BackgroundService(),
        deliverNotice: c.relay.acceptFromHq,
        clientFactory: (s) => BackendClient(s,
            dio: Dio(BaseOptions(baseUrl: s.baseUrl, validateStatus: (_) => true))..httpClientAdapter = hq),
      );

  test('the gateway uploads, fetches the receipt, and the sender hears back', () async {
    final a = FakeNode('A'), b = FakeNode('B'), c = FakeNode('C');
    nodes.addAll([a, b, c]);
    link(a, b);
    link(b, c);
    final id = await createMessage(a, NeedType.medical);
    await settle(nodes);

    await gatewayOn(c).init(); // C is online: check -> upload -> fetch notices
    await settle(nodes);

    expect(gateway.deliveredTotal, 1);
    expect(gateway.noticesFetched, 1);
    final receipt = (await a.db.watchReceipts().first)[id];
    expect(receipt?.receiptState, ReceiptState.delivered, reason: 'two hops back to the sender');
    expect((await b.db.getMessage(id))!.status, MessageStatus.uploaded, reason: 'B stops carrying it');
  });

  test('later checks only ask for what is new, and pick up alerts', () async {
    final c = FakeNode('C'), d = FakeNode('D');
    nodes.addAll([c, d]);
    link(c, d);
    await gatewayOn(c).init();
    await settle(nodes);
    expect(hq.sinceSeen.first, 0);

    hq.issue(FakeHq.alert('Shelter open at City School', level: pb.AlertLevel.WARNING));
    await gateway.check();
    await settle(nodes);

    expect(hq.sinceSeen.last, greaterThan(0), reason: 'cursor from the previous serverTimeMs');
    final atD = await d.db.watchAlerts().first;
    expect(atD.single.title, 'Shelter open at City School');
    expect(atD.single.alertLevel, AlertLevel.warning);

    // Nothing new: the next check fetches nothing and floods nothing.
    final before = gateway.noticesFetched;
    await gateway.check();
    expect(gateway.noticesFetched, before);
  });
}
