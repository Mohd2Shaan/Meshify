import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/db/app_database.dart';
import 'package:mesh_app/models/emergency_message.dart';
import 'package:mesh_app/models/hq_notice.dart';
import 'package:mesh_app/proto/emergency_message.pb.dart' as pb;

import 'fake_mesh.dart';

/// Relay phones shouldn't learn whose messages they carry, and nothing should
/// pile up on a phone forever.
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

  group('relay privacy', () {
    test("a relay's log never names the sender, the message or the neighbour", () async {
      final alice = node('alice-phone'), bob = node('bob-phone'), carol = node('carol-phone');
      link(alice, bob);
      link(bob, carol);
      final id = await createMessage(alice, NeedType.medical);
      await settle(nodes);
      expect(await carol.db.getMessage(id), isNotNull, reason: 'it was relayed');

      final log = bob.relay.log.join('\n');
      expect(log, contains('Medical relayed for someone else'));
      expect(log, contains('sealed'));
      for (final secret in ['alice', 'carol', id.substring(0, 8)]) {
        expect(log, isNot(contains(secret)), reason: 'bob should not learn "$secret"');
      }
    });

    test("the sender's own log still identifies its own message", () async {
      final alice = node('alice-phone'), bob = node('bob-phone');
      link(alice, bob);
      final id = await createMessage(alice, NeedType.trapped);
      await settle(nodes);
      expect(alice.relay.log.join('\n'), contains('your Trapped ${id.substring(0, 8)}'));
    });
  });

  group('3-day clean-up', () {
    test('deletes messages, notices and log rows that expired over 3 days ago', () async {
      final a = node('A'), b = node('B');
      link(a, b);
      final now = DateTime.now();
      final old = await createMessage(a, NeedType.status,
          now: now.subtract(const Duration(days: 4)), ttl: const Duration(hours: 6));
      final recent = await createMessage(a, NeedType.supplies,
          now: now.subtract(const Duration(days: 1)), ttl: const Duration(hours: 6));
      final live = await createMessage(a, NeedType.medical);
      await settle(nodes);
      await a.db.logRelay(old, 'B', RelayDirection.outbound, now.subtract(const Duration(days: 4)));
      await a.db.recordUpload(
          uploadId: 'u-old', messageId: old, gatewayDeviceId: 'A', at: now, ackStatus: 'ACKNOWLEDGED');
      final oldAlert = FakeHq.alert('Old', ttl: const Duration(days: 1));
      await a.db.insertNotice(NoticesCompanion.insert(
        noticeId: 'old-alert',
        kind: NoticeKind.alert,
        issuedAt: now.subtract(const Duration(days: 5)),
        expiry: now.subtract(const Duration(days: 4)),
        receivedAt: now.subtract(const Duration(days: 5)),
        signedBody: oldAlert.$1,
        signature: oldAlert.$2,
      ));

      await a.relay.pruneOld();

      expect(await a.db.getMessage(old), isNull);
      expect(await a.db.relayLogFor(old), isEmpty);
      expect(await a.db.uploadFor(old), isNull);
      expect(await a.db.getNotice('old-alert'), isNull);
      expect(await a.db.getMessage(recent), isNotNull, reason: 'expired only 1 day ago');
      expect(await a.db.getMessage(live), isNotNull, reason: 'still in progress');
      expect(await a.db.relayLogFor(live), isNotEmpty, reason: 'its log is still needed for dedup');
      expect(a.relay.log.where((l) => l.contains('CLEAN deleted')), isNotEmpty);
    });

    test('a deleted message that turns up again is still dropped (it has expired)', () async {
      final a = node('A');
      final t = DateTime.now().subtract(const Duration(days: 4));
      final packet = pb.MeshPacket(
        messageId: 'gone-1',
        senderDeviceId: 'X',
        type: pb.MessageType.MEDICAL,
        timestampMs: Int64(t.millisecondsSinceEpoch),
        ttlExpiryMs: Int64(t.add(const Duration(hours: 6)).millisecondsSinceEpoch),
        hopCount: 1,
        sealedPayload: [1, 2, 3],
      );
      a.inject('B', packet.writeToBuffer());
      await settle(nodes);
      expect(await a.db.getMessage('gone-1'), isNull);
      expect(a.relay.stats.expiredDropped, 1);
    });
  });
}
