import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_config.dart';

class AppScope extends StatelessWidget {
  final Widget child;
  final String? apiBaseUrl;

  const AppScope({super.key, required this.child, this.apiBaseUrl});

  @override
  Widget build(BuildContext context) {
    // Composition root: override DI config here (env/config, auth, etc.).
    //
    // Mock API defaults:
    // - Desktop/Web: http://localhost:4000/api/v1
    // - Android emulator: http://10.0.2.2:4000/api/v1
    //
    // You can also set it at runtime:
    // `--dart-define=API_BASE_URL=http://localhost:4000/api/v1`
    final resolvedBaseUrl =
        apiBaseUrl ??
        const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:4000/api/v1',
        );

    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig(apiBaseUrl: resolvedBaseUrl),
        ),
      ],
      child: child,
    );
  }
}
