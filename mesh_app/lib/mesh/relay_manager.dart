import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';

import '../config.dart';
import '../crypto/notice_verifier.dart';
import '../db/app_database.dart';
import '../models/emergency_message.dart';
import '../models/hq_notice.dart';
import '../proto/emergency_message.pb.dart' as pb;
import 'mesh_transport.dart';
import 'power_policy.dart';
import 'priority.dart';

class RelayStats {
  int received = 0;
  int duplicates = 0;
  int expiredDropped = 0;
  int hopLimitDropped = 0;
  int malformed = 0;
  int forwarded = 0;
  int expiredInStore = 0;

  /// HQ receipts and alerts accepted (signature checked).
  int noticesReceived = 0;

  /// Notices dropped because HQ's signature didn't verify: forged or altered.
  int forgedDropped = 0;

  /// Carried messages this phone stopped relaying because a receipt said HQ
  /// already has them.
  int deliveredElsewhere = 0;

  /// Sends skipped by battery saver / critical mode.
  int powerSkipped = 0;
}

class _Outgoing {
  _Outgoing(this.peer, this.id, this.score, this.seq, {this.notice = false});

  final MeshPeer peer;

  /// messageId, or noticeId when [notice].
  final String id;
  final double score;
  final int seq;
  final bool notice;

  String get key => '${peer.deviceId}|$id';
}

/// Process 3.0 "Relay via Mesh" (DFD Level 2), i.e. FR-4 to FR-7:
///
///   3.1 Check Duplicate (FR-5)   -> Message Store + RelayLog
///   3.2 Validate TTL / hops (FR-6)
///   3.3 Update Priority Score (FR-7) -> Message Store
///   3.4 Broadcast to Nearby Peers (FR-4), highest priority first
///   3.5 Log Relay Event -> RelayLog
///
/// Store-carry-forward (epidemic routing): every carried message is also
/// offered to each newly connected peer, so it can cross gaps in the mesh
/// by being physically carried.
///
/// The same flood also carries HQ notices back the other way: delivery
/// receipts for senders, and broadcast alerts for everyone. Each is checked
/// against HQ's signature before it is stored or passed on.
///
/// Privacy: the relay log never names other people's messages or the phones
/// they came from. A relay phone sees only "a sealed Medical message passed
/// through". Old data is deleted [MeshConfig.retention] after it expires.
class RelayManager extends ChangeNotifier {
  RelayManager({
    required this.db,
    required this.transport,
    required this.verifier,
    MeshConfig? config,
    DateTime Function()? clock,
  })  : config = config ?? MeshConfig(),
        _now = clock ?? DateTime.now;

  final AppDatabase db;
  final MeshTransport transport;
  final NoticeVerifier verifier;
  final MeshConfig config;
  final DateTime Function() _now;

  /// Source name used in the relay log for notices fetched straight from HQ.
  static const hqSource = 'HQ';

  final RelayStats stats = RelayStats();
  final List<String> _log = [];
  final Set<String> _queued = {};
  late PriorityQueue<_Outgoing> _queue = PriorityQueue(_compare);
  int _seq = 0;
  bool _fifo = false;
  PowerMode _power = PowerMode.normal;
  bool _pumping = false;
  bool _disposed = false;
  Future<void> _serial = Future.value();
  final List<StreamSubscription<dynamic>> _subs = [];
  final _newAlerts = StreamController<StoredNotice>.broadcast();
  Timer? _expiryTimer;
  Timer? _pruneTimer;

  List<String> get log => List.unmodifiable(_log);
  int get queueLength => _queue.length;

  /// Alerts as they arrive (first copy only), for the phone notification.
  Stream<StoredNotice> get newAlerts => _newAlerts.stream;

  /// Phase 4 baseline: when true the queue ignores priority (plain FIFO,
  /// like Bridgefy) so the two can be compared under congestion.
  bool get fifoMode => _fifo;
  set fifoMode(bool v) {
    _fifo = v;
    final items = _queue.toList();
    _queue = PriorityQueue(_compare)..addAll(items);
    notifyListeners();
  }

  /// Battery-aware relaying (see power_policy.dart). When the mode becomes
  /// less strict, everything held back is offered to current peers again.
  PowerMode get powerMode => _power;
  set powerMode(PowerMode mode) {
    if (mode == _power) return;
    final relaxed = mode.index < _power.index;
    _power = mode;
    _addLog('POWER ${mode.label}: ${mode.description}');
    if (relaxed) {
      for (final peer in transport.connectedMeshPeers) {
        unawaited(_run(() => _offerStoreTo(peer)));
      }
    }
  }

  int _compare(_Outgoing a, _Outgoing b) {
    if (!_fifo) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
    }
    return a.seq.compareTo(b.seq);
  }

  void start() {
    _subs.add(transport.incoming.listen((p) => _run(() => _handleIncoming(p))));
    _subs.add(transport.peerConnected.listen((p) => _run(() => _offerStoreTo(p))));
    _expiryTimer =
        Timer.periodic(const Duration(seconds: 15), (_) => _run(sweepExpired));
    unawaited(_run(pruneOld));
    _pruneTimer = Timer.periodic(const Duration(hours: 1), (_) => _run(pruneOld));
  }

  /// Runs [task] after every earlier task, so two copies of the same message
  /// arriving together can't both pass the duplicate check.
  Future<void> _run(Future<void> Function() task) {
    final next = _serial.then((_) => task()).catchError((Object e) {
      _addLog('ERROR $e');
    });
    _serial = next;
    return next;
  }

  /// FR-4: a message just created on this phone. Queues it for every
  /// connected peer, and returns how many that is.
  Future<int> originate(String messageId) async {
    var count = 0;
    await _run(() async {
      final m = await db.getMessage(messageId);
      if (m == null) return;
      for (final peer in transport.connectedMeshPeers) {
        if (_enqueueMessage(peer, m)) count++;
      }
      _addLog('NEW ${_short(messageId)} ${m.type.label} queued for $count peer(s)');
    });
    unawaited(_pump());
    return count;
  }

  /// A gateway hands over a notice it fetched from HQ. Returns true if it was
  /// new (and is now being flooded into the mesh).
  Future<bool> acceptFromHq(Uint8List body, Uint8List signature) async {
    var isNew = false;
    await _run(() async => isNew = await _handleNotice(hqSource, body, signature));
    unawaited(_pump());
    return isNew;
  }

  /// Store-carry-forward: offer everything we carry to a new neighbour.
  Future<void> _offerStoreTo(MeshPeer peer) async {
    final now = _now();
    var count = 0;
    for (final n in await db.forwardableNotices(now)) {
      if (await db.hasExchanged(n.noticeId, peer.deviceId)) continue;
      if (_enqueueNotice(peer, n)) count++;
    }
    for (final m in await db.forwardableMessages(now, config.maxHops)) {
      if (await db.hasExchanged(m.messageId, peer.deviceId)) continue;
      if (_enqueueMessage(peer, m)) count++;
    }
    if (count > 0) _addLog('PEER connected: offering $count carried item(s)');
    unawaited(_pump());
  }

  Future<void> _handleIncoming(ReceivedPayload p) async {
    // A notice arrives wrapped in a MeshFrame; an emergency message is a bare
    // MeshPacket, which reads as a frame without a notice (see the .proto).
    try {
      final frame = pb.MeshFrame.fromBuffer(p.bytes);
      if (frame.hasNotice()) {
        await _handleNotice(p.senderName, Uint8List.fromList(frame.notice.body),
            Uint8List.fromList(frame.notice.signature));
        unawaited(_pump());
        return;
      }
    } catch (_) {
      // Not a frame: try it as a packet below.
    }
    final pb.MeshPacket packet;
    try {
      packet = pb.MeshPacket.fromBuffer(p.bytes);
    } catch (_) {
      stats.malformed++;
      _addLog('DROP malformed packet from ${p.senderName}');
      return;
    }
    await _handlePacket(p.senderName, packet);
  }

  Future<void> _handlePacket(String source, pb.MeshPacket packet) async {
    final now = _now();
    final type = NeedType.fromProto(packet.type);
    if (packet.messageId.isEmpty ||
        packet.senderDeviceId.isEmpty ||
        packet.sealedPayload.isEmpty ||
        type == null) {
      stats.malformed++;
      _addLog('DROP invalid packet from $source');
      return;
    }
    final id = packet.messageId;

    // 3.1 Check Duplicate (FR-5)
    if (await db.messageExists(id)) {
      stats.duplicates++;
      if (!await db.hasExchanged(id, source)) {
        await db.logRelay(id, source, RelayDirection.inbound, now);
      }
      _addLog('DUP  ${type.label} (sealed): already have it, not relayed');
      notifyListeners();
      return;
    }

    // 3.2 Validate TTL and hop count (FR-6)
    final expiry = DateTime.fromMillisecondsSinceEpoch(packet.ttlExpiryMs.toInt());
    if (!expiry.isAfter(now)) {
      stats.expiredDropped++;
      _addLog('DROP ${type.label} (sealed): TTL expired');
      notifyListeners();
      return;
    }
    final hops = packet.hopCount + 1;
    if (hops > config.maxHops) {
      stats.hopLimitDropped++;
      _addLog('DROP ${type.label} (sealed): hop limit ($hops > ${config.maxHops})');
      notifyListeners();
      return;
    }

    // 3.3 Update priority score (FR-7) and store (D1)
    final created = DateTime.fromMillisecondsSinceEpoch(packet.timestampMs.toInt());
    await db.insertMessage(MessagesCompanion.insert(
      messageId: id,
      senderDeviceId: packet.senderDeviceId,
      type: type,
      timestamp: created,
      ttlExpiry: expiry,
      hopCount: hops,
      priorityScore: priorityScore(
          type: type, createdAt: created, ttlExpiry: expiry, hopCount: hops, now: now),
      status: MessageStatus.relayed,
      sealedPayload: Uint8List.fromList(packet.sealedPayload),
      receivedAt: now,
      latitude: const Value(null),
      longitude: const Value(null),
    ));
    // 3.5 Log relay event (D2)
    await db.logRelay(id, source, RelayDirection.inbound, now);
    stats.received++;
    _addLog('IN   ${type.label} relayed for someone else, hop $hops | '
        'sealed ${packet.sealedPayload.length} B ${_hex(packet.sealedPayload)}');

    // 3.4 Broadcast onward (FR-4), unless it has reached the hop limit
    if (hops < config.maxHops) {
      final m = (await db.getMessage(id))!;
      for (final peer in transport.connectedMeshPeers) {
        if (peer.deviceId == source) continue;
        _enqueueMessage(peer, m);
      }
    }
    unawaited(_pump());
  }

  /// Verifies, stores and floods an HQ notice. Returns true if it was new.
  Future<bool> _handleNotice(String source, Uint8List body, Uint8List signature) async {
    final now = _now();
    if (!verifier.verify(body, signature)) {
      stats.forgedDropped++;
      _addLog('DROP notice from $source: not signed by HQ (forged or altered)');
      notifyListeners();
      return false;
    }
    final pb.HqNotice n;
    try {
      n = pb.HqNotice.fromBuffer(body);
    } catch (_) {
      stats.malformed++;
      _addLog('DROP unreadable notice from $source');
      return false;
    }
    final id = n.noticeId;
    final receiptState = n.hasReceipt() ? ReceiptState.fromProto(n.receipt.status) : null;
    final level = n.hasAlert() ? AlertLevel.fromProto(n.alert.level) : null;
    if (id.isEmpty || (receiptState == null && level == null)) {
      stats.malformed++;
      _addLog('DROP invalid notice from $source');
      return false;
    }

    if (await db.noticeExists(id)) {
      stats.duplicates++;
      if (!await db.hasExchanged(id, source)) {
        await db.logRelay(id, source, RelayDirection.inbound, now);
      }
      notifyListeners();
      return false;
    }
    final expiry = DateTime.fromMillisecondsSinceEpoch(n.expiryMs.toInt());
    if (!expiry.isAfter(now)) {
      stats.expiredDropped++;
      _addLog('DROP HQ notice: expired');
      notifyListeners();
      return false;
    }

    final receipt = receiptState != null;
    await db.insertNotice(NoticesCompanion.insert(
      noticeId: id,
      kind: receipt ? NoticeKind.receipt : NoticeKind.alert,
      messageId: Value(receipt ? n.receipt.messageId : null),
      receiptState: Value(receiptState),
      teamName: Value(receipt && n.receipt.teamName.isNotEmpty ? n.receipt.teamName : null),
      alertLevel: Value(level),
      title: Value(receipt ? null : n.alert.title),
      body: Value(receipt ? null : n.alert.body),
      issuedAt: DateTime.fromMillisecondsSinceEpoch(n.issuedAtMs.toInt()),
      expiry: expiry,
      receivedAt: now,
      signedBody: body,
      signature: signature,
    ));
    await db.logRelay(id, source, RelayDirection.inbound, now);
    stats.noticesReceived++;
    final stored = (await db.getNotice(id))!;

    if (receipt) {
      final messageId = n.receipt.messageId;
      final m = await db.getMessage(messageId);
      final mine = m != null && m.senderDeviceId == transport.localId;
      _addLog(mine
          ? 'IN   HQ receipt for your ${m.type.label}: ${receiptState.label}'
              '${stored.teamName != null ? ' · ${stored.teamName}' : ''}'
          : 'IN   HQ receipt (for someone else\'s message)');
      // HQ has this message: stop spending radio time on it.
      if (m != null && (m.status == MessageStatus.created || m.status == MessageStatus.relayed)) {
        await db.setStatus(messageId, MessageStatus.uploaded);
        stats.deliveredElsewhere++;
        if (!mine) _addLog('STOP ${m.type.label} (sealed): HQ already has it, no longer relayed');
      }
    } else {
      _addLog('IN   HQ ${level!.label.toUpperCase()} alert "${n.alert.title}"');
      _newAlerts.add(stored);
    }

    if (!stored.superseded) {
      for (final peer in transport.connectedMeshPeers) {
        if (peer.deviceId == source) continue;
        _enqueueNotice(peer, stored);
      }
    }
    notifyListeners();
    return true;
  }

  bool _enqueueMessage(MeshPeer peer, StoredMessage m) {
    if (!_mayRelay(m)) {
      stats.powerSkipped++;
      return false;
    }
    final score = priorityScore(
        type: m.type,
        createdAt: m.timestamp,
        ttlExpiry: m.ttlExpiry,
        hopCount: m.hopCount,
        now: _now());
    return _enqueue(_Outgoing(peer, m.messageId, score, _seq++));
  }

  bool _enqueueNotice(MeshPeer peer, StoredNotice n) {
    final score = noticeScore(kind: n.kind, level: n.alertLevel);
    return _enqueue(_Outgoing(peer, n.noticeId, score, _seq++, notice: true));
  }

  bool _enqueue(_Outgoing item) {
    if (!_queued.add(item.key)) return false;
    _queue.add(item);
    return true;
  }

  /// Own messages always go out; others' depend on the battery mode.
  bool _mayRelay(StoredMessage m) =>
      m.senderDeviceId == transport.localId || _power.relaysForOthers(m.type);

  /// Drains the outbound queue one packet at a time, highest priority first.
  Future<void> _pump() async {
    if (_pumping) return;
    _pumping = true;
    try {
      while (_queue.isNotEmpty) {
        final item = _queue.removeFirst();
        _queued.remove(item.key);
        notifyListeners();

        final connected =
            transport.connectedMeshPeers.any((p) => p.endpointId == item.peer.endpointId);
        if (!connected) continue;
        final sent = item.notice ? await _sendNotice(item) : await _sendMessage(item);

        if (sent && config.sendInterval > Duration.zero) {
          await Future<void>.delayed(config.sendInterval);
        }
      }
    } finally {
      _pumping = false;
      notifyListeners();
    }
  }

  Future<bool> _sendMessage(_Outgoing item) async {
    final m = await db.getMessage(item.id);
    final now = _now();
    if (m == null) return false;
    if (m.status != MessageStatus.created && m.status != MessageStatus.relayed) return false;
    if (!m.ttlExpiry.isAfter(now)) return false;
    if (await db.hasExchanged(m.messageId, item.peer.deviceId)) return false;
    if (!_mayRelay(m)) {
      stats.powerSkipped++; // battery mode tightened while it was queued
      return false;
    }

    await db.updatePriority(m.messageId, item.score);
    await transport.send(item.peer.endpointId, _toPacket(m).writeToBuffer());
    await db.logRelay(m.messageId, item.peer.deviceId, RelayDirection.outbound, now);
    stats.forwarded++;
    _addLog(m.senderDeviceId == transport.localId
        ? 'OUT  your ${m.type.label} ${_short(m.messageId)} -> ${item.peer.deviceId}'
        : 'OUT  ${m.type.label} relayed (sealed), hop ${m.hopCount} '
            '(score ${item.score.toStringAsFixed(1)})');
    return true;
  }

  Future<bool> _sendNotice(_Outgoing item) async {
    final n = await db.getNotice(item.id);
    final now = _now();
    if (n == null || n.superseded || !n.expiry.isAfter(now)) return false;
    if (await db.hasExchanged(n.noticeId, item.peer.deviceId)) return false;

    final frame = pb.MeshFrame(notice: pb.SignedNotice(body: n.signedBody, signature: n.signature));
    await transport.send(item.peer.endpointId, frame.writeToBuffer());
    await db.logRelay(n.noticeId, item.peer.deviceId, RelayDirection.outbound, now);
    stats.forwarded++;
    _addLog('OUT  HQ ${n.kind == NoticeKind.receipt ? 'receipt' : 'alert "${n.title}"'} passed on');
    return true;
  }

  /// FR-6: stop carrying anything whose TTL has passed.
  Future<void> sweepExpired() async {
    final n = await db.expireOld(_now());
    if (n > 0) {
      stats.expiredInStore += n;
      _addLog('EXPIRE $n message(s): TTL passed, no longer relayed');
    }
  }

  /// Deletes messages, notices and relay-log rows that expired more than
  /// [MeshConfig.retention] ago, so the phone doesn't keep other people's
  /// (sealed) traffic, or its own history, forever.
  Future<void> pruneOld() async {
    final r = await db.pruneExpiredBefore(_now().subtract(config.retention));
    if (r.total > 0) {
      _addLog('CLEAN deleted ${r.messages} old message(s), ${r.notices} notice(s), '
          '${r.logRows} log row(s) (expired > ${config.retention.inDays} days ago)');
    }
  }

  pb.MeshPacket _toPacket(StoredMessage m) => pb.MeshPacket(
        messageId: m.messageId,
        senderDeviceId: m.senderDeviceId,
        type: m.type.toProto(),
        timestampMs: Int64(m.timestamp.millisecondsSinceEpoch),
        ttlExpiryMs: Int64(m.ttlExpiry.millisecondsSinceEpoch),
        hopCount: m.hopCount,
        sealedPayload: m.sealedPayload,
      );

  void _addLog(String line) {
    final t = _now().toIso8601String().substring(11, 19);
    _log.insert(0, '$t $line');
    if (_log.length > 300) _log.removeLast();
    debugPrint('[relay] $line');
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  static String _short(String id) => id.substring(0, min(8, id.length));

  static String _hex(List<int> bytes) {
    final head = bytes.take(12).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return bytes.length > 12 ? '$head…' : head;
  }

  @override
  void dispose() {
    _disposed = true;
    _expiryTimer?.cancel();
    _pruneTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _newAlerts.close();
    super.dispose();
  }
}
