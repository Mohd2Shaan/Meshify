import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/app_database.dart';
import '../models/emergency_message.dart';
import '../models/hq_notice.dart';

/// This phone's own messages, with HQ's latest delivery receipt for each:
/// delivered, seen by responders (and which team), resolved.
///
/// Messages it carries for other people are not listed (no type, sender or
/// id), only counted: a relay phone has no business knowing who asked for
/// help. Their content is sealed for HQ anyway.
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
          final rows = snap.data ?? const <StoredMessage>[];
          final mine = rows.where((m) => m.senderDeviceId == deviceId).toList();
          final carrying = rows
              .where((m) =>
                  m.senderDeviceId != deviceId &&
                  (m.status == MessageStatus.created || m.status == MessageStatus.relayed))
              .length;
          return StreamBuilder<Map<String, StoredNotice>>(
            stream: db.watchReceipts(),
            builder: (context, receipts) => ListView(
              children: [
                if (carrying > 0) _CarryingCard(count: carrying),
                if (mine.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text("You haven't sent any messages yet", textAlign: TextAlign.center),
                  ),
                for (final m in mine) ...[
                  _MessageTile(m: m, receipt: receipts.data?[m.messageId]),
                  const Divider(height: 1),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// How many sealed messages this phone is carrying for other people.
class _CarryingCard extends StatelessWidget {
  const _CarryingCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: ListTile(
        leading: const Icon(Icons.lock, color: Colors.teal),
        title: Text('Carrying $count sealed message${count == 1 ? '' : 's'} for others'),
        subtitle: const Text('Only HQ can read them. This phone just passes them on.'),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.m, this.receipt});

  final StoredMessage m;

  /// HQ's latest receipt for this message, if one has reached this phone.
  final StoredNotice? receipt;

  @override
  Widget build(BuildContext context) {
    final content = '${m.latitude!.toStringAsFixed(5)}, ${m.longitude!.toStringAsFixed(5)}'
        '${m.note != null ? ' · "${m.note}"' : ''}';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: m.type.color,
        child: Icon(m.type.icon, color: Colors.white),
      ),
      title: Text(m.type.label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$content\n'
              'hop ${m.hopCount} · ${_expiresIn(m.ttlExpiry)} · id ${m.messageId.substring(0, 8)}'),
          _ReceiptLine(receipt: receipt, status: m.status),
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
