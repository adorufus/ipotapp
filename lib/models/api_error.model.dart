class ApiErrorResponse {
  final ApiError error;
  const ApiErrorResponse({required this.error});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      error: ApiError.fromJson((json['error'] as Map).cast<String, dynamic>()),
    );
  }

  Map<String, dynamic> toJson() => {'error': error.toJson()};
}

class ApiError {
  final String code;
  final String message;
  final List<ApiErrorDetail> details;

  const ApiError({
    required this.code,
    required this.message,
    required this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final detailsRaw = json['details'];
    return ApiError(
      code: (json['code'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      details: detailsRaw is List
          ? detailsRaw
                .whereType<Map>()
                .map((m) => ApiErrorDetail.fromJson(m.cast<String, dynamic>()))
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'details': details.map((d) => d.toJson()).toList(),
  };
}

class ApiErrorDetail {
  final String field;
  final String message;
  const ApiErrorDetail({required this.field, required this.message});

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) {
    return ApiErrorDetail(
      field: (json['field'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'field': field, 'message': message};
}
