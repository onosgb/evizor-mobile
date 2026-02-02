import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Dio client configuration for API requests
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('onRequest');
          // Log request details
          print('═══════════════════════════════════════════════════════════');
          print(
            'REQUEST[${options.method}] => ${options.baseUrl}${options.path}',
          );
          print('Headers: ${options.headers}');
          if (options.data != null) {
            print('Request Body:');
            if (options.data is Map) {
              // Pretty print JSON-like data
              options.data.forEach((key, value) {
                print('  $key: $value');
              });
            } else {
              print('  ${options.data}');
            }
          }
          if (options.queryParameters.isNotEmpty) {
            print('Query Parameters: ${options.queryParameters}');
          }
          print('═══════════════════════════════════════════════════════════');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response details
          print('═══════════════════════════════════════════════════════════');
          print(
            'RESPONSE[${response.statusCode}] => ${response.requestOptions.path}',
          );
          if (response.data != null) {
            print('Response Body:');
            if (response.data is Map) {
              response.data.forEach((key, value) {
                print('  $key: $value');
              });
            } else {
              print('  ${response.data}');
            }
          }
          print('═══════════════════════════════════════════════════════════');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          // Log error details
          print('═══════════════════════════════════════════════════════════');
          print(
            'ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}',
          );
          print('ERROR MESSAGE: ${error.message}');
          if (error.response?.data != null) {
            print('Error Response Body:');
            if (error.response!.data is Map) {
              error.response!.data.forEach((key, value) {
                print('  $key: $value');
              });
            } else {
              print('  ${error.response!.data}');
            }
          }
          print('═══════════════════════════════════════════════════════════');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// Update authorization header with token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authorization header
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
