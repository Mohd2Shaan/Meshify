import 'dart:async';

import 'package:flutter/foundation.dart';

import '../db/app_database.dart';
import '../mesh/power_policy.dart';
import 'background_service.dart';

/// Picks the battery mode (power_policy.dart) and applies it to the relay
/// and the radio. Automatic by default; the Mesh tab can force a mode, which
/// is also how the feature is demonstrated without draining a phone.
class PowerManager extends ChangeNotifier {
  PowerManager({
    required this.db,
    required this.service,
    required this.onModeChanged,
    this.pollInterval = const Duration(minutes: 1),
  });

  final AppDatabase db;
  final BackgroundService service;

  /// Applies a mode: sets RelayManager.powerMode and the discovery duty cycle.
  final void Function(PowerMode mode) onModeChanged;
  final Duration pollInterval;

  static const _forcedKey = 'powerModeOverride';

  int? _level;
  bool _charging = false;
  PowerMode? _forced;
  PowerMode _mode = PowerMode.normal;
  Timer? _timer;

  /// Null until read (or when not on Android).
  int? get batteryLevel => _level;
  bool get charging => _charging;

  /// Null = automatic.
  PowerMode? get forcedMode => _forced;
  PowerMode get mode => _mode;

  Future<void> init() async {
    final saved = await db.getSetting(_forcedKey);
    _forced = PowerMode.values.where((m) => m.name == saved).firstOrNull;
    await refresh();
    _timer = Timer.periodic(pollInterval, (_) => unawaited(refresh()));
  }

  Future<void> refresh() async {
    final b = await service.battery();
    if (b != null) {
      _level = b.level;
      _charging = b.charging;
    }
    _apply();
  }

  /// Forces a mode, or back to automatic with null.
  Future<void> setForcedMode(PowerMode? mode) async {
    _forced = mode;
    await db.setSetting(_forcedKey, mode?.name);
    _apply();
  }

  void _apply() {
    final level = _level;
    final next = _forced ??
        (level == null ? PowerMode.normal : PowerMode.auto(level: level, charging: _charging));
    if (next != _mode) {
      _mode = next;
      onModeChanged(next);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
