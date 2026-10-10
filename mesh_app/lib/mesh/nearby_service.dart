import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';

import 'mesh_transport.dart';

export 'mesh_transport.dart';

/// Service ID shared by every phone running the app. Nearby only connects
/// advertisers and discoverers that use the same ID.
const String kServiceId = 'com.emergencymesh.mesh_app';

enum PeerState { found, connecting, connected }

class Peer {
  Peer(this.endpointId, this.name, this.state);

  final String endpointId;
  final String name;
  PeerState state;
}

/// Wraps the nearby_connections plugin (FR-4 transport layer).
///
/// Every phone advertises and discovers at the same time using P2P_CLUSTER
/// (many-to-many), connects automatically to every peer it finds, and exposes
/// raw bytes in and out. It knows nothing about message formats. Relay logic
/// sits on top of it in relay_manager.dart.
class NearbyService extends ChangeNotifier implements MeshTransport {
  NearbyService({String? localId}) : localId = localId ?? _randomId();

  /// This phone's Device.deviceId, advertised as its Nearby nickname.
  @override
  final String localId;

  final Nearby _nearby = Nearby();
  final Map<String, Peer> _peers = {};
  final List<String> _log = [];
  final _incoming = StreamController<ReceivedPayload>.broadcast();
  final _peerConnected = StreamController<MeshPeer>.broadcast();
  bool _running = false;
  Timer? _restartTimer;

  // Battery saver: discovery (the expensive scan) runs only part of the time.
  (Duration, Duration)? _dutyCycle;
  Timer? _dutyTimer;
  bool _scanPaused = false;

  bool get isRunning => _running;
  List<Peer> get peers => _peers.values.toList(growable: false);
  List<Peer> get connectedPeers =>
      _peers.values.where((p) => p.state == PeerState.connected).toList();
  List<String> get log => List.unmodifiable(_log);

  /// True while battery saver has the discovery scan switched off.
  bool get scanPaused => _scanPaused;

  @override
  List<MeshPeer> get connectedMeshPeers =>
      [for (final p in connectedPeers) MeshPeer(p.endpointId, p.name)];

  @override
  Stream<MeshPeer> get peerConnected => _peerConnected.stream;

  /// Every bytes payload received from any connected peer.
  @override
  Stream<ReceivedPayload> get incoming => _incoming.stream;

  Future<void> start() async {
    if (_running) return;
    _running = true;
    _addLog('Starting as $localId');
    await _startAdvertising();
    await _startDiscovery();
    _scheduleDuty(scanning: true);
    notifyListeners();
  }

  Future<void> stop() async {
    _running = false;
    _restartTimer?.cancel();
    _dutyTimer?.cancel();
    _scanPaused = false;
    await _nearby.stopAdvertising();
    await _nearby.stopDiscovery();
    await _nearby.stopAllEndpoints();
    _peers.clear();
    _addLog('Stopped');
    notifyListeners();
  }

  /// Sends [bytes] to one connected peer.
  @override
  Future<void> send(String endpointId, Uint8List bytes) async {
    try {
      await _nearby.sendBytesPayload(endpointId, bytes);
    } catch (e) {
      _addLog('Send to ${_nameOf(endpointId)} failed: $e');
    }
  }

  Future<void> _startAdvertising() async {
    try {
      await _nearby.startAdvertising(
        localId,
        Strategy.P2P_CLUSTER,
        serviceId: kServiceId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
      _addLog('Advertising');
    } catch (e) {
      _addLog('Advertising failed: $e');
    }
  }

  /// Battery saver: scan for the first duration, pause for the second, repeat. Null
  /// means scan all the time. Advertising stays on, so other phones can still
  /// find and connect to this one while its own scan is paused.
  Future<void> setDiscoveryDutyCycle((Duration, Duration)? cycle) async {
    if (cycle == _dutyCycle) return;
    _dutyCycle = cycle;
    _dutyTimer?.cancel();
    if (!_running) return;
    if (_scanPaused) {
      _scanPaused = false;
      await _startDiscovery();
    }
    _addLog(cycle == null
        ? 'Scanning continuously'
        : 'Battery saver: scanning ${cycle.$1.inSeconds}s, pausing ${cycle.$2.inSeconds}s');
    _scheduleDuty(scanning: true);
    notifyListeners();
  }

  void _scheduleDuty({required bool scanning}) {
    final cycle = _dutyCycle;
    if (cycle == null || !_running) return;
    _dutyTimer = Timer(scanning ? cycle.$1 : cycle.$2, () async {
      if (!_running || _dutyCycle != cycle) return;
      _scanPaused = scanning;
      if (scanning) {
        await _nearby.stopDiscovery();
      } else {
        await _startDiscovery();
      }
      notifyListeners();
      _scheduleDuty(scanning: !scanning);
    });
  }

  Future<void> _startDiscovery() async {
    if (_scanPaused) return; // battery saver; the duty timer resumes it
    try {
      await _nearby.startDiscovery(
        localId,
        Strategy.P2P_CLUSTER,
        serviceId: kServiceId,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
      );
      _addLog('Discovering');
    } catch (e) {
      _addLog('Discovery failed: $e');
    }
  }

  void _onEndpointFound(String endpointId, String name, String serviceId) {
    if (serviceId != kServiceId) return;
    final existing = _peers[endpointId];
    if (existing != null && existing.state != PeerState.found) return;
    _peers[endpointId] = Peer(endpointId, name, PeerState.found);
    _addLog('Found $name');
    notifyListeners();

    // Tie-break so two phones don't both request at once (a common cause of
    // Nearby connection errors): only the phone with the smaller ID asks.
    if (localId.compareTo(name) < 0) {
      _requestConnection(endpointId, name);
    }
  }

  Future<void> _requestConnection(String endpointId, String name) async {
    _peers[endpointId]?.state = PeerState.connecting;
    notifyListeners();
    try {
      await _nearby.requestConnection(
        localId,
        endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
      _addLog('Requested connection to $name');
    } catch (e) {
      _addLog('Request to $name failed: $e');
      _peers[endpointId]?.state = PeerState.found;
      _scheduleRestart();
    }
    notifyListeners();
  }

  void _onEndpointLost(String? endpointId) {
    final peer = _peers[endpointId];
    if (peer != null && peer.state != PeerState.connected) {
      _peers.remove(endpointId);
      _addLog('Lost ${peer.name}');
      notifyListeners();
    }
  }

  void _onConnectionInitiated(String endpointId, ConnectionInfo info) {
    _peers[endpointId] =
        Peer(endpointId, info.endpointName, PeerState.connecting);
    _addLog('Accepting ${info.endpointName}');
    notifyListeners();
    _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: _onPayloadReceived,
    );
  }

  void _onConnectionResult(String endpointId, Status status) {
    final peer = _peers[endpointId];
    if (status == Status.CONNECTED) {
      peer?.state = PeerState.connected;
      _addLog('Connected to ${peer?.name ?? endpointId}');
      if (peer != null) _peerConnected.add(MeshPeer(endpointId, peer.name));
    } else {
      _peers.remove(endpointId);
      _addLog('Connection to ${peer?.name ?? endpointId}: ${status.name}');
      _scheduleRestart();
    }
    notifyListeners();
  }

  void _onDisconnected(String endpointId) {
    final peer = _peers.remove(endpointId);
    _addLog('Disconnected from ${peer?.name ?? endpointId}');
    notifyListeners();
    _scheduleRestart();
  }

  void _onPayloadReceived(String endpointId, Payload payload) {
    final bytes = payload.bytes;
    if (payload.type != PayloadType.BYTES || bytes == null) return;
    _incoming.add(ReceivedPayload(endpointId, _nameOf(endpointId), bytes));
  }

  /// Restarts discovery so peers that dropped out get found and reconnected.
  void _scheduleRestart() {
    if (!_running) return;
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(seconds: 3), () async {
      if (!_running) return;
      _peers.removeWhere((_, p) => p.state == PeerState.found);
      await _nearby.stopDiscovery();
      await _startDiscovery();
      notifyListeners();
    });
  }

  String _nameOf(String endpointId) => _peers[endpointId]?.name ?? endpointId;

  void _addLog(String line) {
    final t = DateTime.now().toIso8601String().substring(11, 19);
    _log.insert(0, '$t  $line');
    if (_log.length > 200) _log.removeLast();
    debugPrint('[mesh] $line');
  }

  @override
  void dispose() {
    _restartTimer?.cancel();
    _dutyTimer?.cancel();
    _incoming.close();
    _peerConnected.close();
    super.dispose();
  }

  static String _randomId() {
    final r = Random.secure();
    return List.generate(8, (_) => r.nextInt(16).toRadixString(16)).join();
  }
}
