import '../api/backend_client.dart';
import '../db/app_database.dart';
import '../models/emergency_message.dart';

class UploadRun {
  int delivered = 0;
  int expired = 0;
  int rejected = 0;

  /// Set when the run stopped early (network dropped, bad API key).
  String? stoppedBecause;
  bool unauthorized = false;

  int get attempted => delivered + expired + rejected;
}

/// FR-9: uploads every stored, undelivered message (most urgent first) and
/// records each crossing in GatewayUpload (D3). A delivered message stops
/// being relayed: its job is done.
class GatewayUploader {
  GatewayUploader({
    required this.db,
    required this.deviceId,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final AppDatabase db;
  final String deviceId;
  final DateTime Function() _now;

  Future<UploadRun> uploadPending(BackendClient client) async {
    final run = UploadRun();
    for (final m in await db.pendingUploads(_now())) {
      final r = await client.upload(m, gatewayDeviceId: deviceId);
      switch (r.outcome) {
        case UploadOutcome.delivered:
          await _record(m, r, r.ackStatus ?? 'ACKNOWLEDGED');
          await db.setStatus(m.messageId, MessageStatus.uploaded);
          run.delivered++;
        case UploadOutcome.expired:
          await _record(m, r, r.ackStatus ?? 'REJECTED');
          await db.setStatus(m.messageId, MessageStatus.expired);
          run.expired++;
        case UploadOutcome.rejected:
          await db.setStatus(m.messageId, MessageStatus.rejected);
          run.rejected++;
        case UploadOutcome.unauthorized:
          run.unauthorized = true;
          run.stoppedBecause = 'API key refused. Check the gateway settings';
          return run;
        case UploadOutcome.retryLater:
          run.stoppedBecause = r.detail ?? 'network error';
          return run;
      }
    }
    return run;
  }

  Future<void> _record(StoredMessage m, UploadResult r, String ack) => db.recordUpload(
        uploadId: r.uploadId ?? newId(),
        messageId: m.messageId,
        gatewayDeviceId: deviceId,
        at: _now(),
        ackStatus: ack,
      );
}
