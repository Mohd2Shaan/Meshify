import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/mesh/power_policy.dart';
import 'package:mesh_app/models/emergency_message.dart';

import 'fake_mesh.dart';

/// Battery-aware relaying: what a phone still relays as its battery drains.
void main() {
  group('automatic mode', () {
    test('thresholds', () {
      expect(PowerMode.auto(level: 80, charging: false), PowerMode.normal);
      expect(PowerMode.auto(level: 31, charging: false), PowerMode.normal);
      expect(PowerMode.auto(level: 30, charging: false), PowerMode.saver);
      expect(PowerMode.auto(level: 16, charging: false), PowerMode.saver);
      expect(PowerMode.auto(level: 15, charging: false), PowerMode.critical);
      expect(PowerMode.auto(level: 5, charging: true), PowerMode.normal, reason: 'charging');
    });

    test('what each mode relays for others', () {
      for (final t in NeedType.values) {
        expect(PowerMode.normal.relaysForOthers(t), isTrue);
        expect(PowerMode.critical.relaysForOthers(t), isFalse);
      }
      expect(PowerMode.saver.relaysForOthers(NeedType.medical), isTrue);
      expect(PowerMode.saver.relaysForOthers(NeedType.trapped), isTrue);
      expect(PowerMode.saver.relaysForOthers(NeedType.supplies), isFalse);
      expect(PowerMode.saver.relaysForOthers(NeedType.status), isFalse);
    });

    test('scan duty cycle gets sparser as the battery drains', () {
      expect(PowerMode.normal.discoveryDutyCycle, isNull);
      final (saverOn, saverOff) = PowerMode.saver.discoveryDutyCycle!;
      final (critOn, critOff) = PowerMode.critical.discoveryDutyCycle!;
      double share(Duration on, Duration off) => on.inSeconds / (on.inSeconds + off.inSeconds);
      expect(share(critOn, critOff), lessThan(share(saverOn, saverOff)));
    });
  });

  group('relay under battery modes', () {
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

    test('saver: B relays MEDICAL but holds back STATUS', () async {
      final a = node('A'), b = node('B'), c = node('C');
      link(a, b);
      link(b, c);
      b.relay.powerMode = PowerMode.saver;

      final medical = await createMessage(a, NeedType.medical);
      final status = await createMessage(a, NeedType.status);
      await settle(nodes);

      expect(await c.db.getMessage(medical), isNotNull);
      expect(await c.db.getMessage(status), isNull);
      expect(await b.db.getMessage(status), isNotNull, reason: 'still stored, so a gateway B could upload it');
      expect(b.relay.stats.powerSkipped, greaterThan(0));
    });

    test('critical: own SOS still goes out, nothing is relayed for others', () async {
      final a = node('A'), b = node('B'), c = node('C');
      link(a, b);
      link(b, c);
      b.relay.powerMode = PowerMode.critical;

      final fromB = await createMessage(b, NeedType.trapped);
      final fromA = await createMessage(a, NeedType.medical);
      await settle(nodes);

      expect(await c.db.getMessage(fromB), isNotNull, reason: "B's own SOS");
      expect(await c.db.getMessage(fromA), isNull);
    });

    test('critical: HQ alerts are still passed on', () async {
      final a = node('A'), b = node('B'), c = node('C');
      link(a, b);
      link(b, c);
      b.relay.powerMode = PowerMode.critical;

      final alert = FakeHq.alert('Evacuate');
      await a.relay.acceptFromHq(alert.$1, alert.$2);
      await settle(nodes);
      expect(await c.db.watchAlerts().first, hasLength(1));
    });

    test('when the battery recovers, held-back messages go out', () async {
      final a = node('A'), b = node('B'), c = node('C');
      link(a, b);
      link(b, c);
      b.relay.powerMode = PowerMode.critical;
      final id = await createMessage(a, NeedType.supplies);
      await settle(nodes);
      expect(await c.db.getMessage(id), isNull);

      b.relay.powerMode = PowerMode.normal; // e.g. plugged into a power bank
      await settle(nodes);
      expect((await c.db.getMessage(id))!.hopCount, 2);
    });
  });
}
