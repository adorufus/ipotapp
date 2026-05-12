import 'package:ipotapp/models/menu_response.model.dart';
import 'package:ipotapp/models/order.model.dart';

/// Builds a display [Order] from cart payload + menu when the server is unavailable.
Order buildOfflinePlaceholderOrder({
  required String localId,
  required OrderRequest request,
  required MenuResponse menu,
}) {
  final now = DateTime.now().toUtc().toIso8601String();
  final itemsById = {for (final it in menu.items) it.id: it};
  final optionById = <int, CustomizationOption>{};
  for (final it in menu.items) {
    for (final g in it.customizationGroups) {
      for (final o in g.options) {
        optionById[o.id] = o;
      }
    }
  }

  var subtotalCents = 0;
  final lines = <OrderLineItem>[];

  for (final ri in request.items) {
    final menuItem = itemsById[ri.menuItemId];
    final name = menuItem?.name ?? 'Item #${ri.menuItemId}';
    var unitCents = menuItem?.priceCents ?? 0;
    final lineCustomizations = <OrderLineCustomization>[];

    for (final c in ri.customizations) {
      final opt = optionById[c.optionId];
      final modCents = opt?.priceModifierCents ?? 0;
      unitCents += modCents * c.quantity;
      lineCustomizations.add(
        OrderLineCustomization(
          optionId: c.optionId,
          optionName: opt?.name ?? 'Option #${c.optionId}',
          priceModifier: centsToMoney(modCents),
          quantity: c.quantity,
        ),
      );
    }

    final lineTotalCents = unitCents * ri.quantity;
    subtotalCents += lineTotalCents;

    lines.add(
      OrderLineItem(
        menuItemId: ri.menuItemId,
        name: name,
        unitPrice: centsToMoney(unitCents),
        quantity: ri.quantity,
        customizations: lineCustomizations,
        lineTotal: centsToMoney(lineTotalCents),
      ),
    );
  }

  final subtotal = centsToMoney(subtotalCents);

  return Order(
    id: localId,
    restaurantId: menu.restaurant.id,
    tableId: request.tableId,
    status: OrderStatus.pending,
    estimatedPrepTimeMinutes: null,
    customerNote: request.customerNote,
    subtotal: subtotal,
    total: subtotal,
    currency: 'USD',
    createdAt: now,
    updatedAt: now,
    timeline: [OrderTimelineEvent(status: OrderStatus.pending, at: now)],
    items: lines,
  );
}
