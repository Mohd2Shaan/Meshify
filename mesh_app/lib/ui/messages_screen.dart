import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/app_database.dart';
import '../models/emergency_message.dart';
import '../models/hq_notice.dart';

/// The local Message Store (D1): what this phone created or is carrying.
///
/// For its own messages, the sender also sees HQ's latest delivery receipt:
/// delivered, seen by responders (and which team), resolved.
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
          return StreamBuilder<Map<String, StoredNotice>>(
            stream: db.watchReceipts(),
            builder: (context, receipts) => ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) => _MessageTile(
                m: rows[i],
                mine: rows[i].senderDeviceId == deviceId,
                receipt: receipts.data?[rows[i].messageId],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.m, required this.mine, this.receipt});

  final StoredMessage m;
  final bool mine;

  /// HQ's latest receipt for this message, if one has reached this phone.
  final StoredNotice? receipt;

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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$content\n'
              'hop ${m.hopCount} · ${_expiresIn(m.ttlExpiry)} · id ${m.messageId.substring(0, 8)}'),
          if (mine) _ReceiptLine(receipt: receipt, status: m.status),
        ],
      ),
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

/// What HQ has told the sender so far, e.g. "Seen by responders · Medical Team Alpha".
class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({required this.receipt, required this.status});

  final StoredNotice? receipt;
  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    final r = receipt;
    final (IconData icon, Color color, String text) = switch (r?.receiptState) {
      ReceiptState.resolved => (ReceiptState.resolved.icon, Colors.green.shade800, 'Resolved by responders'),
      ReceiptState.acknowledged => (ReceiptState.acknowledged.icon, Colors.green.shade700, ReceiptState.acknowledged.label),
      ReceiptState.delivered => (ReceiptState.delivered.icon, Colors.green.shade700, ReceiptState.delivered.label),
      null when status == MessageStatus.expired => (Icons.schedule, Colors.grey, 'Expired before HQ confirmed it'),
      null => (Icons.schedule, Colors.orange.shade800, 'Waiting for HQ to confirm'),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            [text, if (r?.teamName != null) 'Team: ${r!.teamName}'].join(' · '),
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
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
      MessageStatus.rejected => Colors.brown,
    };
    return Chip(
      label: Text(status == MessageStatus.uploaded ? 'delivered' : status.name,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }
}
