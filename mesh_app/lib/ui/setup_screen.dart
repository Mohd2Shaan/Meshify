import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

import '../mesh/mesh_permissions.dart';
import 'nearby_devices_screen.dart';

/// Phase 0 checkpoint screen: requests every permission the mesh needs and
/// confirms the nearby_connections plugin can actually talk to Play Services.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  Map<Permission, PermissionStatus> _statuses = {};
  bool _locationOn = false;
  String _pluginResult = 'Not tested yet';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final statuses = await MeshPermissions.check();
    final locationOn = await MeshPermissions.locationServiceOn();
    if (!mounted) return;
    setState(() {
      _statuses = statuses;
      _locationOn = locationOn;
    });
  }

  Future<void> _request() async {
    await MeshPermissions.request();
    await _refresh();
  }

  /// Starts and immediately stops advertising. Success proves the plugin's
  /// platform channel, Play Services Nearby, and the granted permissions all work.
  Future<void> _testPlugin() async {
    setState(() => _pluginResult = 'Testing...');
    try {
      final ok = await Nearby().startAdvertising(
        'phase0-test',
        Strategy.P2P_CLUSTER,
        serviceId: 'com.emergencymesh.mesh_app',
        onConnectionInitiated: (_, _) {},
        onConnectionResult: (_, _) {},
        onDisconnected: (_) {},
      );
      await Nearby().stopAdvertising();
      setState(() => _pluginResult = ok
          ? 'OK: advertising started and stopped'
          : 'FAILED: startAdvertising returned false');
    } catch (e) {
      setState(() => _pluginResult = 'FAILED: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final allGranted =
        _statuses.isNotEmpty && MeshPermissions.allGranted(_statuses);
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Mesh: Setup')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final p in MeshPermissions.required)
              _StatusTile(
                label: MeshPermissions.labels[p]!,
                ok: _statuses[p]?.isGranted ?? false,
                detail: _statuses[p]?.name ?? '...',
              ),
            _StatusTile(
              label: 'Location service switched on',
              ok: _locationOn,
              detail: _locationOn ? 'on' : 'off',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _request,
              child: const Text('Request permissions'),
            ),
            if (_statuses.values.any((s) => s.isPermanentlyDenied))
              TextButton(
                onPressed: openAppSettings,
                child: const Text('Some permissions blocked: open settings'),
              ),
            const Divider(height: 32),
            FilledButton.tonal(
              onPressed: allGranted && _locationOn ? _testPlugin : null,
              child: const Text('Test Nearby plugin'),
            ),
            const SizedBox(height: 8),
            Text(_pluginResult, textAlign: TextAlign.center),
            const Divider(height: 32),
            FilledButton.icon(
              onPressed: allGranted && _locationOn
                  ? () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const NearbyDevicesScreen()))
                  : null,
              icon: const Icon(Icons.hub),
              label: const Text('Open mesh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile(
      {required this.label, required this.ok, required this.detail});

  final String label;
  final bool ok;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(ok ? Icons.check_circle : Icons.cancel,
          color: ok ? Colors.green : Colors.red),
      title: Text(label),
      trailing: Text(detail),
    );
  }
}
