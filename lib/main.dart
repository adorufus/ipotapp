import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n/app_localizations.dart';
import 'screens/app_shell.screen.dart';
import 'state/app_scope.dart';
import 'state/locale_provider.dart';
import 'utils/color_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const apiBase = String.fromEnvironment('API_BASE_URL');
  if (apiBase.trim().isEmpty) {
    throw StateError(
      'API_BASE_URL is not set. Add it to config.json (see config.example.json in the '
      'repo root), then run the app with:\n'
      '  flutter run --dart-define-from-file=config.json\n'
      'See README for platform-specific URLs and CI.',
    );
  }

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) {
    throw StateError(
      'SUPABASE_URL and SUPABASE_ANON_KEY are not set. Add them next to API_BASE_URL in '
      'config.json (see config.example.json), then run with:\n'
      '  flutter run --dart-define-from-file=config.json',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl.trim(),
    anonKey: supabaseAnonKey.trim(),
  );

  runApp(const AppScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  static ThemeData _theme() {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.tertiary,
      onSecondary: Colors.white,
      surface: AppColors.secondary,
      onSurface: AppColors.neutral,
      error: Color(0xFFB42318),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.secondary,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.neutral;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider).valueOrNull;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _theme(),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          localeResolutionCallback: (deviceLocale, supported) {
            if (deviceLocale != null) {
              for (final loc in supported) {
                if (loc.languageCode == deviceLocale.languageCode) {
                  return loc;
                }
              }
            }
            return supported.first;
          },
          home: child,
        );
      },
      child: const AppShellScreen(),
    );
  }
}
