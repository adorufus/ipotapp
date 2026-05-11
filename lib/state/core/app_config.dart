import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AppConfig {
  final String apiBaseUrl;

  const AppConfig({required this.apiBaseUrl});
}

/// DI root config. `AppScope` should override this for real environments.
final appConfigProvider = Provider<AppConfig>((ref) {
  // On Android emulators, `localhost` points to the emulator itself.
  // `10.0.2.2` routes to the host machine's loopback interface.
  final hostIpOverride = const String.fromEnvironment('HOST_IP').trim();
  final host = (!kIsWeb && Platform.isAndroid)
      ? (hostIpOverride.isNotEmpty ? hostIpOverride : '10.0.2.2')
      : 'localhost';

  return AppConfig(apiBaseUrl: 'http://$host:4000/api/v1');
});
