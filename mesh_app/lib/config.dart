/// Tunable mesh parameters. One place, so the SRS/test report can cite them.
class MeshConfig {
  MeshConfig({
    this.defaultTtl = const Duration(hours: 6),
    this.maxHops = 10,
    this.sendInterval = Duration.zero,
  });

  /// FR-6: how long a new message may circulate before it is discarded.
  Duration defaultTtl;

  /// FR-6: a message is not forwarded once it has taken this many hops.
  int maxHops;

  /// Artificial gap between outgoing sends. Zero in normal use; the FR-7
  /// congestion test raises it to simulate a slow, saturated Bluetooth link.
  Duration sendInterval;

  /// Phase 9 TTL test: short TTL so expiry can be watched live.
  static const Duration testTtl = Duration(minutes: 2);
  static const Duration normalTtl = Duration(hours: 6);

  /// Keeps each packet well inside one small BLE transfer.
  static const int maxNoteLength = 140;
}
