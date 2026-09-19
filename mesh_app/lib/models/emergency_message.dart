import 'package:flutter/material.dart';

import '../proto/emergency_message.pb.dart' as pb;

/// FR-1 need types. Order and names match MessageType in the .proto file
/// and the backend enum.
enum NeedType {
  medical('Medical', Icons.medical_services, Color(0xFFD32F2F)),
  trapped('Trapped', Icons.warning_amber, Color(0xFFE65100)),
  supplies('Supplies', Icons.inventory_2, Color(0xFF1565C0)),
  status('Status', Icons.info_outline, Color(0xFF546E7A));

  const NeedType(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  pb.MessageType toProto() => switch (this) {
        NeedType.medical => pb.MessageType.MEDICAL,
        NeedType.trapped => pb.MessageType.TRAPPED,
        NeedType.supplies => pb.MessageType.SUPPLIES,
        NeedType.status => pb.MessageType.STATUS,
      };

  /// Null for MESSAGE_TYPE_UNSPECIFIED or unknown values (invalid packet).
  static NeedType? fromProto(pb.MessageType t) => switch (t) {
        pb.MessageType.MEDICAL => NeedType.medical,
        pb.MessageType.TRAPPED => NeedType.trapped,
        pb.MessageType.SUPPLIES => NeedType.supplies,
        pb.MessageType.STATUS => NeedType.status,
        _ => null,
      };

  /// Backend enum name (UploadRequest.type).
  String get apiName => name.toUpperCase();
}

/// Lifecycle of a message in this phone's local Message Store (D1).
enum MessageStatus {
  /// Created on this phone, being carried.
  created,

  /// Received from another phone, being carried.
  relayed,

  /// Delivered to the backend by a gateway (FR-9). No longer forwarded.
  uploaded,

  /// TTL passed (FR-6). No longer forwarded or uploaded.
  expired,
}

enum RelayDirection { inbound, outbound }
