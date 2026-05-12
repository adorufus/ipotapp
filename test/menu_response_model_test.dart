import 'package:flutter_test/flutter_test.dart';
import 'package:ipotapp/models/menu_response.model.dart';

void main() {
  group('moneyToCents / centsToMoney', () {
    test('moneyToCents rounds dollar amounts to cents', () {
      expect(moneyToCents(9.99), 999);
      expect(moneyToCents(0), 0);
      expect(moneyToCents(10), 1000);
    });

    test('centsToMoney converts back for API payloads', () {
      expect(centsToMoney(999), closeTo(9.99, 1e-9));
      expect(centsToMoney(0), 0);
    });
  });

  group('MenuItem', () {
    test('fromJson derives priceCents from decimal price', () {
      final item = MenuItem.fromJson({
        'id': 1,
        'name': 'Latte',
        'description': 'Milk + espresso',
        'price': 4.5,
        'category_id': 2,
        'image_url': null,
        'customization_groups': [],
      });

      expect(item.id, 1);
      expect(item.name, 'Latte');
      expect(item.priceCents, 450);
      expect(item.categoryId, 2);
      expect(item.imageUrl, isNull);
    });

    test('toJson uses dollar float for price fields', () {
      const item = MenuItem(
        id: 3,
        name: 'Tea',
        description: '',
        priceCents: 125,
        categoryId: 1,
        imageUrl: null,
        customizationGroups: [],
      );

      final json = item.toJson();
      expect(json['price'], closeTo(1.25, 1e-9));
      expect(json['name'], 'Tea');
    });
  });
}
