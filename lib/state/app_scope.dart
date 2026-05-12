import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_config.dart';

class AppScope extends StatelessWidget {
  final Widget child;
  final String? apiBaseUrl;

  const AppScope({super.key, required this.child, this.apiBaseUrl});

  @override
  Widget build(BuildContext context) {
    final resolvedBaseUrl = (apiBaseUrl ?? const String.fromEnvironment('API_BASE_URL')).trim();

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
