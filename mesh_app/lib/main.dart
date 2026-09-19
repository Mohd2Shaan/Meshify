import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'crypto/message_crypto.dart';
import 'db/app_database.dart';
import 'mesh/nearby_service.dart';
import 'mesh/relay_manager.dart';
import 'services/emergency_sender.dart';
import 'services/location_service.dart';
import 'ui/setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final deviceId = await db.getOrCreateDeviceId();
  final config = MeshConfig();
  final MessageCrypto crypto = PlaintextCrypto(); // Phase 5: libsodium sealed box
  final nearby = NearbyService(localId: deviceId);
  final relay = RelayManager(db: db, transport: nearby, config: config)..start();
  final sender = EmergencySender(
    db: db,
    relay: relay,
    crypto: crypto,
    location: LocationService(),
    deviceId: deviceId,
    config: config,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: db),
        Provider.value(value: config),
        Provider.value(value: crypto),
        Provider.value(value: sender),
        ChangeNotifierProvider.value(value: nearby),
        ChangeNotifierProvider.value(value: relay),
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
