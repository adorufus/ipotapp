class SelectedOption {
  final int optionId;
  final int quantity;
  const SelectedOption({required this.optionId, required this.quantity});

  factory SelectedOption.fromJson(Map<String, dynamic> json) => SelectedOption(
    optionId: (json['option_id'] as num).toInt(),
    quantity: (json['quantity'] as num? ?? 1).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'option_id': optionId,
    'quantity': quantity,
  };
}

class CartLine {
  final String lineId;
  final int menuItemId;
  final int quantity;
  final List<SelectedOption> selectedOptions;

  const CartLine({
    required this.lineId,
    required this.menuItemId,
    required this.quantity,
    required this.selectedOptions,
  });

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    lineId: (json['line_id'] ?? '').toString(),
    menuItemId: (json['menu_item_id'] as num).toInt(),
    quantity: (json['quantity'] as num? ?? 1).toInt(),
    selectedOptions: (json['customizations'] as List? ?? const [])
        .whereType<Map>()
        .map((m) => SelectedOption.fromJson(m.cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'line_id': lineId,
    'menu_item_id': menuItemId,
    'quantity': quantity,
    'customizations': selectedOptions.map((o) => o.toJson()).toList(),
  };
}

class CartState {
  final Map<String, CartLine> linesById;
  final String customerNote;
  final bool submitting;
  final String? submitError;

  const CartState({
    required this.linesById,
    required this.customerNote,
    required this.submitting,
    this.submitError,
  });

  factory CartState.empty() => const CartState(
    linesById: {},
    customerNote: '',
    submitting: false,
    submitError: null,
  );
}
