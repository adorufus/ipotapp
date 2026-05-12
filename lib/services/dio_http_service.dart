import 'dart:async';

import 'package:dio/dio.dart';

import '../models/api_error.model.dart';

class DioHttpService {
  final Dio dio;

  DioHttpService(this.dio);

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  ApiErrorResponse? tryParseApiError(Object error) {
    if (error is! DioException) return null;
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      try {
        return ApiErrorResponse.fromJson(data);
      } catch (_) {
        return null;
      }
    }

    if (data is Map) {
      try {
        return ApiErrorResponse.fromJson(data.cast<String, dynamic>());
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  /// Maps [DioException] to [ApiError] when there is no JSON error body from the API.
  ApiError apiErrorFromDio(DioException e) {
    final jsonError = tryParseApiError(e);
    if (jsonError != null) return jsonError.error;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(
          code: 'timeout',
          message:
              'The connection timed out. Check your network and try again.',
          details: [],
        );
      case DioExceptionType.cancel:
        return const ApiError(
          code: 'cancelled',
          message: 'Request was cancelled.',
          details: [],
        );
      default:
        break;
    }

    final status = e.response?.statusCode;
    if (status == 504) {
      return const ApiError(
        code: 'gateway_timeout',
        message: 'The server took too long to respond. Please try again.',
        details: [],
      );
    }

    return ApiError(
      code: 'network_error',
      message: (e.message != null && e.message!.isNotEmpty)
          ? e.message!
          : 'Request failed',
      details: const [],
    );
  }
}

