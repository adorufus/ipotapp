// Run: `flutter test integration_test/ -d flutter-tester` (CI) or
// `flutter test integration_test/ -d <device>` when multiple devices are listed.
// Web targets are not supported for integration_test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ipotapp/main.dart';
import 'package:ipotapp/state/app_scope.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches with shell and bottom navigation', (tester) async {
    await tester.pumpWidget(
      const AppScope(
        apiBaseUrl: 'http://127.0.0.1:9/api/v1',
        child: MainApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
  });
}
