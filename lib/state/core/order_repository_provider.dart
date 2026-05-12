import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/repositories/order_repository.dart';
import 'package:ipotapp/state/core/http_providers.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(httpServiceProvider));
});
