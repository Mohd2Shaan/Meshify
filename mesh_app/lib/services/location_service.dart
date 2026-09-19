import 'package:geolocator/geolocator.dart';

class LocationUnavailable implements Exception {
  LocationUnavailable(this.reason);

  final String reason;

  @override
  String toString() => reason;
}

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude, {this.fromCache = false});

  final double latitude;
  final double longitude;

  /// True when a fresh fix timed out and the last known position was used.
  final bool fromCache;
}

/// FR-1: the phone's current GPS position. GPS needs no internet, but a
/// cold fix indoors can be slow, so a recent last-known fix is accepted.
class LocationService {
  static const _freshTimeout = Duration(seconds: 15);
  static const _maxCacheAge = Duration(minutes: 30);

  Future<GeoPoint> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationUnavailable('Location is switched off');
    }
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      throw LocationUnavailable('Location permission not granted');
    }
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _freshTimeout,
        ),
      );
      return GeoPoint(p.latitude, p.longitude);
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && DateTime.now().difference(last.timestamp) < _maxCacheAge) {
        return GeoPoint(last.latitude, last.longitude, fromCache: true);
      }
      throw LocationUnavailable('No GPS fix yet. Move near a window or outside and try again');
    }
  }
}
