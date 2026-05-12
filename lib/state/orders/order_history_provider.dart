import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/models/order.model.dart';
import 'package:ipotapp/screens/menu/providers/menu.provider.dart';
import 'package:ipotapp/state/core/order_repository_provider.dart';

/// Server order history for the table from the current menu session.
final tableOrderHistoryProvider = FutureProvider.autoDispose<List<Order>>((
  ref,
) async {
  final menuAsync = ref.watch(menuResponseProvider);
  final menu = menuAsync.valueOrNull;
  if (menu == null) return const [];
  final tid = menu.restaurant.tableId;
  if (tid.isEmpty) return const [];
  return ref.read(orderRepositoryProvider).listOrdersForTable(tableId: tid);
});
