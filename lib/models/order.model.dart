enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  served;

  static OrderStatus fromWire(String value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'served':
        return OrderStatus.served;
      default:
        return OrderStatus.pending;
    }
  }

  String toWire() {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.ready:
        return 'ready';
      case OrderStatus.served:
        return 'served';
    }
  }
}

class OrderRequest {
  final String tableId;
  final List<OrderRequestItem> items;
  final String customerNote;

  const OrderRequest({
    required this.tableId,
    required this.items,
    required this.customerNote,
  });

  Map<String, dynamic> toJson() => {
    'table_id': tableId,
    'items': items.map((i) => i.toJson()).toList(),
    'customer_note': customerNote,
  };
}

class OrderRequestItem {
  final int menuItemId;
  final int quantity;
  final List<OrderRequestCustomization> customizations;

  const OrderRequestItem({
    required this.menuItemId,
    required this.quantity,
    required this.customizations,
  });

  Map<String, dynamic> toJson() => {
    'menu_item_id': menuItemId,
    'quantity': quantity,
    'customizations': customizations.map((c) => c.toJson()).toList(),
  };
}

class OrderRequestCustomization {
  final int optionId;
  final int quantity;

  const OrderRequestCustomization({
    required this.optionId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'option_id': optionId,
    'quantity': quantity,
  };
}

class OrderResponse {
  final Order order;
  const OrderResponse({required this.order});

  factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
    order: Order.fromJson((json['order'] as Map).cast<String, dynamic>()),
  );
}

class Order {
  final String id;
  final String restaurantId;
  final String tableId;
  final OrderStatus status;
  final int? estimatedPrepTimeMinutes;
  final String customerNote;

  // Optional: totals returned by mock api
  final double? subtotal;
  final double? total;
  final String? currency;

  final String createdAt;
  final String updatedAt;

  final List<OrderTimelineEvent> timeline;
  final List<OrderLineItem> items;

  const Order({
    required this.id,
    required this.restaurantId,
    required this.tableId,
    required this.status,
    required this.estimatedPrepTimeMinutes,
    required this.customerNote,
    required this.subtotal,
    required this.total,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    required this.timeline,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: (json['id'] ?? '').toString(),
    restaurantId: (json['restaurant_id'] ?? '').toString(),
    tableId: (json['table_id'] ?? '').toString(),
    status: OrderStatus.fromWire((json['status'] ?? 'pending').toString()),
    estimatedPrepTimeMinutes: (json['estimated_prep_time_minutes'] as num?)
        ?.toInt(),
    customerNote: (json['customer_note'] ?? '').toString(),
    subtotal: (json['subtotal'] as num?)?.toDouble(),
    total: (json['total'] as num?)?.toDouble(),
    currency: json['currency']?.toString(),
    createdAt: (json['created_at'] ?? '').toString(),
    updatedAt: (json['updated_at'] ?? json['created_at'] ?? '').toString(),
    timeline: (json['timeline'] as List? ?? const [])
        .whereType<Map>()
        .map((m) => OrderTimelineEvent.fromJson(m.cast<String, dynamic>()))
        .toList(),
    items: (json['items'] as List? ?? const [])
        .whereType<Map>()
        .map((m) => OrderLineItem.fromJson(m.cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'restaurant_id': restaurantId,
    'table_id': tableId,
    'status': status.toWire(),
    'estimated_prep_time_minutes': estimatedPrepTimeMinutes,
    'customer_note': customerNote,
    'subtotal': subtotal,
    'total': total,
    'currency': currency,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'timeline': timeline.map((t) => t.toJson()).toList(),
    'items': items.map((i) => i.toJson()).toList(),
  };
}

class OrderTimelineEvent {
  final OrderStatus status;
  final String at;
  const OrderTimelineEvent({required this.status, required this.at});

  factory OrderTimelineEvent.fromJson(Map<String, dynamic> json) =>
      OrderTimelineEvent(
        status: OrderStatus.fromWire((json['status'] ?? 'pending').toString()),
        at: (json['at'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'status': status.toWire(), 'at': at};
}

class OrderLineItem {
  final int menuItemId;
  final String name;
  final double unitPrice;
  final int quantity;
  final List<OrderLineCustomization> customizations;
  final double lineTotal;

  const OrderLineItem({
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.customizations,
    required this.lineTotal,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) => OrderLineItem(
    menuItemId: (json['menu_item_id'] as num).toInt(),
    name: (json['name'] ?? '').toString(),
    unitPrice: (json['unit_price'] as num? ?? 0).toDouble(),
    quantity: (json['quantity'] as num? ?? 1).toInt(),
    customizations: (json['customizations'] as List? ?? const [])
        .whereType<Map>()
        .map((m) => OrderLineCustomization.fromJson(m.cast<String, dynamic>()))
        .toList(),
    lineTotal: (json['line_total'] as num? ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'menu_item_id': menuItemId,
    'name': name,
    'unit_price': unitPrice,
    'quantity': quantity,
    'customizations': customizations.map((c) => c.toJson()).toList(),
    'line_total': lineTotal,
  };
}

class OrderLineCustomization {
  final int optionId;
  final String optionName;
  final double priceModifier;
  final int quantity;

  const OrderLineCustomization({
    required this.optionId,
    required this.optionName,
    required this.priceModifier,
    required this.quantity,
  });

  factory OrderLineCustomization.fromJson(Map<String, dynamic> json) =>
      OrderLineCustomization(
        optionId: (json['option_id'] as num).toInt(),
        optionName: (json['option_name'] ?? '').toString(),
        priceModifier: (json['price_modifier'] as num? ?? 0).toDouble(),
        quantity: (json['quantity'] as num? ?? 1).toInt(),
      );

  Map<String, dynamic> toJson() => {
    'option_id': optionId,
    'option_name': optionName,
    'price_modifier': priceModifier,
    'quantity': quantity,
  };
}
