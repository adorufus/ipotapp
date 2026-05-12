import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/models/api_error.model.dart';
import 'package:ipotapp/state/core/connectivity_providers.dart';
import 'package:ipotapp/state/core/device_network_status.dart';
import 'package:ipotapp/state/core/local_store_providers.dart';
import 'package:ipotapp/state/core/order_repository_provider.dart';
import 'package:ipotapp/utils/network_reachability.dart';

final orderOutboundSyncProvider = Provider<OrderOutboundSync>((ref) {
  return OrderOutboundSync(ref);
});

/// Sends queued [PendingOrdersStore] entries using the same [OrderRepository.createOrder] path.
class OrderOutboundSync {
  OrderOutboundSync(this._ref);

  final Ref _ref;
  bool _busy = false;

  Future<void> flushIfOnline() async {
    final status = _ref.read(deviceNetworkStatusProvider).valueOrNull;
    if (status == null || status == DeviceNetworkStatus.offline) return;
    if (_busy) return;
    _busy = true;
    try {
      final store = _ref.read(pendingOrdersStoreProvider);
      final repo = _ref.read(orderRepositoryProvider);
      final pending = await store.loadAll();
      for (final p in pending) {
        try {
          await repo.createOrder(request: p.request);
          await store.remove(p.localId);
        } on ApiError catch (e) {
          if (isUnreachableError(e)) break;
          break;
        }
      }
    } finally {
      _busy = false;
    }
  }
}
