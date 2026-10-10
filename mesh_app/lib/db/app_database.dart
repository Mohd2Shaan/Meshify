import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/emergency_message.dart';
import '../models/hq_notice.dart';

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

/// D3 GatewayUpload (ER: GatewayUpload). One row per message this phone
/// delivered to the backend as a gateway (FR-9).
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

/// Notices from HQ (delivery receipts, broadcast alerts) this phone holds and
/// relays. [signedBody] and [signature] are kept byte-for-byte as HQ signed
/// them, so they can be passed on unchanged; the other columns are the
/// decoded content for display.
@DataClassName('StoredNotice')
class Notices extends Table {
  TextColumn get noticeId => text()();
  TextColumn get kind => textEnum<NoticeKind>()();

  /// Receipts: which message, what happened to it, and the team (if any).
  TextColumn get messageId => text().nullable()();
  TextColumn get receiptState => textEnum<ReceiptState>().nullable()();
  TextColumn get teamName => text().nullable()();

  /// Alerts.
  TextColumn get alertLevel => textEnum<AlertLevel>().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get body => text().nullable()();

  DateTimeColumn get issuedAt => dateTime()();
  DateTimeColumn get expiry => dateTime()();
  DateTimeColumn get receivedAt => dateTime()();
  BlobColumn get signedBody => blob()();
  BlobColumn get signature => blob()();

  /// A newer receipt for the same message exists, so this one isn't relayed.
  BoolColumn get superseded => boolean().withDefault(const Constant(false))();

  /// Alerts: the user has opened the Alerts tab since it arrived.
  BoolColumn get seen => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {noticeId};
}

/// Local key/value settings (this phone's deviceId).
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Messages, RelayLog, GatewayUploads, AppSettings, Notices])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'emergency_mesh'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(notices); // v2: HQ receipts and alerts
        },
      );

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

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  /// Stores [value], or deletes the key when [value] is null.
  Future<void> setSetting(String key, String? value) async {
    if (value == null) {
      await (delete(appSettings)..where((s) => s.key.equals(key))).go();
    } else {
      await into(appSettings)
          .insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));
    }
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

  /// FR-9: what a gateway should upload, most urgent first. Includes messages
  /// at the hop limit, which can't be relayed further but can still reach HQ.
  Future<List<StoredMessage>> pendingUploads(DateTime now) {
    return (select(messages)
          ..where((m) =>
              m.status.isInValues([MessageStatus.created, MessageStatus.relayed]) &
              m.ttlExpiry.isBiggerThanValue(now))
          ..orderBy([(m) => OrderingTerm.desc(m.priorityScore)]))
        .get();
  }

  // ---- D3 GatewayUpload --------------------------------------------------------

  Future<void> recordUpload({
    required String uploadId,
    required String messageId,
    required String gatewayDeviceId,
    required DateTime at,
    required String ackStatus,
  }) {
    return into(gatewayUploads).insertOnConflictUpdate(GatewayUploadsCompanion.insert(
      uploadId: uploadId,
      messageId: messageId,
      gatewayDeviceId: gatewayDeviceId,
      uploadTimestamp: at,
      backendAckStatus: ackStatus,
    ));
  }

  Future<GatewayUploadEntry?> uploadFor(String messageId) =>
      (select(gatewayUploads)..where((u) => u.messageId.equals(messageId))..limit(1))
          .getSingleOrNull();

  // ---- HQ notices (receipts, alerts) -------------------------------------------

  Future<StoredNotice?> getNotice(String id) =>
      (select(notices)..where((n) => n.noticeId.equals(id))).getSingleOrNull();

  Future<bool> noticeExists(String id) async => await getNotice(id) != null;

  /// Stores a verified notice. A receipt replaces any older receipt for the
  /// same message (only the newest is relayed); an out-of-date one arriving
  /// late is stored as superseded, so it still counts as seen for FR-5.
  Future<void> insertNotice(NoticesCompanion n) => transaction(() async {
        final messageId = n.messageId.present ? n.messageId.value : null;
        var row = n;
        if (n.kind.value == NoticeKind.receipt && messageId != null) {
          final newer = await (select(notices)
                ..where((o) =>
                    o.messageId.equals(messageId) &
                    o.kind.equalsValue(NoticeKind.receipt) &
                    o.issuedAt.isBiggerOrEqualValue(n.issuedAt.value))
                ..limit(1))
              .getSingleOrNull();
          if (newer != null) {
            row = n.copyWith(superseded: const Value(true));
          } else {
            await (update(notices)
                  ..where((o) =>
                      o.messageId.equals(messageId) & o.kind.equalsValue(NoticeKind.receipt)))
                .write(const NoticesCompanion(superseded: Value(true)));
          }
        }
        await into(notices).insert(row);
      });

  /// Notices this phone should still pass on.
  Future<List<StoredNotice>> forwardableNotices(DateTime now) {
    return (select(notices)
          ..where((n) => n.expiry.isBiggerThanValue(now) & n.superseded.equals(false)))
        .get();
  }

  /// Latest receipt per message, for the sender's Messages tab.
  Stream<Map<String, StoredNotice>> watchReceipts() {
    return (select(notices)
          ..where((n) => n.kind.equalsValue(NoticeKind.receipt) & n.superseded.equals(false)))
        .watch()
        .map((rows) => {for (final r in rows) r.messageId!: r});
  }

  Stream<List<StoredNotice>> watchAlerts() {
    return (select(notices)
          ..where((n) => n.kind.equalsValue(NoticeKind.alert))
          ..orderBy([(n) => OrderingTerm.desc(n.issuedAt)]))
        .watch();
  }

  Stream<int> watchUnseenAlertCount() {
    final count = notices.noticeId.count();
    return (selectOnly(notices)
          ..addColumns([count])
          ..where(notices.kind.equalsValue(NoticeKind.alert) & notices.seen.equals(false)))
        .map((r) => r.read(count) ?? 0)
        .watchSingle();
  }

  Future<void> markAlertsSeen() =>
      (update(notices)..where((n) => n.kind.equalsValue(NoticeKind.alert) & n.seen.equals(false)))
          .write(const NoticesCompanion(seen: Value(true)));

  // ---- Clean-up --------------------------------------------------------------

  /// Deletes what can no longer matter: messages and notices that expired
  /// before [cutoff], then the relay-log and upload rows that pointed at them.
  ///
  /// Safe for deduplication (FR-5): a copy of a deleted message or notice
  /// that turns up again has long expired, so the TTL check drops it anyway.
  Future<PruneResult> pruneExpiredBefore(DateTime cutoff) => transaction(() async {
        final msgs = await (delete(messages)..where((m) => m.ttlExpiry.isSmallerThanValue(cutoff))).go();
        final nts = await (delete(notices)..where((n) => n.expiry.isSmallerThanValue(cutoff))).go();
        final keptMessages = selectOnly(messages)..addColumns([messages.messageId]);
        final keptNotices = selectOnly(notices)..addColumns([notices.noticeId]);
        final logs = await (delete(relayLog)
              ..where((r) => r.messageId.isNotInQuery(keptMessages) & r.messageId.isNotInQuery(keptNotices)))
            .go();
        final ups = await (delete(gatewayUploads)..where((u) => u.messageId.isNotInQuery(keptMessages))).go();
        return PruneResult(msgs, nts, logs + ups);
      });

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

class PruneResult {
  const PruneResult(this.messages, this.notices, this.logRows);

  final int messages;
  final int notices;
  final int logRows;

  int get total => messages + notices + logRows;
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
