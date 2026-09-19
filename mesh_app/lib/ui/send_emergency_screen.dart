import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../mesh/nearby_service.dart';
import '../models/emergency_message.dart';
import '../services/emergency_sender.dart';
import '../services/location_service.dart';

/// Send Emergency screen (SRS 3.3), FR-1.
///
/// Two taps (SRS 3.2 usability): tap a need type, then SEND. The note is
/// optional and can be skipped.
class SendEmergencyScreen extends StatelessWidget {
  const SendEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final peers = context.watch<NearbyService>().connectedPeers.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Emergency'),
        actions: [
          IconButton(
            tooltip: 'What do the buttons mean?',
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MeshStatusBanner(peers: peers),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  for (final t in NeedType.values)
                    _NeedButton(type: t, onTap: () => _confirm(context, t)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, NeedType type) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ConfirmSheet(type: type),
    );
    if (note == null || !context.mounted) return; // cancelled
    await _send(context, type, note);
  }

  Future<void> _send(BuildContext context, NeedType type, String note) async {
    final sender = context.read<EmergencySender>();
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Expanded(child: Text('Getting your location…')),
        ]),
      ),
    );
    String result;
    try {
      final r = await sender.send(type, note: note);
      result = '${type.label} alert saved. '
          '${r.peersQueued == 0 ? 'No phones nearby yet: it will be passed on as soon as one connects.' : 'Sending to ${r.peersQueued} nearby phone(s).'}'
          '${r.usedCachedLocation ? ' (Used your last known location.)' : ''}';
    } on LocationUnavailable catch (e) {
      result = 'Not sent: $e';
    } on InvalidMessage catch (e) {
      result = 'Not sent: $e';
    }
    if (context.mounted) Navigator.of(context).pop(); // progress dialog
    messenger.showSnackBar(SnackBar(content: Text(result), duration: const Duration(seconds: 6)));
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('How this works'),
        content: const SingleChildScrollView(
          child: Text(
            'No internet needed. Your alert hops from phone to phone over '
            'Bluetooth/Wi-Fi until one of them has internet, then it reaches '
            'rescue teams with your location.\n\n'
            'MEDICAL: someone is injured or ill.\n'
            'TRAPPED: you or others cannot get out.\n'
            'SUPPLIES: you need water, food or medicine.\n'
            'STATUS: you are safe (routine update).\n\n'
            'Your location and note are encrypted. Phones that pass the alert '
            'on cannot read them.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _MeshStatusBanner extends StatelessWidget {
  const _MeshStatusBanner({required this.peers});

  final int peers;

  @override
  Widget build(BuildContext context) {
    final ok = peers > 0;
    return Card(
      color: ok ? Colors.green.shade50 : Colors.orange.shade50,
      child: ListTile(
        leading: Icon(ok ? Icons.hub : Icons.bluetooth_searching,
            color: ok ? Colors.green : Colors.orange),
        title: Text(ok ? '$peers phone(s) connected' : 'Looking for nearby phones…'),
        subtitle: Text(ok
            ? 'Alerts you send will start relaying immediately'
            : 'You can still send: the alert is kept and passed on later'),
      ),
    );
  }
}

class _NeedButton extends StatelessWidget {
  const _NeedButton({required this.type, required this.onTap});

  final NeedType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: type.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, size: 56, color: Colors.white),
            const SizedBox(height: 8),
            Text(type.label.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ConfirmSheet extends StatefulWidget {
  const _ConfirmSheet({required this.type});

  final NeedType type;

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.type;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(t.icon, color: t.color, size: 32),
            const SizedBox(width: 12),
            Text('Send ${t.label.toUpperCase()} alert?',
                style: Theme.of(context).textTheme.titleLarge),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            maxLength: MeshConfig.maxNoteLength,
            decoration: const InputDecoration(
              labelText: 'Short note (optional)',
              hintText: 'e.g. 2 people, one with a leg injury',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: t.color),
              onPressed: () => Navigator.pop(context, _note.text),
              icon: const Icon(Icons.send),
              label: const Text('SEND', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
