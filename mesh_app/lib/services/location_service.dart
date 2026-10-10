import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationUnavailable implements Exception {
  LocationUnavailable(this.reason);

  final String reason;

  @override
  String toString() => reason;
}

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude, {this.fromCache = false, this.age = Duration.zero});

  final double latitude;
  final double longitude;

  /// True when a fresh fix timed out and an earlier position was used.
  final bool fromCache;

  /// How old the position is (zero for a fresh fix).
  final Duration age;
}

/// A position and when it was taken.
class Fix {
  const Fix(this.latitude, this.longitude, this.at);

  final double latitude;
  final double longitude;
  final DateTime at;
}

/// FR-1: the phone's current GPS position.
///
/// GPS needs no internet, but without mobile data or Wi-Fi Android can't
/// speed it up with cell towers and Wi-Fi networks, so the first fix can take
/// a minute or more (longer indoors). An SOS must never fail just because of
/// that, so:
///  1. [warmUp] starts GPS when the app opens, so a fix is usually ready by
///     the time someone taps SEND;
///  2. [current] uses a recent fix at once, else waits up to [freshTimeout];
///  3. failing that, it falls back to the last known position (up to
///     [maxFallbackAge] old) and says how old it is.
class LocationService {
  static const freshTimeout = Duration(seconds: 45);
  static const recentEnough = Duration(minutes: 2);
  static const maxFallbackAge = Duration(hours: 12);
  static const warmUpFor = Duration(minutes: 5);

  Fix? _latest;
  StreamSubscription<Position>? _warm;
  Timer? _warmStop;

  /// Keeps GPS running for [warmUpFor] so a fix is ready when needed. Called
  /// when the app opens or comes back to the foreground. Silently does
  /// nothing without permission.
  Future<void> warmUp() async {
    _warmStop?.cancel();
    _warmStop = Timer(warmUpFor, _stopWarmUp);
    if (_warm != null) return;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
      _warm = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
      ).listen(_remember, onError: (_) => _stopWarmUp());
    } catch (_) {
      // Not available (e.g. tests); sending still works, just slower.
    }
  }

  void _stopWarmUp() {
    _warmStop?.cancel();
    _warm?.cancel();
    _warm = null;
  }

  void _remember(Position p) => _latest = Fix(p.latitude, p.longitude, p.timestamp);

  Future<GeoPoint> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationUnavailable('Location is switched off');
    }
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      throw LocationUnavailable('Location permission not granted');
    }
    final now = DateTime.now();
    final warm = _latest;
    if (warm != null && now.difference(warm.at) < recentEnough) {
      return GeoPoint(warm.latitude, warm.longitude);
    }
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: freshTimeout),
      );
      _remember(p);
      return GeoPoint(p.latitude, p.longitude);
    } catch (_) {
      Fix? lastKnown;
      try {
        final p = await Geolocator.getLastKnownPosition();
        if (p != null) lastKnown = Fix(p.latitude, p.longitude, p.timestamp);
      } catch (_) {}
      final best = pickFallback([_latest, lastKnown], now: now);
      if (best != null) return best;
      throw LocationUnavailable(
          'No GPS fix yet. Without internet the first fix can take a minute or two: '
          'go near a window or outside and try again');
    }
  }

  /// The newest of [fixes] that is at most [maxFallbackAge] old, or null.
  static GeoPoint? pickFallback(List<Fix?> fixes, {required DateTime now}) {
    Fix? best;
    for (final f in fixes) {
      if (f == null || now.difference(f.at) > maxFallbackAge) continue;
      if (best == null || f.at.isAfter(best.at)) best = f;
    }
    if (best == null) return null;
    return GeoPoint(best.latitude, best.longitude, fromCache: true, age: now.difference(best.at));
  }
}
