import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/services/menu_cache_store.dart';
import 'package:ipotapp/services/pending_orders_store.dart';

final menuCacheStoreProvider = Provider<MenuCacheStore>((ref) {
  return MenuCacheStore();
});

final pendingOrdersStoreProvider = Provider<PendingOrdersStore>((ref) {
  return PendingOrdersStore();
});
