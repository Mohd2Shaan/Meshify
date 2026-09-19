import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/emergency_message.dart';

part 'app_database.g.dart';

/// D1 Message Store (ER: Message).
///
/// latitude/longitude/note are only filled on the phone that created the
/// message. Relay phones can't read them (FR-3). They carry sealedPayload.
@DataClassName('StoredMessage')
class Messages extends Table {
  TextColumn get messageId => text()();
  TextColumn get senderDeviceId => text()();
  TextColumn get type => textEnum<NeedType>()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get ttlExpiry => dateTime()();
  IntColumn get hopCount => integer()();
  RealColumn get priorityScore => real()();
  TextColumn get status => textEnum<MessageStatus>()();
  BlobColumn get sealedPayload => blob()();
  DateTimeColumn get receivedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {messageId};
}

/// D2 RelayLog (ER: RelayLog). One row per hop this phone took part in.
///
/// relayDeviceId is the phone at the other end of the hop. direction says
/// whether the message came in from it or went out to it. That lets FR-5
/// avoid sending a message back where it came from, or to the same phone twice.
@DataClassName('RelayLogEntry')
@TableIndex(name: 'relay_log_msg_peer', columns: {#messageId, #relayDeviceId})
class RelayLog extends Table {
  TextColumn get relayId => text()();
  TextColumn get messageId => text()();
  TextColumn get relayDeviceId => text()();
  TextColumn get direction => textEnum<RelayDirection>()();
  DateTimeColumn get relayTimestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {relayId};
}

/// D3 GatewayUpload (ER: GatewayUpload). Filled in Phase 7 (FR-9).
@DataClassName('GatewayUploadEntry')
class GatewayUploads extends Table {
  TextColumn get uploadId => text()();
  TextColumn get messageId => text()();
  TextColumn get gatewayDeviceId => text()();
  DateTimeColumn get uploadTimestamp => dateTime()();
  TextColumn get backendAckStatus => text()();

  @override
  Set<Column> get primaryKey => {uploadId};
}

/// Local key/value settings (this phone's deviceId).
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Messages, RelayLog, GatewayUploads, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'emergency_mesh'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // ---- Device identity -----------------------------------------------------

  /// This phone's permanent Device.deviceId, created on first launch.
  Future<String> getOrCreateDeviceId() async {
    const key = 'deviceId';
    final row = await (select(appSettings)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    if (row != null) return row.value;
    final id = newId().substring(0, 8);
    await into(appSettings).insert(AppSettingsCompanion.insert(key: key, value: id));
    return id;
  }

  // ---- D1 Message Store ------------------------------------------------------

  Future<void> insertMessage(MessagesCompanion m) => into(messages).insert(m);

  Future<StoredMessage?> getMessage(String id) =>
      (select(messages)..where((m) => m.messageId.equals(id))).getSingleOrNull();

  Future<bool> messageExists(String id) async => await getMessage(id) != null;

  /// Messages this phone should still pass on: carried, not expired, and
  /// under the hop limit (FR-6).
  Future<List<StoredMessage>> forwardableMessages(DateTime now, int maxHops) {
    return (select(messages)
          ..where((m) =>
              m.status.isInValues([MessageStatus.created, MessageStatus.relayed]) &
              m.ttlExpiry.isBiggerThanValue(now) &
              m.hopCount.isSmallerThanValue(maxHops)))
        .get();
  }

  Future<void> updatePriority(String id, double score) =>
      (update(messages)..where((m) => m.messageId.equals(id)))
          .write(MessagesCompanion(priorityScore: Value(score)));

  Future<void> setStatus(String id, MessageStatus status) =>
      (update(messages)..where((m) => m.messageId.equals(id)))
          .write(MessagesCompanion(status: Value(status)));

  /// FR-6: marks every carried message whose TTL has passed as expired.
  Future<int> expireOld(DateTime now) {
    return (update(messages)
          ..where((m) =>
              m.status.isInValues([MessageStatus.created, MessageStatus.relayed]) &
              m.ttlExpiry.isSmallerOrEqualValue(now)))
        .write(const MessagesCompanion(status: Value(MessageStatus.expired)));
  }

  Stream<List<StoredMessage>> watchMessages() {
    return (select(messages)
          ..orderBy([
            (m) => OrderingTerm.desc(m.receivedAt),
          ]))
        .watch();
  }

  // ---- D2 RelayLog -------------------------------------------------------------

  Future<void> logRelay(
      String messageId, String peerDeviceId, RelayDirection direction, DateTime at) {
    return into(relayLog).insert(RelayLogCompanion.insert(
      relayId: newId(),
      messageId: messageId,
      relayDeviceId: peerDeviceId,
      direction: direction,
      relayTimestamp: at,
    ));
  }

  /// FR-5: true if this message already crossed the link to/from [peerDeviceId].
  Future<bool> hasExchanged(String messageId, String peerDeviceId) async {
    final row = await (select(relayLog)
          ..where((r) =>
              r.messageId.equals(messageId) & r.relayDeviceId.equals(peerDeviceId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<List<RelayLogEntry>> relayLogFor(String messageId) =>
      (select(relayLog)..where((r) => r.messageId.equals(messageId))).get();
}

/// Random UUID v4 string.
String newId() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}
