import 'package:drift/drift.dart' show Value;

import '../config.dart';
import '../crypto/message_crypto.dart';
import '../db/app_database.dart';
import '../mesh/priority.dart';
import '../mesh/relay_manager.dart';
import '../models/emergency_message.dart';
import '../proto/emergency_message.pb.dart' as pb;
import 'location_service.dart';

class InvalidMessage implements Exception {
  InvalidMessage(this.reason);

  final String reason;

  @override
  String toString() => reason;
}

class SendResult {
  SendResult(this.message, this.peersQueued, this.usedCachedLocation, {this.locationAge = Duration.zero});

  final StoredMessage message;
  final int peersQueued;
  final bool usedCachedLocation;

  /// How old the location was, when [usedCachedLocation].
  final Duration locationAge;
}

/// DFD processes 1.0 (Create & Validate) and 2.0 (Encrypt), then hands off
/// to 3.0 (Relay):
///   FR-1 need type + automatic GPS
///   FR-2 validate, assign messageId/timestamp/TTL, save to Message Store
///   FR-3 seal the private content before it can reach the mesh
class EmergencySender {
  EmergencySender({
    required this.db,
    required this.relay,
    required this.crypto,
    required this.location,
    required this.deviceId,
    required this.config,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final AppDatabase db;
  final RelayManager relay;
  final MessageCrypto crypto;
  final LocationService location;
  final String deviceId;
  final MeshConfig config;
  final DateTime Function() _now;

  Future<SendResult> send(NeedType type, {String? note}) async {
    final trimmed = note?.trim();
    if (trimmed != null && trimmed.length > MeshConfig.maxNoteLength) {
      throw InvalidMessage('Note is longer than ${MeshConfig.maxNoteLength} characters');
    }
    final pos = await location.current(); // throws LocationUnavailable
    if (pos.latitude.abs() > 90 || pos.longitude.abs() > 180) {
      throw InvalidMessage('GPS returned invalid coordinates');
    }

    final now = _now();
    final expiry = now.add(config.defaultTtl);
    final id = newId();
    final sealed = await crypto.seal(pb.EmergencyPayload(
      latitude: pos.latitude,
      longitude: pos.longitude,
      note: trimmed ?? '',
    ).writeToBuffer());

    await db.insertMessage(MessagesCompanion.insert(
      messageId: id,
      senderDeviceId: deviceId,
      type: type,
      latitude: Value(pos.latitude),
      longitude: Value(pos.longitude),
      note: Value(trimmed?.isEmpty ?? true ? null : trimmed),
      timestamp: now,
      ttlExpiry: expiry,
      hopCount: 0,
      priorityScore: priorityScore(
          type: type, createdAt: now, ttlExpiry: expiry, hopCount: 0, now: now),
      status: MessageStatus.created,
      sealedPayload: sealed,
      receivedAt: now,
    ));

    final peers = await relay.originate(id);
    return SendResult((await db.getMessage(id))!, peers, pos.fromCache, locationAge: pos.age);
  }
}
