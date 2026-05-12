import 'package:flutter_riverpod/flutter_riverpod.dart';

/// REST API base URL including `/api/v1`.
///
/// In production this must be supplied at compile time via
/// `--dart-define=API_BASE_URL=...` or `--dart-define-from-file=config.json`.
/// See [AppScope] in `lib/state/app_scope.dart`.
class AppConfig {
  final String apiBaseUrl;

  const AppConfig({required this.apiBaseUrl});
}

/// Fallback when no [AppScope] override. Prefer wrapping the app in [AppScope]
/// so the URL comes from dart-define (see `main.dart`).
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig(apiBaseUrl: const String.fromEnvironment('API_BASE_URL').trim());
});
