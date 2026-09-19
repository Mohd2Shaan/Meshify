import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'crypto/message_crypto.dart';
import 'db/app_database.dart';
import 'mesh/gateway_detector.dart';
import 'mesh/mesh_controller.dart';
import 'mesh/nearby_service.dart';
import 'mesh/relay_manager.dart';
import 'services/background_service.dart';
import 'services/emergency_sender.dart';
import 'services/gateway_uploader.dart';
import 'services/location_service.dart';
import 'ui/setup_screen.dart';

/// Runs once per app process, in the engine MeshApplication.kt creates. That
/// can be with no screen at all (after a reboot), so the mesh is started
/// here and not from a widget.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final deviceId = await db.getOrCreateDeviceId();
  final config = MeshConfig();
  final MessageCrypto crypto = await SealedBoxCrypto.create(); // FR-3
  final nearby = NearbyService(localId: deviceId);
  final relay = RelayManager(db: db, transport: nearby, config: config)..start();
  final background = BackgroundService();
  final controller = MeshController(db: db, nearby: nearby, service: background);
  final sender = EmergencySender(
    db: db,
    relay: relay,
    crypto: crypto,
    location: LocationService(),
    deviceId: deviceId,
    config: config,
  );
  final gateway = GatewayDetector(
    db: db,
    uploader: GatewayUploader(db: db, deviceId: deviceId),
    service: background,
  );
  await controller.init();
  await gateway.init();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: db),
        Provider.value(value: config),
        Provider.value(value: crypto),
        Provider.value(value: sender),
        Provider.value(value: background),
        ChangeNotifierProvider.value(value: nearby),
        ChangeNotifierProvider.value(value: relay),
        ChangeNotifierProvider.value(value: controller),
        ChangeNotifierProvider.value(value: gateway),
      ],
      child: const MeshApp(),
    ),
  );
}

class MeshApp extends StatelessWidget {
  const MeshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Mesh',
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      home: const StartupGate(),
    );
  }
}
