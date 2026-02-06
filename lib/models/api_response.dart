/// Generic API response model
///
/// Wraps API responses in a consistent format:
/// {
///   "message": "Success message" or ["Error 1", "Error 2"],
///   "statusCode": 200,
///   "data": T
/// }
class ApiResponse<T> {
  final String message;
  final int statusCode;
  final T data;

  ApiResponse({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  /// Create ApiResponse from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      message: _extractMessage(json['message']),
      statusCode: json['statusCode'] as int? ?? 200,
      data: fromJsonT(json['data']),
    );
  }

  /// Extract message from either String or List format
  ///
  /// Handles two cases:
  /// - String: "Error message" -> "Error message"
  /// - List: ["Error 1", "Error 2"] -> "Error 1, Error 2"
  static String _extractMessage(dynamic message) {
    if (message == null) return '';

    if (message is String) {
      return message;
    }

    if (message is List) {
      // Join multiple error messages with comma and space
      return message
          .where((item) => item != null)
          .map((item) => item.toString())
          .join(', ');
    }

    // Fallback for unexpected types
    return message.toString();
  }

  /// Convert ApiResponse to JSON
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': toJsonT(data),
    };
  }

  /// Check if response is successful (status code 2xx)
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Generic API response for list/array data
///
/// Wraps API responses containing arrays:
/// {
///   "message": "Success message",
///   "statusCode": 200,
///   "data": [...]
/// }
class ApiListResponse<T> {
  final String message;
  final int statusCode;
  final List<T> data;

  ApiListResponse({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  /// Create ApiListResponse from JSON
  factory ApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final dataList = json['data'] as List? ?? [];
    return ApiListResponse<T>(
      message: ApiResponse._extractMessage(json['message']),
      statusCode: json['statusCode'] as int? ?? 200,
      data: dataList.map((item) => fromJsonT(item)).toList(),
    );
  }

  /// Convert ApiListResponse to JSON
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'message': message,
      'statusCode': statusCode,
      'data': data.map((item) => toJsonT(item)).toList(),
    };
  }

  /// Check if response is successful (status code 2xx)
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Check if data is empty
  bool get isEmpty => data.isEmpty;

  /// Get the number of items in data
  int get length => data.length;
}
