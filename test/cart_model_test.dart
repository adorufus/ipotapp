import 'package:flutter_test/flutter_test.dart';
import 'package:ipotapp/models/cart.model.dart';

void main() {
  group('CartLine', () {
    test('fromJson maps fields and customizations', () {
      final line = CartLine.fromJson({
        'line_id': 'a1',
        'menu_item_id': 42,
        'quantity': 2,
        'customizations': [
          {'option_id': 7, 'quantity': 1},
        ],
      });

      expect(line.lineId, 'a1');
      expect(line.menuItemId, 42);
      expect(line.quantity, 2);
      expect(line.selectedOptions, hasLength(1));
      expect(line.selectedOptions.first.optionId, 7);
      expect(line.selectedOptions.first.quantity, 1);
    });

    test('toJson round-trips with fromJson', () {
      const original = CartLine(
        lineId: 'x',
        menuItemId: 1,
        quantity: 3,
        selectedOptions: [
          SelectedOption(optionId: 9, quantity: 2),
        ],
      );

      final restored = CartLine.fromJson(original.toJson());
      expect(restored.lineId, original.lineId);
      expect(restored.menuItemId, original.menuItemId);
      expect(restored.quantity, original.quantity);
      expect(restored.selectedOptions, hasLength(1));
      expect(restored.selectedOptions.first.optionId, 9);
      expect(restored.selectedOptions.first.quantity, 2);
    });
  });

  group('SelectedOption', () {
    test('fromJson defaults quantity to 1 when absent', () {
      final o = SelectedOption.fromJson({'option_id': 5});
      expect(o.optionId, 5);
      expect(o.quantity, 1);
    });
  });

  test('CartState.empty has no lines and is not submitting', () {
    final s = CartState.empty();
    expect(s.linesById, isEmpty);
    expect(s.customerNote, '');
    expect(s.submitting, isFalse);
    expect(s.submitError, isNull);
  });
}
