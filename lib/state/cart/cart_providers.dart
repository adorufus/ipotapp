import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/models/cart.model.dart';
import 'package:ipotapp/models/menu_response.model.dart';
import 'package:ipotapp/screens/menu/providers/menu.provider.dart';

final cartControllerProvider = StateNotifierProvider<CartController, CartState>(
  (ref) {
    return CartController();
  },
);

class CartController extends StateNotifier<CartState> {
  CartController() : super(CartState.empty());

  void addMenuItem(
    MenuItem item, {
    int quantity = 1,
    List<SelectedOption> selectedOptions = const [],
  }) {
    if (quantity <= 0) return;

    final normalizedOptions = [...selectedOptions]
      ..removeWhere((o) => o.quantity <= 0)
      ..sort((a, b) => a.optionId.compareTo(b.optionId));

    bool sameOptions(List<SelectedOption> a, List<SelectedOption> b) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (a[i].optionId != b[i].optionId) return false;
        if (a[i].quantity != b[i].quantity) return false;
      }
      return true;
    }

    final existing = state.linesById.values.where((l) {
      final a = [...l.selectedOptions]
        ..sort((x, y) => x.optionId.compareTo(y.optionId));
      return l.menuItemId == item.id && sameOptions(a, normalizedOptions);
    }).toList();

    if (existing.isNotEmpty) {
      final line = existing.first;
      state = CartState(
        linesById: {
          ...state.linesById,
          line.lineId: CartLine(
            lineId: line.lineId,
            menuItemId: line.menuItemId,
            quantity: line.quantity + quantity,
            selectedOptions: line.selectedOptions,
          ),
        },
        customerNote: state.customerNote,
        submitting: state.submitting,
        submitError: state.submitError,
      );
      return;
    }

    final lineId = DateTime.now().microsecondsSinceEpoch.toString();
    state = CartState(
      linesById: {
        ...state.linesById,
        lineId: CartLine(
          lineId: lineId,
          menuItemId: item.id,
          quantity: quantity,
          selectedOptions: normalizedOptions,
        ),
      },
      customerNote: state.customerNote,
      submitting: state.submitting,
      submitError: state.submitError,
    );
  }

  void increment(String lineId) {
    final line = state.linesById[lineId];
    if (line == null) return;
    state = CartState(
      linesById: {
        ...state.linesById,
        lineId: CartLine(
          lineId: line.lineId,
          menuItemId: line.menuItemId,
          quantity: line.quantity + 1,
          selectedOptions: line.selectedOptions,
        ),
      },
      customerNote: state.customerNote,
      submitting: state.submitting,
      submitError: state.submitError,
    );
  }

  void decrement(String lineId) {
    final line = state.linesById[lineId];
    if (line == null) return;
    if (line.quantity <= 1) {
      remove(lineId);
      return;
    }
    state = CartState(
      linesById: {
        ...state.linesById,
        lineId: CartLine(
          lineId: line.lineId,
          menuItemId: line.menuItemId,
          quantity: line.quantity - 1,
          selectedOptions: line.selectedOptions,
        ),
      },
      customerNote: state.customerNote,
      submitting: state.submitting,
      submitError: state.submitError,
    );
  }

  void remove(String lineId) {
    if (!state.linesById.containsKey(lineId)) return;
    final next = {...state.linesById}..remove(lineId);
    state = CartState(
      linesById: next,
      customerNote: state.customerNote,
      submitting: state.submitting,
      submitError: state.submitError,
    );
  }

  void clear() {
    state = CartState.empty();
  }
}

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartControllerProvider);
  return cart.linesById.values.fold<int>(0, (sum, l) => sum + l.quantity);
});

final cartTotalCentsProvider = Provider<int>((ref) {
  final cart = ref.watch(cartControllerProvider);
  final asyncMenu = ref.watch(menuResponseProvider);

  return asyncMenu.maybeWhen(
    data: (menu) {
      final itemsById = {for (final it in menu.items) it.id: it};
      final optionById = <int, CustomizationOption>{};
      for (final it in menu.items) {
        for (final g in it.customizationGroups) {
          for (final o in g.options) {
            optionById[o.id] = o;
          }
        }
      }
      var total = 0;
      for (final line in cart.linesById.values) {
        final item = itemsById[line.menuItemId];
        if (item == null) continue;
        var unit = item.priceCents;
        for (final sel in line.selectedOptions) {
          final opt = optionById[sel.optionId];
          if (opt == null) continue;
          unit += opt.priceModifierCents * sel.quantity;
        }
        total += unit * line.quantity;
      }
      return total;
    },
    orElse: () => 0,
  );
});
