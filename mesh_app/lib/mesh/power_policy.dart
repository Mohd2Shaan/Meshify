import '../models/emergency_message.dart';

/// Battery-aware relaying. In a disaster nobody can charge their phone, and a
/// phone that dies stops relaying for everyone. So as the battery drains, a
/// phone spends its radio time on what matters most.
///
/// | Mode     | When (auto)            | Relays for others        | Discovery scan   |
/// |----------|------------------------|--------------------------|------------------|
/// | normal   | > 30 %, or charging    | everything               | always on        |
/// | saver    | 16-30 %                | Medical and Trapped only | 1 min on, 1 off  |
/// | critical | 15 % or less           | nothing                  | 20 s on, 100 off |
///
/// In every mode a phone still sends its own messages, still uploads if it is
/// a gateway, and still passes on HQ receipts and alerts (they are tiny and
/// can save lives). Advertising stays on, so others can still find it.
enum PowerMode {
  normal('Normal', 'Relays everything, scans continuously'),
  saver('Battery saver', 'Relays only Medical and Trapped for others; scans half the time'),
  critical('Critical battery', 'Sends only its own SOS; scans 20 s in every 2 min');

  const PowerMode(this.label, this.description);

  final String label;
  final String description;

  static const saverBelow = 30;
  static const criticalBelow = 15;

  static PowerMode auto({required int level, required bool charging}) {
    if (charging || level > saverBelow) return PowerMode.normal;
    if (level > criticalBelow) return PowerMode.saver;
    return PowerMode.critical;
  }

  /// Whether this phone should forward someone else's message of [type].
  bool relaysForOthers(NeedType type) => switch (this) {
        PowerMode.normal => true,
        PowerMode.saver => type == NeedType.medical || type == NeedType.trapped,
        PowerMode.critical => false,
      };

  /// Discovery duty cycle: (scan on, scan off), or null for always on.
  (Duration, Duration)? get discoveryDutyCycle => switch (this) {
        PowerMode.normal => null,
        PowerMode.saver => (const Duration(seconds: 60), const Duration(seconds: 60)),
        PowerMode.critical => (const Duration(seconds: 20), const Duration(seconds: 100)),
      };
}
