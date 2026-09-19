import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:mesh_app/config.dart';
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
    relay = RelayManager(db: db, transport: this, config: this.config, clock: clock)..start();
  }

  @override
  final String localId;
  final MeshConfig config;
  late final AppDatabase db;
  late final RelayManager relay;

  final Map<String, FakeNode> links = {};

  /// Message IDs this node received over the air, in arrival order.
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
      target.arrivals.add(pb.MeshPacket.fromBuffer(bytes).messageId);
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
