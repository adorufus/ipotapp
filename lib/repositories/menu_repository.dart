import 'package:ipotapp/models/menu_response.model.dart';
import 'package:ipotapp/services/dio_http_service.dart';
import 'package:ipotapp/services/menu_cache_store.dart';
import 'package:ipotapp/utils/network_reachability.dart';

class MenuRepository {
  final DioHttpService _http;
  final MenuCacheStore _cache;

  MenuRepository(this._http, this._cache);

  Future<MenuResponse> fetchMenu({required String? tableId}) async {
    final tableKey = (tableId ?? '').trim();

    try {
      final res = await _http.get<dynamic>(
        '/menu',
        queryParameters: {
          if (tableId != null && tableId.isNotEmpty) 'table_id': tableId,
        },
      );

      final menu = _parseMenuResponse(res.data);
      await _cache.save(tableKey, menu);
      return menu;
    } catch (e) {
      if (isUnreachableError(e)) {
        final cached = await _cache.load(tableKey);
        if (cached != null) return cached;
      }
      return _mockMenu(tableId: tableId);
    }
  }

  MenuResponse _parseMenuResponse(dynamic data) {
    if (data is Map<String, dynamic>) return MenuResponse.fromJson(data);
    if (data is Map) {
      return MenuResponse.fromJson(data.cast<String, dynamic>());
    }
    throw StateError('Unexpected response type: ${data.runtimeType}');
  }
}

MenuResponse _mockMenu({required String? tableId}) {
  final categories = <MenuCategory>[
    const MenuCategory(id: 1, name: 'Appetizers', sortOrder: 1),
    const MenuCategory(id: 2, name: 'Main Course', sortOrder: 2),
    const MenuCategory(id: 3, name: 'Drinks', sortOrder: 3),
  ];

  return MenuResponse(
    restaurant: Restaurant(
      id: 'R001',
      name: 'Sushi Zen',
      tableId: tableId ?? 'T001',
    ),
    categories: categories,
    items: const [
      MenuItem(
        id: 1,
        name: 'Edamame',
        description: 'Steamed soybeans with sea salt',
        priceCents: 599,
        categoryId: 1,
        imageUrl: null,
        customizationGroups: [
          CustomizationGroup(
            id: 1,
            name: 'Seasoning',
            required: false,
            maxSelections: 2,
            options: [
              CustomizationOption(
                id: 1,
                name: 'Sea Salt',
                priceModifierCents: 0,
              ),
              CustomizationOption(
                id: 2,
                name: 'Truffle Salt',
                priceModifierCents: 150,
              ),
              CustomizationOption(
                id: 3,
                name: 'Chili Flakes',
                priceModifierCents: 50,
              ),
            ],
          ),
        ],
      ),
      MenuItem(
        id: 2,
        name: 'Salmon Sashimi',
        description: 'Fresh Norwegian salmon, 8 pieces',
        priceCents: 1699,
        categoryId: 2,
        imageUrl: null,
        customizationGroups: [
          CustomizationGroup(
            id: 2,
            name: 'Size',
            required: true,
            maxSelections: 1,
            options: [
              CustomizationOption(
                id: 4,
                name: 'Regular (8pc)',
                priceModifierCents: 0,
              ),
              CustomizationOption(
                id: 5,
                name: 'Large (12pc)',
                priceModifierCents: 800,
              ),
            ],
          ),
        ],
      ),
      MenuItem(
        id: 3,
        name: 'Green Tea',
        description: 'Hot Japanese green tea',
        priceCents: 350,
        categoryId: 3,
        imageUrl: null,
        customizationGroups: [],
      ),
      MenuItem(
        id: 4,
        name: 'Chicken Ramen',
        description: 'Rich chicken broth with chashu, egg, and noodles',
        priceCents: 1499,
        categoryId: 2,
        imageUrl: null,
        customizationGroups: [
          CustomizationGroup(
            id: 3,
            name: 'Spice Level',
            required: true,
            maxSelections: 1,
            options: [
              CustomizationOption(
                id: 6,
                name: 'Mild',
                priceModifierCents: 0,
              ),
              CustomizationOption(
                id: 7,
                name: 'Medium',
                priceModifierCents: 0,
              ),
              CustomizationOption(
                id: 8,
                name: 'Spicy',
                priceModifierCents: 0,
              ),
              CustomizationOption(
                id: 9,
                name: 'Extra Spicy',
                priceModifierCents: 100,
              ),
            ],
          ),
          CustomizationGroup(
            id: 4,
            name: 'Add-ons',
            required: false,
            maxSelections: 3,
            options: [
              CustomizationOption(
                id: 10,
                name: 'Extra Egg',
                priceModifierCents: 200,
              ),
              CustomizationOption(
                id: 11,
                name: 'Extra Chashu',
                priceModifierCents: 400,
              ),
              CustomizationOption(
                id: 12,
                name: 'Corn',
                priceModifierCents: 100,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
