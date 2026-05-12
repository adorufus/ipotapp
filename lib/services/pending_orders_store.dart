import 'dart:convert';

import 'package:ipotapp/models/order.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingOrderEntry {
  final String localId;
  final OrderRequest request;

  const PendingOrderEntry({required this.localId, required this.request});

  Map<String, dynamic> toJson() => {
    'local_id': localId,
    'request': request.toJson(),
  };

  factory PendingOrderEntry.fromJson(Map<String, dynamic> json) {
    return PendingOrderEntry(
      localId: (json['local_id'] ?? '').toString(),
      request: OrderRequest.fromJson(
        (json['request'] as Map).cast<String, dynamic>(),
      ),
    );
  }
}

/// Orders waiting for the same [OrderRepository.createOrder] call when online.
class PendingOrdersStore {
  static const _key = 'ipot_pending_orders_v1';

  Future<List<PendingOrderEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((m) => PendingOrderEntry.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(PendingOrderEntry entry) async {
    final all = await loadAll();
    final next = [...all.where((e) => e.localId != entry.localId), entry];
    await _saveAll(next);
  }

  Future<void> remove(String localId) async {
    final all = await loadAll();
    final next = all.where((e) => e.localId != localId).toList();
    await _saveAll(next);
  }

  Future<void> _saveAll(List<PendingOrderEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
