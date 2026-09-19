import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/config.dart';
import 'package:mesh_app/models/emergency_message.dart';
import 'package:mesh_app/proto/emergency_message.pb.dart' as pb;

import 'fake_mesh.dart';

void main() {
  final nodes = <FakeNode>[];
  FakeNode node(String id, {MeshConfig? config, DateTime Function()? clock}) {
    final n = FakeNode(id, config: config, clock: clock);
    nodes.add(n);
    return n;
  }

  tearDown(() async {
    for (final n in nodes) {
      await n.dispose();
    }
    nodes.clear();
  });

  group('FR-4 multi-hop relay', () {
    test('A -> B -> C: C receives a message from A it was never in range of', () async {
      final a = node('A'), b = node('B'), c = node('C');
      link(a, b);
      link(b, c); // A and C never linked
      await settle(nodes);

      final id = await createMessage(a, NeedType.medical);
      await settle(nodes);

      final atB = await b.db.getMessage(id);
      final atC = await c.db.getMessage(id);
      expect(atB!.hopCount, 1);
      expect(atC!.hopCount, 2);
      expect(atC.status, MessageStatus.relayed);
      expect(atC.latitude, isNull, reason: 'relay phones never store readable content');
      expect(atC.senderDeviceId, 'A');
    });

    test('store-carry-forward: B carries a message from A to C across a gap', () async {
      final a = node('A'), b = node('B'), c = node('C');
      final id = await createMessage(a, NeedType.trapped); // A alone
      await settle(nodes);
      expect(await b.db.getMessage(id), isNull);

      link(a, b); // B walks past A
      await settle(nodes);
      expect(await b.db.getMessage(id), isNotNull);

      unlink(a, b);
      link(b, c); // B later meets C
      await settle(nodes);
      expect((await c.db.getMessage(id))!.hopCount, 2);
    });
  });

  group('FR-5 deduplication', () {
    test('triangle: C gets the message twice but stores and relays it once', () async {
      final a = node('A'), b = node('B'), c = node('C');
      link(a, b);
      link(b, c);
      link(a, c);
      await settle(nodes);

      final id = await createMessage(a, NeedType.medical);
      await settle(nodes);

      // Everyone has exactly one copy, and the flood terminated.
      for (final n in [b, c]) {
        expect(await n.db.getMessage(id), isNotNull);
      }
      final totalDupes = b.relay.stats.duplicates + c.relay.stats.duplicates;
      final totalForwarded = nodes.fold(0, (s, n) => s + n.relay.stats.forwarded);
      expect(totalForwarded, lessThanOrEqualTo(4), reason: 'bounded, not flooding forever');
      expect(totalDupes, lessThanOrEqualTo(2));
    });

    test('never sends a message back to the phone it came from', () async {
      final a = node('A'), b = node('B');
      link(a, b);
      await settle(nodes);
      final id = await createMessage(a, NeedType.supplies);
      await settle(nodes);

      expect(a.arrivals, isNot(contains(id)));
      expect(b.relay.stats.forwarded, 0);
    });

    test('reconnecting peers do not resend what was already exchanged', () async {
      final a = node('A'), b = node('B');
      link(a, b);
      await createMessage(a, NeedType.medical);
      await settle(nodes);
      final sentBefore = a.relay.stats.forwarded;

      unlink(a, b);
      link(a, b);
      await settle(nodes);
      expect(a.relay.stats.forwarded, sentBefore);
    });
  });

  group('FR-6 TTL and hop limit', () {
    Uint8List packet({required int ttlMs, int hops = 0, String id = 'x1'}) => pb.MeshPacket(
          messageId: id,
          senderDeviceId: 'Z',
          type: pb.MessageType.MEDICAL,
          timestampMs: Int64(DateTime.now().millisecondsSinceEpoch),
          ttlExpiryMs: Int64(DateTime.now().millisecondsSinceEpoch + ttlMs),
          hopCount: hops,
          sealedPayload: [1, 2, 3],
        ).writeToBuffer();

    test('an already-expired packet is dropped, not stored', () async {
      final b = node('B');
      b.inject('Z', packet(ttlMs: -1000));
      await settle(nodes);
      expect(await b.db.getMessage('x1'), isNull);
      expect(b.relay.stats.expiredDropped, 1);
    });

    test('a packet over the hop limit is dropped', () async {
      final b = node('B', config: MeshConfig(maxHops: 3));
      b.inject('Z', packet(ttlMs: 60000, hops: 3)); // arrives as hop 4
      await settle(nodes);
      expect(await b.db.getMessage('x1'), isNull);
      expect(b.relay.stats.hopLimitDropped, 1);
    });

    test('at the hop limit a message is kept (can still be uploaded) but not forwarded', () async {
      final config = MeshConfig(maxHops: 1);
      final a = node('A', config: config), b = node('B', config: config), c = node('C', config: config);
      link(a, b);
      link(b, c);
      await settle(nodes);
      final id = await createMessage(a, NeedType.medical);
      await settle(nodes);

      expect((await b.db.getMessage(id))!.hopCount, 1);
      expect(await c.db.getMessage(id), isNull);
    });

    test('a carried message expires in the store and is no longer offered', () async {
      var now = DateTime(2026, 9, 20, 12);
      final a = node('A', clock: () => now), b = node('B', clock: () => now);
      final id = await createMessage(a, NeedType.status, ttl: const Duration(minutes: 2), now: now);

      now = now.add(const Duration(minutes: 3));
      await a.relay.sweepExpired();
      expect((await a.db.getMessage(id))!.status, MessageStatus.expired);

      link(a, b);
      await settle(nodes);
      expect(await b.db.getMessage(id), isNull);
    });
  });

  group('FR-7 priority under congestion', () {
    Future<List<String>> run({required bool fifo}) async {
      final config = MeshConfig(sendInterval: const Duration(milliseconds: 30));
      final a = node('A-$fifo', config: config), b = node('B-$fifo', config: config);
      a.relay.fifoMode = fifo;
      link(a, b);
      await settle([a, b]);
      final ids = <String>[];
      for (var i = 0; i < 6; i++) {
        ids.add(await createMessage(a, NeedType.status));
      }
      final medical = await createMessage(a, NeedType.medical);
      await settle([a, b], quiet: const Duration(milliseconds: 300));
      expect(b.arrivals, hasLength(7));
      return [...b.arrivals.map((x) => x == medical ? 'MEDICAL' : 'status')];
    }

    test('MEDICAL overtakes queued STATUS messages; FIFO leaves it last', () async {
      final prioritized = await run(fifo: false);
      final fifo = await run(fifo: true);
      // With priority, MEDICAL goes out right after whatever was already on
      // the air. With FIFO it waits behind all six.
      expect(prioritized.indexOf('MEDICAL'), lessThanOrEqualTo(1));
      expect(fifo.indexOf('MEDICAL'), 6);
    });
  });

  test('malformed bytes are ignored without crashing', () async {
    final b = node('B');
    b.inject('Z', Uint8List.fromList([0xff, 0xff, 0xff]));
    b.inject('Z', pb.MeshPacket(messageId: 'no-payload').writeToBuffer());
    await settle(nodes);
    expect(b.relay.stats.malformed, 2);
  });
}
