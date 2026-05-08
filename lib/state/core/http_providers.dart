import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/dio_http_service.dart';
import 'network_providers.dart';

final httpServiceProvider = Provider<DioHttpService>((ref) {
  return DioHttpService(ref.watch(dioProvider));
});

