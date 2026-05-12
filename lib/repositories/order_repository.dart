import 'package:dio/dio.dart';
import 'package:ipotapp/models/order.model.dart';
import 'package:ipotapp/services/dio_http_service.dart';

class OrderRepository {
  final DioHttpService _http;
  const OrderRepository(this._http);

  Future<OrderResponse> createOrder({
    required OrderRequest request,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _http.post<dynamic>(
        '/orders',
        data: request.toJson(),
        cancelToken: cancelToken,
      );

      return _parseOrderResponse(res.data);
    } on DioException catch (e) {
      _throwApiFromDio(e);
    }
  }

  Future<OrderResponse> fetchOrder({
    required String orderId,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _http.get<dynamic>(
        '/orders/$orderId',
        cancelToken: cancelToken,
      );
      return _parseOrderResponse(res.data);
    } on DioException catch (e) {
      _throwApiFromDio(e);
    }
  }

  /// Lists orders for a table (`GET /orders?table_id=`).
  Future<List<Order>> listOrdersForTable({
    required String tableId,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _http.get<dynamic>(
        '/orders',
        queryParameters: {'table_id': tableId},
        cancelToken: cancelToken,
      );
      return _parseOrdersListResponse(res.data).orders;
    } on DioException catch (e) {
      _throwApiFromDio(e);
    }
  }

  /// Removes the order on the server (mock API: `DELETE /orders/:id`).
  Future<void> cancelOrder({
    required String orderId,
    CancelToken? cancelToken,
  }) async {
    try {
      await _http.delete<dynamic>(
        '/orders/$orderId',
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      _throwApiFromDio(e);
    }
  }

  OrderResponse _parseOrderResponse(dynamic data) {
    if (data is Map<String, dynamic>) return OrderResponse.fromJson(data);
    if (data is Map) {
      return OrderResponse.fromJson(data.cast<String, dynamic>());
    }
    throw StateError('Unexpected response type: ${data.runtimeType}');
  }

  OrdersListResponse _parseOrdersListResponse(dynamic data) {
    if (data is Map<String, dynamic>) return OrdersListResponse.fromJson(data);
    if (data is Map) {
      return OrdersListResponse.fromJson(data.cast<String, dynamic>());
    }
    throw StateError('Unexpected response type: ${data.runtimeType}');
  }

  Never _throwApiFromDio(DioException e) {
    throw _http.apiErrorFromDio(e);
  }
}
