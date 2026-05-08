int moneyToCents(num value) => (value * 100).round();
double centsToMoney(int cents) => cents / 100.0;

class Restaurant {
  final String id;
  final String name;
  final String tableId;

  const Restaurant({
    required this.id,
    required this.name,
    required this.tableId,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: (json['id'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    tableId: (json['table_id'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'table_id': tableId,
  };
}

class MenuResponse {
  final Restaurant restaurant;
  final List<MenuCategory> categories;
  final List<MenuItem> items;

  const MenuResponse({
    required this.restaurant,
    required this.categories,
    required this.items,
  });

  factory MenuResponse.fromJson(Map<String, dynamic> json) => MenuResponse(
    restaurant: Restaurant.fromJson(
      (json['restaurant'] as Map).cast<String, dynamic>(),
    ),
    categories: (json['categories'] as List? ?? const [])
        .whereType<Map>()
        .map((m) => MenuCategory.fromJson(m.cast<String, dynamic>()))
        .toList(),
    items: (json['items'] as List? ?? const [])
        .whereType<Map>()
        .map((m) => MenuItem.fromJson(m.cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'restaurant': restaurant.toJson(),
    'categories': categories.map((c) => c.toJson()).toList(),
    'items': items.map((i) => i.toJson()).toList(),
  };
}

class MenuCategory {
  final int id;
  final String name;
  final int sortOrder;

  const MenuCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
    id: (json['id'] as num).toInt(),
    name: (json['name'] ?? '').toString(),
    sortOrder: (json['sort_order'] as num? ?? 0).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sort_order': sortOrder,
  };
}

class MenuItem {
  final int id;
  final String name;
  final String description;
  final int priceCents;
  final int categoryId;
  final String? imageUrl;
  final List<CustomizationGroup> customizationGroups;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.categoryId,
    required this.imageUrl,
    required this.customizationGroups,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: (json['id'] as num).toInt(),
    name: (json['name'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    priceCents: moneyToCents((json['price'] as num?) ?? 0),
    categoryId: (json['category_id'] as num? ?? 0).toInt(),
    imageUrl: json['image_url'] == null ? null : json['image_url'].toString(),
    customizationGroups: (json['customization_groups'] as List? ?? const [])
        .whereType<Map>()
        .map((m) => CustomizationGroup.fromJson(m.cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': centsToMoney(priceCents),
    'category_id': categoryId,
    'image_url': imageUrl,
    'customization_groups': customizationGroups.map((g) => g.toJson()).toList(),
  };
}

class CustomizationGroup {
  final int id;
  final String name;
  final bool required;
  final int maxSelections;
  final List<CustomizationOption> options;

  const CustomizationGroup({
    required this.id,
    required this.name,
    required this.required,
    required this.maxSelections,
    required this.options,
  });

  factory CustomizationGroup.fromJson(Map<String, dynamic> json) =>
      CustomizationGroup(
        id: (json['id'] as num).toInt(),
        name: (json['name'] ?? '').toString(),
        required: (json['required'] as bool?) ?? false,
        maxSelections: (json['max_selections'] as num? ?? 0).toInt(),
        options: (json['options'] as List? ?? const [])
            .whereType<Map>()
            .map((m) => CustomizationOption.fromJson(m.cast<String, dynamic>()))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'required': required,
    'max_selections': maxSelections,
    'options': options.map((o) => o.toJson()).toList(),
  };
}

class CustomizationOption {
  final int id;
  final String name;
  final int priceModifierCents;

  const CustomizationOption({
    required this.id,
    required this.name,
    required this.priceModifierCents,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) =>
      CustomizationOption(
        id: (json['id'] as num).toInt(),
        name: (json['name'] ?? '').toString(),
        priceModifierCents: moneyToCents((json['price_modifier'] as num?) ?? 0),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price_modifier': centsToMoney(priceModifierCents),
  };
}
