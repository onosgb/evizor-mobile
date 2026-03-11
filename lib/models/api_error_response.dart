class ApiErrorResponse {
  final bool success;
  final String message;
  final int? statusCode;
  final dynamic error;

  ApiErrorResponse({
    this.success = false,
    required this.message,
    this.statusCode,
    this.error,
  });

  factory ApiErrorResponse.fromJson(dynamic json) {
    if (json is String) {
      return ApiErrorResponse(message: json);
    }

    if (json is Map<String, dynamic>) {
      return ApiErrorResponse(
        message: _extractMessage(json['message']),
        statusCode: json['statusCode'] as int?,
        error: json['error'],
      );
    }

    return ApiErrorResponse(message: 'An unexpected error occurred');
  }

  static String _extractMessage(dynamic message) {
    if (message == null) return 'Unknown error';

    if (message is String) {
      return message;
    }

    if (message is List) {
      return message
          .where((item) => item != null)
          .map((item) => item.toString())
          .join(', ');
    }

    return message.toString();
  }

  @override
  String toString() => message;
}
