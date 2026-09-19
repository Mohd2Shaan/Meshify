import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';

import '../config.dart';
import '../db/app_database.dart';
import '../models/emergency_message.dart';
import '../proto/emergency_message.pb.dart' as pb;
import 'mesh_transport.dart';
import 'priority.dart';

class RelayStats {
  int received = 0;
  int duplicates = 0;
  int expiredDropped = 0;
  int hopLimitDropped = 0;
  int malformed = 0;
  int forwarded = 0;
  int expiredInStore = 0;
}

class _Outgoing {
  _Outgoing(this.peer, this.messageId, this.score, this.seq);

  final MeshPeer peer;
  final String messageId;
  final double score;
  final int seq;

  String get key => '${peer.deviceId}|$messageId';
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
class RelayManager extends ChangeNotifier {
  RelayManager({
    required this.db,
    required this.transport,
    MeshConfig? config,
    DateTime Function()? clock,
  })  : config = config ?? MeshConfig(),
        _now = clock ?? DateTime.now;

  final AppDatabase db;
  final MeshTransport transport;
  final MeshConfig config;
  final DateTime Function() _now;

  final RelayStats stats = RelayStats();
  final List<String> _log = [];
  final Set<String> _queued = {};
  late PriorityQueue<_Outgoing> _queue = PriorityQueue(_compare);
  int _seq = 0;
  bool _fifo = false;
  bool _pumping = false;
  bool _disposed = false;
  Future<void> _serial = Future.value();
  final List<StreamSubscription<dynamic>> _subs = [];
  Timer? _expiryTimer;

  List<String> get log => List.unmodifiable(_log);
  int get queueLength => _queue.length;

  /// Phase 4 baseline: when true the queue ignores priority (plain FIFO,
  /// like Bridgefy) so the two can be compared under congestion.
  bool get fifoMode => _fifo;
  set fifoMode(bool v) {
    _fifo = v;
    final items = _queue.toList();
    _queue = PriorityQueue(_compare)..addAll(items);
    notifyListeners();
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
        if (_enqueue(peer, m)) count++;
      }
      _addLog('NEW ${_short(messageId)} ${m.type.label} queued for $count peer(s)');
    });
    unawaited(_pump());
    return count;
  }

  /// Store-carry-forward: offer everything we carry to a new neighbour.
  Future<void> _offerStoreTo(MeshPeer peer) async {
    final carried = await db.forwardableMessages(_now(), config.maxHops);
    var count = 0;
    for (final m in carried) {
      if (await db.hasExchanged(m.messageId, peer.deviceId)) continue;
      if (_enqueue(peer, m)) count++;
    }
    if (count > 0) _addLog('PEER ${peer.deviceId}: offering $count carried message(s)');
    unawaited(_pump());
  }

  Future<void> _handleIncoming(ReceivedPayload p) async {
    final now = _now();
    final pb.MeshPacket packet;
    try {
      packet = pb.MeshPacket.fromBuffer(p.bytes);
    } catch (_) {
      stats.malformed++;
      _addLog('DROP malformed packet from ${p.senderName}');
      return;
    }
    final type = NeedType.fromProto(packet.type);
    if (packet.messageId.isEmpty ||
        packet.senderDeviceId.isEmpty ||
        packet.sealedPayload.isEmpty ||
        type == null) {
      stats.malformed++;
      _addLog('DROP invalid packet from ${p.senderName}');
      return;
    }
    final id = packet.messageId;

    // 3.1 Check Duplicate (FR-5)
    if (await db.messageExists(id)) {
      stats.duplicates++;
      if (!await db.hasExchanged(id, p.senderName)) {
        await db.logRelay(id, p.senderName, RelayDirection.inbound, now);
      }
      _addLog('DUP  ${_short(id)} from ${p.senderName}: already seen, not relayed');
      notifyListeners();
      return;
    }

    // 3.2 Validate TTL and hop count (FR-6)
    final expiry = DateTime.fromMillisecondsSinceEpoch(packet.ttlExpiryMs.toInt());
    if (!expiry.isAfter(now)) {
      stats.expiredDropped++;
      _addLog('DROP ${_short(id)} from ${p.senderName}: TTL expired');
      notifyListeners();
      return;
    }
    final hops = packet.hopCount + 1;
    if (hops > config.maxHops) {
      stats.hopLimitDropped++;
      _addLog('DROP ${_short(id)} from ${p.senderName}: hop limit ($hops > ${config.maxHops})');
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
    await db.logRelay(id, p.senderName, RelayDirection.inbound, now);
    stats.received++;
    _addLog('IN   ${_short(id)} ${type.label} hop $hops from ${p.senderName} | '
        'content: ${packet.sealedPayload.length} B sealed ${_hex(packet.sealedPayload)}');

    // 3.4 Broadcast onward (FR-4), unless it has reached the hop limit
    if (hops < config.maxHops) {
      final m = (await db.getMessage(id))!;
      for (final peer in transport.connectedMeshPeers) {
        if (peer.deviceId == p.senderName) continue;
        _enqueue(peer, m);
      }
    }
    unawaited(_pump());
  }

  bool _enqueue(MeshPeer peer, StoredMessage m) {
    final item = _Outgoing(
      peer,
      m.messageId,
      priorityScore(
          type: m.type,
          createdAt: m.timestamp,
          ttlExpiry: m.ttlExpiry,
          hopCount: m.hopCount,
          now: _now()),
      _seq++,
    );
    if (!_queued.add(item.key)) return false;
    _queue.add(item);
    return true;
  }

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
        final m = await db.getMessage(item.messageId);
        final now = _now();
        if (!connected || m == null) continue;
        if (m.status != MessageStatus.created && m.status != MessageStatus.relayed) continue;
        if (!m.ttlExpiry.isAfter(now)) continue;
        if (await db.hasExchanged(m.messageId, item.peer.deviceId)) continue;

        await db.updatePriority(m.messageId, item.score);
        await transport.send(item.peer.endpointId, _toPacket(m).writeToBuffer());
        await db.logRelay(m.messageId, item.peer.deviceId, RelayDirection.outbound, now);
        stats.forwarded++;
        _addLog('OUT  ${_short(m.messageId)} ${m.type.label} hop ${m.hopCount} '
            '-> ${item.peer.deviceId} (score ${item.score.toStringAsFixed(1)})');

        if (config.sendInterval > Duration.zero) {
          await Future<void>.delayed(config.sendInterval);
        }
      }
    } finally {
      _pumping = false;
      notifyListeners();
    }
  }

  /// FR-6: stop carrying anything whose TTL has passed.
  Future<void> sweepExpired() async {
    final n = await db.expireOld(_now());
    if (n > 0) {
      stats.expiredInStore += n;
      _addLog('EXPIRE $n message(s): TTL passed, no longer relayed');
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
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
