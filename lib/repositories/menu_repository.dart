import 'package:ipotapp/models/menu_response.model.dart';
import 'package:ipotapp/services/dio_http_service.dart';

class MenuRepository {
  final DioHttpService _http;
  const MenuRepository(this._http);

  Future<MenuResponse> fetchMenu({required String? tableId}) async {
    try {
      final res = await _http.get<dynamic>(
        '/menu',
        queryParameters: {
          if (tableId != null && tableId.isNotEmpty) 'table_id': tableId,
        },
      );

      final data = res.data;
      if (data is Map<String, dynamic>) return MenuResponse.fromJson(data);
      if (data is Map) {
        return MenuResponse.fromJson(data.cast<String, dynamic>());
      }
      throw StateError('Unexpected response type: ${data.runtimeType}');
    } catch (_) {
      // The project doesn’t yet have a menu endpoint wired. Provide a realistic
      // fallback so the UI can be built and reviewed immediately.
      return _mockMenu(tableId: tableId);
    }
  }
}

MenuResponse _mockMenu({required String? tableId}) {
  final categories = <MenuCategory>[
    const MenuCategory(id: 1, name: 'Starters', sortOrder: 1),
    const MenuCategory(id: 2, name: 'Mains', sortOrder: 2),
    const MenuCategory(id: 3, name: 'Drinks', sortOrder: 3),
    const MenuCategory(id: 4, name: 'Desserts', sortOrder: 4),
  ];

  return MenuResponse(
    restaurant: Restaurant(id: 'r1', name: 'Ipot', tableId: tableId ?? '12'),
    categories: categories,
    items: const [
      MenuItem(
        id: 101,
        name: 'Artisanal Smashed Avocado',
        description:
            'Sourdough base, sea salt, organic micro-greens, and a drizzle of local chili oil.',
        priceCents: 1400,
        categoryId: 1,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCEI70zEYTMJx8UVJ8bEi7ldnq-giVjPz8gLgFKF05HC_N9eZtpqmwx76PwSN-jJsXMevcBCMQngFCRBuUn_WffFlc7TeMyKtkfwLNe31twKcEHuxioFLizyYT-Kpq83GHOCbqPA61gCxOW-Gg3wZtgKRbOwPqPIjDheAJQecTlhoHwWZwNq_-Im5wSaEo1XsavN2s8LlufsD41B4tJTlz3S45sY-orECnZ5qB4MBBdehLoGoxVBpT6NsR43Le8hCprfb5GGlnW84M',
        customizationGroups: [],
      ),
      MenuItem(
        id: 102,
        name: 'Honey-Glazed Short Ribs',
        description:
            'Slow-cooked for 12 hours, glazed with wildflower honey and smoked paprika.',
        priceCents: 1850,
        categoryId: 1,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAlWZy12EMY6-tNcqZ0LzNqNAMLj7uhbnilszwLqauJ3B3HqDhp-dF6es9QoAeeGdUDYiePJrob0VqveJBaT-RSvQLoL_vJ0wXt9EijqdIu-NyNREPb827Hexi41aAkJx6rNYqk27fmu1Wl3_l4W4ebtKWtotgvakpWPqUZyoBI3uaPMtzQGsiuovH8fPuStECPvSQzqn8DxSxQqDYl-Pig2Olsu_TCHyHLDP-zglQI3vmxRWxqdpv7roU6theoGR6ojSKhdREolqg',
        customizationGroups: [],
      ),
      MenuItem(
        id: 103,
        name: 'Terracotta Harvest Bowl',
        description:
            'Seasonal grains, roasted chickpeas, feta, and a house-made lemon tahini dressing.',
        priceCents: 1200,
        categoryId: 2,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAzd1qx83oXLhbZy5tnSANVVkItr6lMrNhc4l3c8ie7E_Jo6hcg8ToIg07WaNP2D2O0yIrkA_LZRDWTGfHXEnfu9MYx8pVXqPv_2-4frp9dchWYUoqKlIYtSnuL6sjqvcrvp-q7jiKFawZMTt_X6tiEJQkyENzqBqXSiSypzzXt8NYANXrMcIuUwANvIe6kB_-6eAa0iPCZm4nHJzgz3i5B51i6Ju6fjB3FJVTi9txTDuYZnPI7iCAbgQNDxQATctPLPef1PG-tP4U',
        customizationGroups: [],
      ),
      MenuItem(
        id: 104,
        name: 'Black Truffle Pappardelle',
        description:
            'Hand-cut pasta, shaved Umbrian truffles, and aged parmesan cream sauce.',
        priceCents: 2400,
        categoryId: 2,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDvspRarFPPs8L0ENFycBkKaVKhskygPcrbtN9NmO8KQ1ElSEZwyzCvTBxR0AzLeX0ZcxLlKlSqsq-XmhsTcgioVGTn6C-AVbEpAMoX-ls0DRlMMUEWTLSQDz5uJPoV7e83t_yb9WXK4x2NHvSwjhx_BQS_j6FGmrSUxlPbEjyhJDHE1Th2cQcqCgf2h6V9AqD4rP0m4Qx1zN3pw_KETOcjLRott1k2FJk7F3Jm7_FBo2PPXOVycXQSDKzSzxv_08TzdHpUF-HjGAc',
        customizationGroups: [],
      ),
    ],
  );
}
