import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/app_database.dart';
import '../models/emergency_message.dart';

/// The local Message Store (D1): what this phone created or is carrying.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<List<StoredMessage>>(
        stream: db.watchMessages(),
        builder: (context, snap) {
          final rows = snap.data ?? const [];
          if (rows.isEmpty) {
            return const Center(child: Text('No messages created or carried yet'));
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _MessageTile(m: rows[i], mine: rows[i].senderDeviceId == deviceId),
          );
        },
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.m, required this.mine});

  final StoredMessage m;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final content = mine
        ? '${m.latitude!.toStringAsFixed(5)}, ${m.longitude!.toStringAsFixed(5)}'
            '${m.note != null ? ' · "${m.note}"' : ''}'
        : 'Content sealed (${m.sealedPayload.length} bytes). Only HQ can read it';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: m.type.color,
        child: Icon(m.type.icon, color: Colors.white),
      ),
      title: Text('${m.type.label} · ${mine ? 'created here' : 'from ${m.senderDeviceId}'}'),
      subtitle: Text('$content\n'
          'hop ${m.hopCount} · ${_expiresIn(m.ttlExpiry)} · id ${m.messageId.substring(0, 8)}'),
      isThreeLine: true,
      trailing: _StatusChip(m.status),
      onTap: () => _showRelayLog(context),
    );
  }

  String _expiresIn(DateTime expiry) {
    final d = expiry.difference(DateTime.now());
    if (d.isNegative) return 'TTL passed';
    if (d.inHours > 0) return 'expires in ${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return 'expires in ${d.inMinutes}m';
    return 'expires in ${d.inSeconds}s';
  }

  Future<void> _showRelayLog(BuildContext context) async {
    final log = await context.read<AppDatabase>().relayLogFor(m.messageId);
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Relay log · ${m.messageId.substring(0, 8)}'),
        content: SizedBox(
          width: double.maxFinite,
          child: log.isEmpty
              ? const Text('Not relayed yet')
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final r in log)
                      ListTile(
                        dense: true,
                        leading: Icon(r.direction == RelayDirection.inbound
                            ? Icons.call_received
                            : Icons.call_made),
                        title: Text(r.direction == RelayDirection.inbound
                            ? 'Received from ${r.relayDeviceId}'
                            : 'Sent to ${r.relayDeviceId}'),
                        subtitle: Text(r.relayTimestamp.toLocal().toString().substring(0, 19)),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MessageStatus.created => Colors.blue,
      MessageStatus.relayed => Colors.teal,
      MessageStatus.uploaded => Colors.green,
      MessageStatus.expired => Colors.grey,
    };
    return Chip(
      label: Text(status.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }
}
