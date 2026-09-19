import 'dart:async';

import 'package:flutter/widgets.dart';

import '../db/app_database.dart';
import '../models/emergency_message.dart';
import '../services/background_service.dart';
import 'mesh_permissions.dart';
import 'nearby_service.dart';

/// Decides when the mesh runs:
///
///   permissions granted + user hasn't switched it off  =>  relay, in the
///   background too, until a radio or permission is turned off.
///
/// Runs from main(), not from a screen, so it also works when the app was
/// started with no UI (after a reboot, or restarted by Android).
class MeshController extends ChangeNotifier with WidgetsBindingObserver {
  MeshController({
    required this.db,
    required this.nearby,
    required this.service,
  });

  final AppDatabase db;
  final NearbyService nearby;
  final BackgroundService service;

  static const _userOffKey = 'meshUserOff';

  bool _permissionsOk = false;
  bool _userOff = false;
  MeshHealthStatus _health = const MeshHealthStatus(true, []);
  int _carried = 0;
  StreamSubscription<List<StoredMessage>>? _storeSub;

  bool get permissionsOk => _permissionsOk;

  /// The user's on/off choice (Mesh tab switch).
  bool get enabled => !_userOff;
  MeshHealthStatus get health => _health;

  /// True when the user wants relaying but something is blocking it.
  bool get paused => enabled && _permissionsOk && !_health.ok;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    service.onHealthChanged = _onHealthChanged;
    nearby.addListener(_pushStatus);
    _storeSub = db.watchMessages().listen((rows) {
      _carried = rows
          .where((m) => m.status == MessageStatus.created || m.status == MessageStatus.relayed)
          .length;
      _pushStatus();
    });
    _userOff = await db.getSetting(_userOffKey) == '1';
    await refresh();
  }

  /// Re-evaluates permissions and radios. Called at start, on app resume,
  /// and after the setup screen grants permissions.
  Future<void> refresh() async {
    _permissionsOk = MeshPermissions.allGranted(await MeshPermissions.check());
    _health = await service.health();
    await _apply();
  }

  Future<void> setEnabled(bool on) async {
    _userOff = !on;
    await db.setSetting(_userOffKey, on ? null : '1');
    await _apply();
  }

  Future<void> _apply() async {
    final shouldRun = enabled && _permissionsOk;
    if (shouldRun) {
      await service.start();
      if (_health.ok && !nearby.isRunning) await nearby.start();
      if (!_health.ok && nearby.isRunning) await nearby.stop();
    } else {
      if (nearby.isRunning) await nearby.stop();
      await service.stop();
    }
    notifyListeners();
  }

  void _onHealthChanged(MeshHealthStatus h) {
    _health = h;
    unawaited(_apply());
  }

  void _pushStatus() {
    unawaited(service.updateStatus(peers: nearby.connectedPeers.length, carried: _carried));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    nearby.removeListener(_pushStatus);
    _storeSub?.cancel();
    super.dispose();
  }
}
