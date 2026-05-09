import 'package:flutter/material.dart';

import 'screens/app_shell.screen.dart';
import 'state/app_scope.dart';

void main() {
  runApp(const AppScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppShellScreen(),
    );
  }
}
