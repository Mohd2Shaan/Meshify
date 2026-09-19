import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../mesh/mesh_permissions.dart';
import 'home_screen.dart';

/// Shows the home screen once every mesh permission is granted and Location
/// is on. Otherwise shows the setup checklist.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool? _ready;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ok = MeshPermissions.allGranted(await MeshPermissions.check()) &&
        await MeshPermissions.locationServiceOn();
    if (mounted) setState(() => _ready = ok);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_ready) {
      null => const Scaffold(body: Center(child: CircularProgressIndicator())),
      true => const HomeScreen(),
      false => SetupScreen(onReady: () => setState(() => _ready = true)),
    };
  }
}

/// Requests every permission the mesh needs (Phase 0 checkpoint).
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, required this.onReady});

  final VoidCallback onReady;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> with WidgetsBindingObserver {
  Map<Permission, PermissionStatus> _statuses = {};
  bool _locationOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-check when the user comes back from system settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
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

  @override
  Widget build(BuildContext context) {
    final ready = _statuses.isNotEmpty && MeshPermissions.allGranted(_statuses) && _locationOn;
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Mesh: Setup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'This app passes emergency alerts between phones over Bluetooth '
            'and Wi-Fi, with no internet needed. It needs these permissions to find '
            'nearby phones and attach your location.',
          ),
          const SizedBox(height: 8),
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
          if (!ready)
            FilledButton(onPressed: _request, child: const Text('Grant permissions')),
          if (_statuses.values.any((s) => s.isPermanentlyDenied))
            TextButton(
              onPressed: openAppSettings,
              child: const Text('Some permissions blocked: open settings'),
            ),
          if (ready)
            FilledButton.icon(
              onPressed: widget.onReady,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue'),
            ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.label, required this.ok, required this.detail});

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
