import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../crypto/message_crypto.dart';
import '../mesh/gateway_detector.dart';
import '../mesh/mesh_controller.dart';
import '../mesh/nearby_service.dart';
import '../mesh/power_policy.dart';
import '../mesh/relay_manager.dart';
import '../services/power_manager.dart';

/// Nearby Devices screen (SRS 3.3): active mesh connections, relay
/// statistics, and the relay/connection logs used as test evidence.
class NearbyDevicesScreen extends StatefulWidget {
  const NearbyDevicesScreen({super.key});

  @override
  State<NearbyDevicesScreen> createState() => _NearbyDevicesScreenState();
}

class _NearbyDevicesScreenState extends State<NearbyDevicesScreen> {
  @override
  Widget build(BuildContext context) {
    final mesh = context.watch<NearbyService>();
    final controller = context.watch<MeshController>();
    final relay = context.watch<RelayManager>();
    final config = context.read<MeshConfig>();
    final crypto = context.read<MessageCrypto>();
    final s = relay.stats;
    return Scaffold(
      appBar: AppBar(title: const Text('Mesh')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(children: [
              SwitchListTile(
                title: Text('Mesh active · this phone: ${mesh.localId}'),
                subtitle: Text(switch ((controller.enabled, mesh.isRunning)) {
                  (false, _) => 'Off: this phone is invisible and relays nothing',
                  (true, true) => 'Relaying, also in the background · crypto: ${crypto.mode}',
                  (true, false) =>
                    'Paused: ${controller.health.problems.firstOrNull ?? 'starting…'}',
                }),
                value: controller.enabled,
                onChanged: controller.setEnabled,
              ),
            ]),
          ),
          const _Header('Peers'),
          if (mesh.peers.isEmpty) const ListTile(title: Text('No peers yet')),
          for (final p in mesh.peers)
            ListTile(
              dense: true,
              leading: Icon(
                p.state == PeerState.connected ? Icons.link : Icons.bluetooth_searching,
                color: p.state == PeerState.connected ? Colors.green : null,
              ),
              title: Text(p.name),
              trailing: Text(p.state.name),
            ),
          const _Header('Gateway (FR-8, FR-9)'),
          const _GatewayCard(),
          const _Header('Battery-aware relaying'),
          const _PowerCard(),
          const _Header('Relay statistics'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _Stat('received', s.received),
            _Stat('forwarded', s.forwarded),
            _Stat('duplicates dropped', s.duplicates),
            _Stat('expired dropped', s.expiredDropped + s.expiredInStore),
            _Stat('hop-limit dropped', s.hopLimitDropped),
            _Stat('malformed', s.malformed),
            _Stat('queue', relay.queueLength),
            _Stat('HQ notices received', s.noticesReceived),
            _Stat('forged notices dropped', s.forgedDropped),
            _Stat('stopped: HQ has it', s.deliveredElsewhere),
            _Stat('skipped to save battery', s.powerSkipped),
          ]),
          const _Header('Test settings'),
          SwitchListTile(
            dense: true,
            title: const Text('Short TTL (2 min) for new messages'),
            subtitle: const Text('FR-6 test: watch a message expire and stop relaying'),
            value: config.defaultTtl == MeshConfig.testTtl,
            onChanged: (on) => setState(() =>
                config.defaultTtl = on ? MeshConfig.testTtl : MeshConfig.normalTtl),
          ),
          ListTile(
            dense: true,
            title: const Text('Max hops'),
            subtitle: const Text('FR-6: messages stop being forwarded after this many hops'),
            trailing: DropdownButton<int>(
              value: config.maxHops,
              items: const [1, 2, 3, 5, 10]
                  .map((h) => DropdownMenuItem(value: h, child: Text('$h')))
                  .toList(),
              onChanged: (h) => setState(() => config.maxHops = h!),
            ),
          ),
          const _Header('Relay log'),
          if (relay.log.isEmpty) const Text('Nothing relayed yet'),
          for (final line in relay.log.take(100)) _LogLine(line),
          const _Header('Connection log'),
          for (final line in mesh.log.take(100)) _LogLine(line),
        ],
      ),
    );
  }
}

class _GatewayCard extends StatelessWidget {
  const _GatewayCard();

  @override
  Widget build(BuildContext context) {
    final gw = context.watch<GatewayDetector>();
    final run = gw.lastRun;
    final checked = gw.lastCheck == null
        ? 'not checked yet'
        : 'checked ${gw.lastCheck!.toLocal().toString().substring(11, 19)}';
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(gw.isGateway ? Icons.cloud_done : Icons.cloud_off,
                color: gw.isGateway ? Colors.green : Colors.grey),
            title: Text(gw.isGateway
                ? 'This phone is a GATEWAY: HQ reachable'
                : 'Not a gateway: HQ not reachable'),
            subtitle: Text('${gw.settings.baseUrl} · $checked\n'
                'Delivered to HQ from this phone: ${gw.deliveredTotal}'
                ' · receipts/alerts brought into the mesh: ${gw.noticesFetched}'
                '${run?.stoppedBecause != null ? '\nLast upload stopped: ${run!.stoppedBecause}' : ''}'),
            isThreeLine: true,
            trailing: gw.isUploading ? const CircularProgressIndicator() : null,
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => _editSettings(context, gw), child: const Text('Settings')),
              TextButton(onPressed: gw.check, child: const Text('Check / upload now')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editSettings(BuildContext context, GatewayDetector gw) async {
    final url = TextEditingController(text: gw.settings.baseUrl);
    final key = TextEditingController(text: gw.settings.apiKey);
    final save = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Backend (HQ) settings'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
                labelText: 'Backend URL', hintText: 'http://192.168.137.1:8080'),
          ),
          TextField(controller: key, decoration: const InputDecoration(labelText: 'Gateway API key')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (save == true) await gw.updateSettings(url.text, key.text);
    url.dispose();
    key.dispose();
  }
}

class _PowerCard extends StatelessWidget {
  const _PowerCard();

  @override
  Widget build(BuildContext context) {
    final power = context.watch<PowerManager>();
    final scanPaused = context.select<NearbyService, bool>((n) => n.scanPaused);
    final level = power.batteryLevel;
    final battery = level == null
        ? 'Battery level unknown'
        : 'Battery $level%${power.charging ? ', charging' : ''}';
    final mode = power.mode;
    final color = switch (mode) {
      PowerMode.normal => Colors.green,
      PowerMode.saver => Colors.orange,
      PowerMode.critical => Colors.red,
    };
    return Card(
      child: Column(children: [
        ListTile(
          leading: Icon(
            mode == PowerMode.normal ? Icons.battery_full : Icons.battery_saver,
            color: color,
          ),
          title: Text('${mode.label}${power.forcedMode == null ? ' (auto)' : ' (forced)'}'),
          subtitle: Text('$battery\n${mode.description}'
              '${scanPaused ? '\nScan paused right now to save battery' : ''}'),
          isThreeLine: true,
        ),
        ListTile(
          dense: true,
          title: const Text('Mode'),
          subtitle: Text('Auto: saver at ${PowerMode.saverBelow}% or less, '
              'critical at ${PowerMode.criticalBelow}% or less'),
          trailing: DropdownButton<PowerMode?>(
            value: power.forcedMode,
            items: [
              const DropdownMenuItem(value: null, child: Text('Auto')),
              for (final m in PowerMode.values) DropdownMenuItem(value: m, child: Text(m.label)),
            ],
            onChanged: power.setForcedMode,
          ),
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'), visualDensity: VisualDensity.compact);
  }
}

class _LogLine extends StatelessWidget {
  const _LogLine(this.line);

  final String line;

  @override
  Widget build(BuildContext context) {
    return Text(line, style: const TextStyle(fontFamily: 'monospace', fontSize: 11));
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
