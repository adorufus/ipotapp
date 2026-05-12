import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'screens/app_shell.screen.dart';
import 'state/app_scope.dart';
import 'utils/color_utils.dart';

void main() {
  runApp(const AppScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _theme(),
          home: child,
        );
      },
      child: const AppShellScreen(),
    );
  }
}
