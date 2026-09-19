import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mesh/nearby_service.dart';

/// Nearby Devices screen (SRS 3.3): active mesh connections.
///
/// Phase 1 also uses it as the raw-connectivity test bench: send a plain
/// string to every connected phone and show what arrives.
class NearbyDevicesScreen extends StatefulWidget {
  const NearbyDevicesScreen({super.key});

  @override
  State<NearbyDevicesScreen> createState() => _NearbyDevicesScreenState();
}

class _NearbyDevicesScreenState extends State<NearbyDevicesScreen> {
  final _text = TextEditingController(text: 'hello');
  final List<String> _received = [];
  StreamSubscription<ReceivedPayload>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = context.read<NearbyService>().incoming.listen((p) {
      setState(() => _received.insert(
          0, '${p.senderName}: ${utf8.decode(p.bytes, allowMalformed: true)}'));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _text.dispose();
    super.dispose();
  }

  Future<void> _send(NearbyService mesh) async {
    final msg = _text.text.trim();
    if (msg.isEmpty) return;
    final n = await mesh.broadcast(Uint8List.fromList(utf8.encode(msg)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent to $n peer${n == 1 ? '' : 's'}')));
  }

  @override
  Widget build(BuildContext context) {
    final mesh = context.watch<NearbyService>();
    final connected = mesh.connectedPeers;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Devices'),
        actions: [
          Center(
              child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text('Me: ${mesh.localId}'),
          )),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Mesh active'),
            subtitle: Text(mesh.isRunning
                ? 'Advertising + discovering'
                : 'Off: this phone is invisible'),
            value: mesh.isRunning,
            onChanged: (on) => on ? mesh.start() : mesh.stop(),
          ),
          const _Header('Peers'),
          if (mesh.peers.isEmpty)
            const ListTile(title: Text('No peers yet')),
          for (final p in mesh.peers)
            ListTile(
              dense: true,
              leading: Icon(
                p.state == PeerState.connected
                    ? Icons.link
                    : Icons.bluetooth_searching,
                color: p.state == PeerState.connected ? Colors.green : null,
              ),
              title: Text(p.name),
              trailing: Text(p.state.name),
            ),
          const _Header('Send text to all connected peers'),
          Row(children: [
            Expanded(child: TextField(controller: _text)),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: connected.isEmpty ? null : () => _send(mesh),
              child: const Text('Send'),
            ),
          ]),
          const _Header('Received'),
          if (_received.isEmpty)
            const ListTile(title: Text('Nothing received yet')),
          for (final r in _received) ListTile(dense: true, title: Text(r)),
          const _Header('Connection log'),
          for (final line in mesh.log)
            Text(line,
                style:
                    const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
