import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipotapp/components/menu_item_card.dart';
import 'package:ipotapp/l10n/app_localizations.dart';
import 'package:ipotapp/models/menu_response.model.dart';

void main() {
  testWidgets('MenuItemCard shows name and formatted price', (tester) async {
    const item = MenuItem(
      id: 10,
      name: 'House Ramen',
      description: 'Rich broth, noodles, egg.',
      priceCents: 1299,
      categoryId: 1,
      imageUrl: null,
      customizationGroups: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: MenuItemCard(item: item, onAdd: _noop),
        ),
      ),
    );

    expect(find.text('House Ramen'), findsOneWidget);
    expect(find.text(r'$12.99'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });

  testWidgets('MenuItemCard invokes onAdd when + is tapped', (tester) async {
    var tapped = false;
    const item = MenuItem(
      id: 2,
      name: 'Side',
      description: 'Small plate',
      priceCents: 100,
      categoryId: 1,
      imageUrl: null,
      customizationGroups: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: MenuItemCard(
            item: item,
            onAdd: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(tapped, isTrue);
  });
}

void _noop() {}
