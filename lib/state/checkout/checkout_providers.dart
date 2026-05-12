import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/models/api_error.model.dart';
import 'package:ipotapp/models/menu_response.model.dart';
import 'package:ipotapp/models/order.model.dart';
import 'package:ipotapp/repositories/order_repository.dart';
import 'package:ipotapp/services/offline_order_builder.dart';
import 'package:ipotapp/services/pending_orders_store.dart';
import 'package:ipotapp/state/core/local_store_providers.dart';
import 'package:ipotapp/state/core/order_repository_provider.dart';
import 'package:ipotapp/utils/network_reachability.dart';

class CheckoutState {
  final bool submitting;
  final String? submitError;
  final Order? lastOrder;

  const CheckoutState({
    required this.submitting,
    required this.submitError,
    required this.lastOrder,
  });

  factory CheckoutState.initial() => const CheckoutState(
    submitting: false,
    submitError: null,
    lastOrder: null,
  );

  CheckoutState copyWith({
    bool? submitting,
    String? submitError,
    bool clearSubmitError = false,
    Order? lastOrder,
    bool clearLastOrder = false,
  }) {
    return CheckoutState(
      submitting: submitting ?? this.submitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      lastOrder: clearLastOrder ? null : (lastOrder ?? this.lastOrder),
    );
  }
}

final checkoutControllerProvider =
    StateNotifierProvider<CheckoutController, CheckoutState>((ref) {
      return CheckoutController(
        ref.watch(orderRepositoryProvider),
        ref.watch(pendingOrdersStoreProvider),
      );
    });

class CheckoutController extends StateNotifier<CheckoutState> {
  final OrderRepository _orders;
  final PendingOrdersStore _pending;

  CheckoutController(this._orders, this._pending) : super(CheckoutState.initial());

  void clearDraft() {
    state = CheckoutState.initial();
  }

  void clearSubmitError() {
    state = state.copyWith(clearSubmitError: true);
  }

  /// Place an order with an already-built request payload.
  ///
  /// Always calls [OrderRepository.createOrder] first. On unreachable errors,
  /// queues the same payload for [OrderOutboundSync] and returns a local
  /// placeholder [Order] so the flow can finish offline.
  Future<OrderResponse> placeOrder({
    required OrderRequest request,
    required MenuResponse menuSnapshot,
    CancelToken? cancelToken,
  }) async {
    if (state.submitting) {
      throw StateError('Checkout already in progress');
    }
    state = state.copyWith(submitting: true, clearSubmitError: true);
    try {
      final res = await _orders.createOrder(
        request: request,
        cancelToken: cancelToken,
      );
      state = state.copyWith(
        submitting: false,
        lastOrder: res.order,
        clearSubmitError: true,
      );
      return res;
    } on ApiError catch (e) {
      if (isUnreachableError(e)) {
        final localId = 'local_${DateTime.now().microsecondsSinceEpoch}';
        final offlineOrder = buildOfflinePlaceholderOrder(
          localId: localId,
          request: request,
          menu: menuSnapshot,
        );
        await _pending.add(
          PendingOrderEntry(localId: localId, request: request),
        );
        state = state.copyWith(
          submitting: false,
          lastOrder: offlineOrder,
          clearSubmitError: true,
        );
        return OrderResponse(order: offlineOrder);
      }
      state = state.copyWith(submitting: false, submitError: e.message);
      rethrow;
    } catch (e) {
      if (isUnreachableError(e)) {
        final localId = 'local_${DateTime.now().microsecondsSinceEpoch}';
        final offlineOrder = buildOfflinePlaceholderOrder(
          localId: localId,
          request: request,
          menu: menuSnapshot,
        );
        await _pending.add(
          PendingOrderEntry(localId: localId, request: request),
        );
        state = state.copyWith(
          submitting: false,
          lastOrder: offlineOrder,
          clearSubmitError: true,
        );
        return OrderResponse(order: offlineOrder);
      }
      state = state.copyWith(
        submitting: false,
        submitError: e.toString(),
      );
      rethrow;
    }
  }

  /// Fetch latest server state for an order.
  Future<OrderResponse> refreshOrder({
    required String orderId,
    CancelToken? cancelToken,
  }) async {
    if (state.submitting) {
      throw StateError('Checkout already in progress');
    }
    state = state.copyWith(submitting: true, clearSubmitError: true);
    try {
      final res = await _orders.fetchOrder(
        orderId: orderId,
        cancelToken: cancelToken,
      );
      state = state.copyWith(
        submitting: false,
        lastOrder: res.order,
        clearSubmitError: true,
      );
      return res;
    } on ApiError catch (e) {
      state = state.copyWith(submitting: false, submitError: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        submitting: false,
        submitError: e.toString(),
      );
      rethrow;
    }
  }

  /// Deletes the order on the server (see [OrderRepository.cancelOrder]).
  Future<void> cancelOrder({
    required String orderId,
    CancelToken? cancelToken,
  }) async {
    if (state.submitting) {
      throw StateError('Checkout already in progress');
    }
    state = state.copyWith(submitting: true, clearSubmitError: true);
    final clearLastOrder = state.lastOrder?.id == orderId;
    try {
      await _orders.cancelOrder(orderId: orderId, cancelToken: cancelToken);
      state = state.copyWith(
        submitting: false,
        clearSubmitError: true,
        clearLastOrder: clearLastOrder,
      );
    } on ApiError catch (e) {
      state = state.copyWith(submitting: false, submitError: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        submitting: false,
        submitError: e.toString(),
      );
      rethrow;
    }
  }
}
