import 'dart:typed_data';

/// A connected neighbour. [deviceId] is its Device.deviceId (its Nearby
/// nickname). [endpointId] is Nearby's handle for the current connection.
class MeshPeer {
  const MeshPeer(this.endpointId, this.deviceId);

  final String endpointId;
  final String deviceId;
}

class ReceivedPayload {
  ReceivedPayload(this.endpointId, this.senderName, this.bytes);

  final String endpointId;

  /// The sending neighbour's deviceId.
  final String senderName;
  final Uint8List bytes;
}

/// What the relay layer needs from the radio layer. NearbyService implements
/// it on real phones, and tests use an in-memory fake network.
abstract class MeshTransport {
  String get localId;

  List<MeshPeer> get connectedMeshPeers;

  /// Fires when a new neighbour finishes connecting.
  Stream<MeshPeer> get peerConnected;

  Stream<ReceivedPayload> get incoming;

  Future<void> send(String endpointId, Uint8List bytes);
}
