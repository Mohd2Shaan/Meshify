import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_app/services/location_service.dart';

/// Offline, a fresh GPS fix can time out. An SOS should still go out with the
/// best earlier position rather than fail.
void main() {
  final now = DateTime(2026, 10, 10, 12);

  test('uses the newest earlier fix and reports its age', () {
    final p = LocationService.pickFallback([
      Fix(13.0, 80.0, now.subtract(const Duration(hours: 2))),
      Fix(13.1, 80.1, now.subtract(const Duration(minutes: 40))),
    ], now: now)!;
    expect(p.latitude, 13.1);
    expect(p.fromCache, isTrue);
    expect(p.age, const Duration(minutes: 40));
  });

  test('a fix older than 30 minutes is still used (it used to be refused)', () {
    final p = LocationService.pickFallback([Fix(13.0, 80.0, now.subtract(const Duration(hours: 3)))], now: now);
    expect(p, isNotNull);
  });

  test('nothing usable: no fix at all, or only very old ones', () {
    expect(LocationService.pickFallback([null, null], now: now), isNull);
    expect(
      LocationService.pickFallback(
          [Fix(13.0, 80.0, now.subtract(LocationService.maxFallbackAge + const Duration(minutes: 1)))], now: now),
      isNull,
    );
  });
}
