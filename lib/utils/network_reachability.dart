import 'package:dio/dio.dart';
import 'package:ipotapp/models/api_error.model.dart';

/// Whether [error] likely means the device cannot reach the server right now.
/// Used to fall back to cached menu or queued checkout without treating API
/// validation errors as offline.
bool isUnreachableError(Object error) {
  if (error is ApiError) {
    return error.code == 'network_error' ||
        error.code == 'timeout' ||
        error.code == 'gateway_timeout';
  }
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        return error.response == null;
      default:
        return false;
    }
  }
  return false;
}
