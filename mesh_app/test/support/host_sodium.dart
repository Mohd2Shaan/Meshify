import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:sodium/sodium.dart' hide SodiumInit;
import 'package:sodium/sodium.ffi.dart';

/// Loads libsodium on the developer PC for tests: the same DLL the backend
/// uses, taken from lazysodium-java's jar in the Gradle cache.
class HostSodium {
  HostSodium._(this.sodium);

  final Sodium sodium;

  static final String _home = Platform.environment['USERPROFILE'] ?? '';
  static final String repo = Directory.current.parent.path;
  static final File keyFile = File('$repo/backend/secrets/mesh-keys.properties');

  /// Why the host-crypto tests can't run here, or null if they can.
  static String? get unavailableReason {
    if (!Platform.isWindows) return 'host crypto tests only run on Windows';
    if (_jar() == null) return 'lazysodium jar not in Gradle cache (build the backend once)';
    if (!keyFile.existsSync()) return 'no backend key (run ./gradlew genKeys)';
    return null;
  }

  static Future<HostSodium> load() async {
    final dll = await _extractDll(_jar()!);
    return HostSodium._(await SodiumInit.init(() => DynamicLibrary.open(dll)));
  }

  SecureKey backendSecretKey() {
    final line = keyFile.readAsLinesSync().firstWhere((l) => l.startsWith('mesh.crypto.private-key='));
    return SecureKey.fromList(sodium, base64Decode(line.split('=').skip(1).join('=')));
  }

  Uint8List seal(Uint8List message, Uint8List publicKey) =>
      sodium.crypto.box.seal(message: message, publicKey: publicKey);

  static String? _jar() {
    final d = Directory('$_home/.gradle/caches/modules-2/files-2.1/com.goterl/lazysodium-java');
    if (!d.existsSync()) return null;
    for (final f in d.listSync(recursive: true)) {
      if (f.path.endsWith('lazysodium-java-5.1.4.jar')) return f.path;
    }
    return null;
  }

  static Future<String> _extractDll(String jar) async {
    final out = Directory('${Directory.systemTemp.path}/mesh_sodium')..createSync(recursive: true);
    final dll = '${out.path}/libsodium.dll';
    if (!File(dll).existsSync()) {
      final r = await Process.run('tar', ['-xf', jar, '-C', out.path, 'windows64/libsodium.dll']);
      if (r.exitCode != 0) throw StateError('could not extract libsodium.dll: ${r.stderr}');
      File('${out.path}/windows64/libsodium.dll').copySync(dll);
    }
    return dll;
  }
}
