import 'package:flutter/material.dart';

import '../proto/emergency_message.pb.dart' as pb;

/// A notice from Headquarters, relayed through the mesh (see MeshFrame in the
/// .proto). Signed by HQ, so phones can trust it.
enum NoticeKind { receipt, alert }

/// What HQ has done with a message. Shown to the sender on the Messages tab.
enum ReceiptState {
  delivered('Delivered to HQ', Icons.done),
  acknowledged('Seen by responders', Icons.done_all),
  resolved('Resolved', Icons.verified);

  const ReceiptState(this.label, this.icon);

  final String label;
  final IconData icon;

  static ReceiptState? fromProto(pb.ReceiptStatus s) => switch (s) {
        pb.ReceiptStatus.DELIVERED => ReceiptState.delivered,
        pb.ReceiptStatus.ACKNOWLEDGED => ReceiptState.acknowledged,
        pb.ReceiptStatus.RESOLVED => ReceiptState.resolved,
        _ => null,
      };
}

enum AlertLevel {
  info('Info', Icons.info, Color(0xFF1565C0)),
  warning('Warning', Icons.warning_amber, Color(0xFFE65100)),
  critical('Critical', Icons.campaign, Color(0xFFB71C1C));

  const AlertLevel(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  static AlertLevel? fromProto(pb.AlertLevel l) => switch (l) {
        pb.AlertLevel.INFO => AlertLevel.info,
        pb.AlertLevel.WARNING => AlertLevel.warning,
        pb.AlertLevel.CRITICAL => AlertLevel.critical,
        _ => null,
      };
}
