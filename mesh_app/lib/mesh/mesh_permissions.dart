import 'package:permission_handler/permission_handler.dart';

/// Runtime permissions needed by Nearby Connections (FR-4) and GPS (FR-1).
///
/// Android only grants the ones that apply to the running OS version:
/// the BLUETOOTH_* trio exists from Android 12, NEARBY_WIFI_DEVICES from 13.
/// On older versions permission_handler reports those as granted.
class MeshPermissions {
  static const List<Permission> required = [
    Permission.location,
    Permission.bluetoothScan,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.nearbyWifiDevices,
  ];

  static final Map<Permission, String> labels = {
    Permission.location: 'Location (GPS + peer discovery)',
    Permission.bluetoothScan: 'Bluetooth scan',
    Permission.bluetoothAdvertise: 'Bluetooth advertise',
    Permission.bluetoothConnect: 'Bluetooth connect',
    Permission.nearbyWifiDevices: 'Nearby Wi-Fi devices',
  };

  static Future<Map<Permission, PermissionStatus>> check() async {
    return {for (final p in required) p: await p.status};
  }

  static Future<Map<Permission, PermissionStatus>> request() {
    return required.request();
  }

  static bool allGranted(Map<Permission, PermissionStatus> statuses) {
    return statuses.values.every((s) => s.isGranted || s.isLimited);
  }

  /// Nearby discovery also needs the Location toggle itself switched on.
  static Future<bool> locationServiceOn() async {
    return await Permission.location.serviceStatus.isEnabled;
  }
}
