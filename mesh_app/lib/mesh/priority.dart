import '../models/emergency_message.dart';
import '../models/hq_notice.dart';

/// FR-7: priority score = f(type, age, hop count). Higher goes out first.
///
/// - type: severity sets the base, and the gaps are wide enough that
///   aging can never lift a routine STATUS above a fresh MEDICAL.
/// - age: up to +20 as a message nears its TTL, so older messages
///   aren't starved behind a stream of newer ones of the same type.
/// - hops: -2 per hop. A message that has already travelled far has
///   probably been copied widely, so fresher local reports go first.
///
/// Kept in its own file (SRS 4.3) so the formula can change without
/// touching relay, crypto or gateway code.
double priorityScore({
  required NeedType type,
  required DateTime createdAt,
  required DateTime ttlExpiry,
  required int hopCount,
  required DateTime now,
}) {
  final lifetime = ttlExpiry.difference(createdAt).inMilliseconds;
  final age = now.difference(createdAt).inMilliseconds;
  final ageFraction = lifetime <= 0 ? 1.0 : (age / lifetime).clamp(0.0, 1.0);
  return typeWeight(type) + 20 * ageFraction - 2 * hopCount;
}

double typeWeight(NeedType type) => switch (type) {
      NeedType.medical => 100,
      NeedType.trapped => 90,
      NeedType.supplies => 50,
      NeedType.status => 10,
    };

/// Queue score for an HQ notice, on the same scale as [priorityScore]. A
/// critical alert (e.g. an evacuation order affects everyone) goes out before
/// any single SOS; a receipt sits just below a fresh Trapped report.
double noticeScore({required NoticeKind kind, AlertLevel? level}) => switch ((kind, level)) {
      (NoticeKind.alert, AlertLevel.critical) => 130,
      (NoticeKind.alert, AlertLevel.warning) => 110,
      (NoticeKind.alert, _) => 80,
      (NoticeKind.receipt, _) => 85,
    };
