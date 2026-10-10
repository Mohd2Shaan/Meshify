import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/models/emergency_message.dart';
import 'package:mesh_app/models/hq_notice.dart';
import 'package:mesh_app/proto/emergency_message.pb.dart' as pb;

import 'fake_mesh.dart';

/// HQ -> mesh notices: delivery receipts and broadcast alerts, flooded back
/// through the same relay as emergency messages.
void main() {
  final nodes = <FakeNode>[];
  FakeNode node(String id) {
    final n = FakeNode(id);
    nodes.add(n);
    return n;
  }

  tearDown(() async {
    for (final n in nodes) {
      await n.dispose();
    }
    nodes.clear();
  });

  Future<void> fromHq(FakeNode gateway, (Uint8List, Uint8List) n) =>
      gateway.relay.acceptFromHq(n.$1, n.$2);

  group('delivery receipts', () {
    test('a receipt from HQ reaches the sender two hops away', () async {
      final a = node('A'), b = node('B'), c = node('C');
      link(a, b);
      link(b, c);
      final id = await createMessage(a, NeedType.medical);
      await settle(nodes);

      // C is the gateway: it uploaded the message and fetched HQ's receipt.
      await fromHq(c, FakeHq.receipt(id, status: pb.ReceiptStatus.ACKNOWLEDGED, team: 'Medical Team Alpha'));
      await settle(nodes);

      final receipt = (await a.db.watchReceipts().first)[id]!;
      expect(receipt.receiptState, ReceiptState.acknowledged);
      expect(receipt.teamName, 'Medical Team Alpha');
      expect((await a.db.getMessage(id))!.status, MessageStatus.uploaded,
          reason: 'the sender knows it arrived');
    });

    test('relay phones stop carrying a message once its receipt arrives', () async {
      final a = node('A'), b = node('B'), c = node('C');
      link(a, b);
      final id = await createMessage(a, NeedType.trapped);
      await settle(nodes);
      expect((await b.db.getMessage(id))!.status, MessageStatus.relayed);

      // Another gateway delivered it; the receipt reaches B before B meets C.
      final receipt = FakeHq.receipt(id);
      b.inject('X', FakeHq.frame(receipt));
      await settle(nodes);
      expect((await b.db.getMessage(id))!.status, MessageStatus.uploaded);
      expect(b.relay.stats.deliveredElsewhere, 1);

      link(b, c);
      await settle(nodes);
      expect(await c.db.getMessage(id), isNull, reason: 'B no longer spends radio time on it');
      expect(await c.db.noticeExists(pb.HqNotice.fromBuffer(receipt.$1).noticeId), isTrue,
          reason: 'but passes the receipt on, so C stops carrying it too');
    });

    test('a newer receipt replaces an older one; only the newest is relayed', () async {
      final a = node('A'), b = node('B');
      final t = DateTime.now();
      final delivered = FakeHq.receipt('m1', issued: t);
      final resolved = FakeHq.receipt('m1', status: pb.ReceiptStatus.RESOLVED, issued: t.add(const Duration(minutes: 5)));
      await fromHq(a, resolved);
      await fromHq(a, delivered); // arrives late, out of order
      await settle(nodes);

      expect((await a.db.watchReceipts().first)['m1']!.receiptState, ReceiptState.resolved);

      link(a, b);
      await settle(nodes);
      expect(b.arrivals.where((x) => x.startsWith('r-m1')), hasLength(1));
      expect((await b.db.watchReceipts().first)['m1']!.receiptState, ReceiptState.resolved);
    });
  });

  group('broadcast alerts', () {
    test('an alert floods to every phone, store-carry-forward included', () async {
      final a = node('A'), b = node('B'), c = node('C'), d = node('D');
      link(a, b);
      link(b, c);
      final seenAtC = <String>[];
      c.relay.newAlerts.listen((n) => seenAtC.add(n.title!));

      await fromHq(a, FakeHq.alert('Evacuate North Zone'));
      await settle(nodes);
      expect(seenAtC, ['Evacuate North Zone']);

      link(c, d); // D turns up later
      await settle(nodes);
      final atD = await d.db.watchAlerts().first;
      expect(atD.single.title, 'Evacuate North Zone');
      expect(atD.single.alertLevel, AlertLevel.critical);
      expect(await d.db.watchUnseenAlertCount().first, 1);
    });

    test('duplicates are dropped and the notification fires once', () async {
      final a = node('A'), b = node('B'), c = node('C');
      link(a, b);
      link(b, c);
      link(a, c); // triangle
      var notified = 0;
      c.relay.newAlerts.listen((_) => notified++);

      await fromHq(a, FakeHq.alert('Shelter open'));
      await settle(nodes);
      expect(notified, 1);
      expect(await c.db.watchAlerts().first, hasLength(1));
    });
  });

  group('HQ signature', () {
    test('a forged alert is dropped and never relayed', () async {
      final a = node('A'), b = node('B');
      link(a, b);
      final (body, _) = FakeHq.alert('Fake evacuation');
      a.inject('Mallory', FakeHq.frame((body, Uint8List.fromList([1, 2, 3]))));
      await settle(nodes);

      expect(a.relay.stats.forgedDropped, 1);
      expect(await a.db.watchAlerts().first, isEmpty);
      expect(b.arrivals, isEmpty);
    });

    test('an altered notice fails the signature check', () async {
      final a = node('A');
      final (body, sig) = FakeHq.receipt('m1');
      final altered = Uint8List.fromList(body)..[body.length - 1] ^= 1;
      a.inject('Mallory', FakeHq.frame((altered, sig)));
      await settle(nodes);
      expect(a.relay.stats.forgedDropped, 1);
    });

    test('an expired notice is dropped', () async {
      final a = node('A');
      a.inject('B', FakeHq.frame(FakeHq.alert('Old', ttl: const Duration(seconds: -1))));
      await settle(nodes);
      expect(a.relay.stats.expiredDropped, 1);
      expect(await a.db.watchAlerts().first, isEmpty);
    });
  });
}
