import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/mesh/priority.dart';
import 'package:mesh_app/models/emergency_message.dart';

void main() {
  final t0 = DateTime(2026, 9, 20, 12);
  final expiry = t0.add(const Duration(hours: 6));

  double score(NeedType type, {Duration age = Duration.zero, int hops = 0}) => priorityScore(
      type: type, createdAt: t0, ttlExpiry: expiry, hopCount: hops, now: t0.add(age));

  test('severity order: medical > trapped > supplies > status', () {
    expect(score(NeedType.medical), greaterThan(score(NeedType.trapped)));
    expect(score(NeedType.trapped), greaterThan(score(NeedType.supplies)));
    expect(score(NeedType.supplies), greaterThan(score(NeedType.status)));
  });

  test('an old, far-travelled STATUS never outranks a fresh MEDICAL', () {
    expect(score(NeedType.status, age: const Duration(hours: 6)),
        lessThan(score(NeedType.medical, hops: 10)));
  });

  test('within a type, older messages rise and far-travelled ones fall', () {
    expect(score(NeedType.supplies, age: const Duration(hours: 3)), greaterThan(score(NeedType.supplies)));
    expect(score(NeedType.supplies, hops: 3), lessThan(score(NeedType.supplies)));
  });
}
