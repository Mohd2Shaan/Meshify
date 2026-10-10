import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/app_database.dart';
import '../mesh/nearby_service.dart';
import 'alerts_screen.dart';
import 'messages_screen.dart';
import 'nearby_devices_screen.dart';
import 'send_emergency_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _alertsTab = 2;
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final deviceId = context.read<NearbyService>().localId;
    final db = context.read<AppDatabase>();
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          SendEmergencyScreen(onShowAlerts: () => _select(_alertsTab)),
          MessagesScreen(deviceId: deviceId),
          const AlertsScreen(),
          const NearbyDevicesScreen(),
        ],
      ),
      bottomNavigationBar: StreamBuilder<int>(
        stream: db.watchUnseenAlertCount(),
        builder: (context, snap) {
          final unseen = snap.data ?? 0;
          // Alerts arriving while the tab is open count as seen.
          if (unseen > 0 && _tab == _alertsTab) unawaited(db.markAlertsSeen());
          return NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: _select,
            destinations: [
              const NavigationDestination(icon: Icon(Icons.sos), label: 'Send'),
              const NavigationDestination(icon: Icon(Icons.inbox), label: 'Messages'),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unseen > 0 && _tab != _alertsTab,
                  label: Text('$unseen'),
                  child: const Icon(Icons.campaign),
                ),
                label: 'Alerts',
              ),
              const NavigationDestination(icon: Icon(Icons.hub), label: 'Mesh'),
            ],
          );
        },
      ),
    );
  }

  void _select(int i) {
    setState(() => _tab = i);
    if (i == _alertsTab) unawaited(context.read<AppDatabase>().markAlertsSeen());
  }
}
