import 'dart:convert';

import 'package:ipotapp/models/menu_response.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists last successful [MenuResponse] per table for offline use.
class MenuCacheStore {
  static const _prefix = 'ipot_menu_v1_';

  String _key(String tableKey) => '$_prefix$tableKey';

  Future<MenuResponse?> load(String tableKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(tableKey));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return null;
      return MenuResponse.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(String tableKey, MenuResponse menu) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(tableKey), jsonEncode(menu.toJson()));
  }
}
