import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_config.dart';

class AppScope extends StatelessWidget {
  final Widget child;
  final String? apiBaseUrl;

  const AppScope({super.key, required this.child, this.apiBaseUrl});

  @override
  Widget build(BuildContext context) {
    final hostIpOverride =
        const String.fromEnvironment('HOST_IP', defaultValue: '').trim();
    final host = hostIpOverride.isNotEmpty ? hostIpOverride : '10.0.2.2';
    final defaultBaseUrl = 'http://$host:4000/api/v1';

    final resolvedBaseUrl =
        apiBaseUrl ??
        String.fromEnvironment('API_BASE_URL', defaultValue: defaultBaseUrl);

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
