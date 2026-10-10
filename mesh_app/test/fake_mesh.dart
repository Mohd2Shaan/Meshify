import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:mesh_app/config.dart';
import 'package:mesh_app/crypto/notice_verifier.dart';
import 'package:mesh_app/db/app_database.dart';
import 'package:mesh_app/mesh/mesh_transport.dart';
import 'package:mesh_app/mesh/priority.dart';
import 'package:mesh_app/mesh/relay_manager.dart';
import 'package:mesh_app/models/emergency_message.dart';
import 'package:mesh_app/proto/emergency_message.pb.dart' as pb;

/// In-memory stand-in for the Bluetooth layer, so relay logic can be tested
/// across several simulated phones on a PC. Endpoint IDs are device IDs.
class FakeNode implements MeshTransport {
  FakeNode(this.localId, {MeshConfig? config, DateTime Function()? clock})
      : config = config ?? MeshConfig() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    relay = RelayManager(
        db: db, transport: this, verifier: FakeHq.verifier, config: this.config, clock: clock)
      ..start();
  }

  @override
  final String localId;
  final MeshConfig config;
  late final AppDatabase db;
  late final RelayManager relay;

  final Map<String, FakeNode> links = {};

  /// Message and notice IDs this node received over the air, in arrival order.
  final List<String> arrivals = [];

  final _incoming = StreamController<ReceivedPayload>.broadcast();
  final _peerConnected = StreamController<MeshPeer>.broadcast();

  @override
  List<MeshPeer> get connectedMeshPeers =>
      [for (final id in links.keys) MeshPeer(id, id)];

  @override
  Stream<MeshPeer> get peerConnected => _peerConnected.stream;

  @override
  Stream<ReceivedPayload> get incoming => _incoming.stream;

  @override
  Future<void> send(String endpointId, Uint8List bytes) async {
    final target = links[endpointId];
    if (target == null) return;
    Timer.run(() {
      final frame = pb.MeshFrame.fromBuffer(bytes);
      target.arrivals.add(frame.hasNotice()
          ? pb.HqNotice.fromBuffer(frame.notice.body).noticeId
          : pb.MeshPacket.fromBuffer(bytes).messageId);
      target._incoming.add(ReceivedPayload(localId, localId, bytes));
    });
  }

  /// Delivers raw bytes as if [from] had sent them.
  void inject(String from, Uint8List bytes) =>
      _incoming.add(ReceivedPayload(from, from, bytes));

  Future<void> dispose() async {
    relay.dispose();
    await db.close();
  }
}

void link(FakeNode a, FakeNode b) {
  a.links[b.localId] = b;
  b.links[a.localId] = a;
  a._peerConnected.add(MeshPeer(b.localId, b.localId));
  b._peerConnected.add(MeshPeer(a.localId, a.localId));
}

void unlink(FakeNode a, FakeNode b) {
  a.links.remove(b.localId);
  b.links.remove(a.localId);
}

/// Lets the simulated network run until no node has sent or received
/// anything for a while.
Future<void> settle(List<FakeNode> nodes, {Duration quiet = const Duration(milliseconds: 150)}) async {
  int activity() => nodes.fold(0, (s, n) => s + n.relay.stats.forwarded + n.arrivals.length);
  var last = -1;
  var stableFor = Duration.zero;
  const step = Duration(milliseconds: 10);
  for (var i = 0; i < 1000 && stableFor < quiet; i++) {
    await Future<void>.delayed(step);
    final now = activity();
    final busy = nodes.any((n) => n.relay.queueLength > 0);
    stableFor = (now == last && !busy) ? stableFor + step : Duration.zero;
    last = now;
  }
}

int _counter = 0;

/// Creates a message on [node] as EmergencySender would (minus GPS), and
/// hands it to the relay.
Future<String> createMessage(
  FakeNode node,
  NeedType type, {
  Duration ttl = const Duration(hours: 1),
  DateTime? now,
}) async {
  final t = now ?? DateTime.now();
  final id = 'msg-${type.name}-${_counter++}-${newId()}';
  final expiry = t.add(ttl);
  await node.db.insertMessage(MessagesCompanion.insert(
    messageId: id,
    senderDeviceId: node.localId,
    type: type,
    latitude: const Value(13.08),
    longitude: const Value(80.27),
    timestamp: t,
    ttlExpiry: expiry,
    hopCount: 0,
    priorityScore: priorityScore(type: type, createdAt: t, ttlExpiry: expiry, hopCount: 0, now: t),
    status: MessageStatus.created,
    sealedPayload: pb.EmergencyPayload(latitude: 13.08, longitude: 80.27).writeToBuffer(),
    receivedAt: t,
  ));
  await node.relay.originate(id);
  return id;
}

/// Stands in for HQ's Ed25519 key in relay tests: "signs" with a checksum
/// only FakeHq.verifier accepts, so forged/altered notices can be tested too.
/// The real signature is tested in crypto_interop_test.dart.
class FakeHq {
  static final NoticeVerifier verifier = _FakeVerifier();

  static Uint8List sign(Uint8List body) {
    final sum = body.fold<int>(7, (a, b) => (a * 31 + b) & 0x7fffffff);
    return Uint8List.fromList(utf8.encode('HQ-SIG:$sum'));
  }

  static Uint8List _notice(pb.HqNotice n) => n.writeToBuffer();

  static (Uint8List, Uint8List) receipt(String messageId,
      {pb.ReceiptStatus status = pb.ReceiptStatus.DELIVERED,
      String team = '',
      DateTime? issued,
      Duration ttl = const Duration(hours: 6)}) {
    final t = issued ?? DateTime.now();
    final body = _notice(pb.HqNotice(
      noticeId: 'r-$messageId-${status.name}-${t.microsecondsSinceEpoch}',
      issuedAtMs: Int64(t.millisecondsSinceEpoch),
      expiryMs: Int64(t.add(ttl).millisecondsSinceEpoch),
      receipt: pb.DeliveryReceipt(messageId: messageId, status: status, teamName: team),
    ));
    return (body, sign(body));
  }

  static (Uint8List, Uint8List) alert(String title,
      {pb.AlertLevel level = pb.AlertLevel.CRITICAL, Duration ttl = const Duration(hours: 1)}) {
    final t = DateTime.now();
    final body = _notice(pb.HqNotice(
      noticeId: 'a-$title-${t.microsecondsSinceEpoch}',
      issuedAtMs: Int64(t.millisecondsSinceEpoch),
      expiryMs: Int64(t.add(ttl).millisecondsSinceEpoch),
      alert: pb.HqAlert(level: level, title: title, body: 'Body of $title'),
    ));
    return (body, sign(body));
  }

  /// Wraps a notice for [FakeNode.inject], as a phone sends it.
  static Uint8List frame((Uint8List, Uint8List) n) =>
      pb.MeshFrame(notice: pb.SignedNotice(body: n.$1, signature: n.$2)).writeToBuffer();
}

class _FakeVerifier implements NoticeVerifier {
  @override
  bool verify(Uint8List body, Uint8List signature) => listEquals(signature, FakeHq.sign(body));
}
