import 'dart:convert';

import 'package:dio/dio.dart';

import '../db/app_database.dart';

/// Where the gateway uploads to. Editable in the Mesh tab, with defaults from
///   flutter run --dart-define=BACKEND_URL=http://192.168.137.1:8080
///              --dart-define=GATEWAY_API_KEY=dev-gateway-key
class BackendSettings {
  const BackendSettings(this.baseUrl, this.apiKey);

  final String baseUrl;
  final String apiKey;

  static const defaultUrl =
      String.fromEnvironment('BACKEND_URL', defaultValue: 'http://192.168.137.1:8080');
  static const defaultApiKey =
      String.fromEnvironment('GATEWAY_API_KEY', defaultValue: 'dev-gateway-key');
}

enum UploadOutcome {
  /// 201 new incident, or 200 already received via another gateway.
  delivered,

  /// 422: TTL passed before it reached HQ.
  expired,

  /// 400: backend can't open or parse it. Retrying won't help.
  rejected,

  /// 401/403: wrong API key. Nothing will upload until settings are fixed.
  unauthorized,

  /// Network error or 5xx. Try again later.
  retryLater,
}

class UploadResult {
  UploadResult(this.outcome, {this.uploadId, this.ackStatus, this.detail});

  final UploadOutcome outcome;
  final String? uploadId;
  final String? ackStatus;
  final String? detail;
}

/// REST client for the Spring Boot backend (FR-8 health check, FR-9 upload).
class BackendClient {
  BackendClient(this.settings, {Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
              // Handle every status ourselves instead of throwing.
              validateStatus: (_) => true,
            )) {
    _dio.options.baseUrl = settings.baseUrl;
    _dio.options.headers['X-API-Key'] = settings.apiKey;
  }

  final BackendSettings settings;
  final Dio _dio;

  /// FR-8: true only if the backend itself answers, not just "has Wi-Fi".
  Future<bool> isReachable() async {
    try {
      final res = await _dio.get<Object>('/api/health');
      return res.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  /// FR-9: POST /api/messages. Only the routing header and the sealed
  /// payload leave the phone; the gateway can't read the content either.
  Future<UploadResult> upload(StoredMessage m, {required String gatewayDeviceId}) async {
    final Response<Object> res;
    try {
      res = await _dio.post<Object>('/api/messages', data: {
        'messageId': m.messageId,
        'senderDeviceId': m.senderDeviceId,
        'gatewayDeviceId': gatewayDeviceId,
        'type': m.type.apiName,
        'timestampMs': m.timestamp.millisecondsSinceEpoch,
        'ttlExpiryMs': m.ttlExpiry.millisecondsSinceEpoch,
        'hopCount': m.hopCount,
        'priorityScore': m.priorityScore,
        'sealedPayload': base64Encode(m.sealedPayload),
      });
    } on DioException catch (e) {
      return UploadResult(UploadOutcome.retryLater, detail: e.message ?? e.type.name);
    }
    final body = res.data is Map ? res.data! as Map : const {};
    final uploadId = body['uploadId'] as String?;
    final ack = body['ackStatus'] as String?;
    return switch (res.statusCode) {
      200 || 201 => UploadResult(UploadOutcome.delivered, uploadId: uploadId, ackStatus: ack),
      422 => UploadResult(UploadOutcome.expired, uploadId: uploadId, ackStatus: ack),
      400 => UploadResult(UploadOutcome.rejected, detail: body['detail'] as String?),
      401 || 403 => UploadResult(UploadOutcome.unauthorized, detail: 'API key refused'),
      _ => UploadResult(UploadOutcome.retryLater, detail: 'HTTP ${res.statusCode}'),
    };
  }
}
