import 'package:flutter/services.dart';

class MeshHealthStatus {
  const MeshHealthStatus(this.ok, this.problems);

  /// False when something blocks relaying (permission, Bluetooth, Location).
  final bool ok;

  /// Human-readable, e.g. "Bluetooth is off". May include non-blocking
  /// warnings such as Wi-Fi being off.
  final List<String> problems;

  static MeshHealthStatus fromMap(Object? raw) {
    final m = (raw as Map?) ?? const {};
    return MeshHealthStatus(
      m['ok'] as bool? ?? true,
      [for (final p in (m['problems'] as List?) ?? const []) p as String],
    );
  }
}

/// Dart side of the Android foreground service (MeshForegroundService.kt)
/// that keeps relaying alive in the background (SRS 2.3).
class BackgroundService {
  BackgroundService() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'healthChanged':
          onHealthChanged?.call(MeshHealthStatus.fromMap(call.arguments));
        case 'internetChanged':
          onInternetChanged?.call(call.arguments as bool? ?? false);
      }
    });
  }

  static const _channel = MethodChannel('emergency_mesh/service');

  /// Called when Bluetooth / Location / Wi-Fi is switched on or off.
  void Function(MeshHealthStatus)? onHealthChanged;

  /// Called when Android reports internet gained (true) or lost (false).
  /// FR-8 re-checks the backend straight away instead of waiting for its timer.
  void Function(bool validated)? onInternetChanged;

  /// Starts the service (idempotent). False if Android refused.
  Future<bool> start() async => await _call<bool>('start') ?? false;

  Future<void> stop() => _call('stop');

  /// Shows "Gateway: uploading to HQ" in the service notification.
  Future<void> setGateway(bool isGateway) => _call('setGateway', {'gateway': isGateway});

  Future<MeshHealthStatus> health() async =>
      MeshHealthStatus.fromMap(await _call<Map>('health'));

  Future<void> updateStatus({required int peers, required int carried}) =>
      _call('updateStatus', {'peers': peers, 'carried': carried});

  /// Battery level (0-100) and whether it is charging. Null off Android.
  Future<({int level, bool charging})?> battery() async {
    final m = await _call<Map>('battery');
    if (m == null) return null;
    return (level: (m['level'] as int?) ?? 100, charging: (m['charging'] as bool?) ?? false);
  }

  /// Heads-up notification for an HQ broadcast alert.
  Future<void> showHqAlert({
    required String id,
    required String level,
    required String title,
    required String body,
  }) =>
      _call('showHqAlert', {'id': id, 'level': level, 'title': title, 'body': body});

  Future<bool> isIgnoringBatteryOptimizations() async =>
      await _call<bool>('isIgnoringBatteryOptimizations') ?? true;

  Future<void> requestIgnoreBatteryOptimizations() =>
      _call('requestIgnoreBatteryOptimizations');

  /// Swallows MissingPluginException so widget tests and non-Android
  /// platforms don't crash.
  Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    }
  }
}
