import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  final String apiBaseUrl;

  const AppConfig({required this.apiBaseUrl});
}

/// DI root config. `AppScope` should override this for real environments.
final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig(apiBaseUrl: 'http://localhost:4000/api/v1');
});

