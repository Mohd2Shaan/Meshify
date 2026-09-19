import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mesh/nearby_service.dart';
import 'ui/setup_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NearbyService(),
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
      home: const SetupScreen(),
    );
  }
}
