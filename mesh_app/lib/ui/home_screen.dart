import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mesh/nearby_service.dart';
import 'messages_screen.dart';
import 'nearby_devices_screen.dart';
import 'send_emergency_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // Relay participants are passive (SRS 2.3): the mesh runs as soon as the
    // app is open, with nothing to switch on.
    context.read<NearbyService>().start();
  }

  @override
  Widget build(BuildContext context) {
    final deviceId = context.read<NearbyService>().localId;
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          const SendEmergencyScreen(),
          MessagesScreen(deviceId: deviceId),
          const NearbyDevicesScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sos), label: 'Send'),
          NavigationDestination(icon: Icon(Icons.inbox), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.hub), label: 'Mesh'),
        ],
      ),
    );
  }
}
