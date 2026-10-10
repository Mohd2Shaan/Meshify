import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/app_database.dart';

/// Broadcasts from HQ responders, received through the mesh. Each one was
/// checked against HQ's signature before it was shown or passed on.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts from HQ')),
      body: StreamBuilder<List<StoredNotice>>(
        stream: db.watchAlerts(),
        builder: (context, snap) {
          final alerts = snap.data ?? const [];
          if (alerts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No alerts yet.\n\nWhen responders broadcast an alert, it reaches this '
                  'phone through the mesh, even with no internet here, as long as some '
                  'phone nearby can reach HQ.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [for (final a in alerts) AlertCard(a)],
          );
        },
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  const AlertCard(this.a, {super.key, this.compact = false});

  final StoredNotice a;

  /// Banner form for the Send screen: no footer.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final level = a.alertLevel!;
    final expired = !a.expiry.isAfter(DateTime.now());
    final color = expired ? Colors.grey : level.color;
    final theme = Theme.of(context);
    return Card(
      margin: compact ? EdgeInsets.zero : null,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 6))),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(level.icon, color: color),
              const SizedBox(width: 8),
              Text('HQ ${level.label.toUpperCase()}',
                  style: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(expired ? 'Expired' : _time(a.issuedAt), style: theme.textTheme.bodySmall),
            ]),
            const SizedBox(height: 8),
            Text(a.title!, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(a.body!, maxLines: compact ? 2 : null, overflow: compact ? TextOverflow.ellipsis : null),
            if (!compact) ...[
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.verified, size: 14, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text('Signed by HQ · ${expired ? 'no longer relayed' : _validFor(a.expiry)}',
                    style: theme.textTheme.bodySmall),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  static String _time(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  static String _validFor(DateTime expiry) {
    final d = expiry.difference(DateTime.now());
    if (d.inHours > 0) return 'valid ${d.inHours}h ${d.inMinutes % 60}m more';
    return 'valid ${d.inMinutes}m more';
  }
}
