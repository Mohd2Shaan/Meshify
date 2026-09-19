import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/backend_client.dart';
import '../db/app_database.dart';
import '../services/background_service.dart';
import '../services/gateway_uploader.dart';

/// DFD process 4.0 "Detect Gateway and Upload".
///
/// FR-8: this phone is a Gateway while the backend answers /api/health.
/// Having Wi-Fi or data isn't enough, since disaster networks are often up but
/// broken. It re-checks the moment Android reports new internet, and every
/// 30 s as a fallback.
///
/// FR-9: while a Gateway, it uploads whatever the phone carries, and again
/// whenever a new message arrives over the mesh.
class GatewayDetector extends ChangeNotifier {
  GatewayDetector({
    required this.db,
    required this.uploader,
    required this.service,
    BackendClient Function(BackendSettings)? clientFactory,
  }) : _clientFactory = clientFactory ?? BackendClient.new;

  final AppDatabase db;
  final GatewayUploader uploader;
  final BackgroundService service;
  final BackendClient Function(BackendSettings) _clientFactory;

  static const _urlKey = 'backendUrl';
  static const _apiKeyKey = 'gatewayApiKey';
  static const checkInterval = Duration(seconds: 30);

  late BackendSettings _settings;
  late BackendClient _client;
  bool _isGateway = false;
  bool _uploading = false;
  bool _uploadAgain = false;
  DateTime? _lastCheck;
  UploadRun? _lastRun;
  int _deliveredTotal = 0;
  Timer? _timer;
  StreamSubscription<Object>? _storeSub;

  bool get isGateway => _isGateway;
  bool get isUploading => _uploading;
  DateTime? get lastCheck => _lastCheck;
  UploadRun? get lastRun => _lastRun;
  int get deliveredTotal => _deliveredTotal;
  BackendSettings get settings => _settings;

  Future<void> init() async {
    _settings = BackendSettings(
      await db.getSetting(_urlKey) ?? BackendSettings.defaultUrl,
      await db.getSetting(_apiKeyKey) ?? BackendSettings.defaultApiKey,
    );
    _client = _clientFactory(_settings);
    service.onInternetChanged = (_) => unawaited(check());
    _timer = Timer.periodic(checkInterval, (_) => unawaited(check()));
    // New or relayed messages arriving while online go straight up.
    _storeSub = db.watchMessages().listen((_) {
      if (_isGateway) unawaited(uploadNow());
    });
    unawaited(check());
  }

  Future<void> updateSettings(String url, String apiKey) async {
    final clean = url.trim().replaceAll(RegExp(r'/+$'), '');
    await db.setSetting(_urlKey, clean);
    await db.setSetting(_apiKeyKey, apiKey.trim());
    _settings = BackendSettings(clean, apiKey.trim());
    _client = _clientFactory(_settings);
    await check();
  }

  /// FR-8: am I a Gateway right now?
  Future<void> check() async {
    final reachable = await _client.isReachable();
    _lastCheck = DateTime.now();
    final changed = reachable != _isGateway;
    _isGateway = reachable;
    notifyListeners();
    if (changed) _pushStatus();
    if (reachable) await uploadNow();
  }

  /// FR-9: upload everything pending. Serialised: a call during a run makes
  /// the run go round once more instead of starting a second one.
  Future<void> uploadNow() async {
    if (_uploading) {
      _uploadAgain = true;
      return;
    }
    _uploading = true;
    notifyListeners();
    try {
      do {
        _uploadAgain = false;
        final run = await uploader.uploadPending(_client);
        _deliveredTotal += run.delivered;
        if (run.attempted > 0 || run.stoppedBecause != null) _lastRun = run;
        if (run.stoppedBecause != null && !run.unauthorized) {
          _isGateway = false; // the network went away mid-run
          _pushStatus();
          break;
        }
      } while (_uploadAgain);
    } finally {
      _uploading = false;
      notifyListeners();
    }
  }

  void _pushStatus() => unawaited(service.setGateway(_isGateway));

  @override
  void dispose() {
    _timer?.cancel();
    _storeSub?.cancel();
    super.dispose();
  }
}
