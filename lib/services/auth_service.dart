import 'package:dio/dio.dart';
import '../models/registration_model.dart';
import 'api_client.dart';

/// Authentication API service
class AuthService {
  final Dio _dio = ApiClient().dio;

  /// Register a new patient account
  ///
  /// Endpoint: POST /auth/register
  Future<Map<String, dynamic>> register(RegistrationRequest request) async {
    try {
      // Log data before sending
      final requestData = request.toJson();
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 PREPARING REGISTRATION REQUEST');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Endpoint: POST /auth/register');
      print('Request Data:');
      requestData.forEach((key, value) {
        // Mask password for security
        if (key == 'password') {
          print('  $key: ${'*' * (value.toString().length)}');
        } else {
          print('  $key: $value');
        }
      });
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _dio.post('/auth/register', data: requestData);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        throw Exception(
          errorData?['message'] ??
              errorData?['error'] ??
              'Registration failed. Please try again.',
        );
      } else {
        // Network or other error
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Login with email and password
  ///
  /// Endpoint: POST /auth/login
  /// Request: { "email": "string", "password": "string" }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Log data before sending
      final requestData = {'email': email, 'password': password};
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 PREPARING LOGIN REQUEST');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Endpoint: POST /auth/login');
      print('Request Data:');
      requestData.forEach((key, value) {
        // Mask password for security
        if (key == 'password') {
          print('  $key: ${'*' * (value.toString().length)}');
        } else {
          print('  $key: $value');
        }
      });
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _dio.post('/auth/login', data: requestData);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        throw Exception(
          errorData?['message'] ??
              errorData?['error'] ??
              'Login failed. Please check your credentials.',
        );
      } else {
        // Network or other error
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Verify email with OTP code
  ///
  /// Endpoint: POST /auth/verify-email
  /// Response: { "token": "string", "email": "string" }
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otpCode,
  }) async {
    try {
      // Log data before sending
      final requestData = {'email': email, 'token': otpCode};
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 PREPARING EMAIL VERIFICATION REQUEST');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Endpoint: POST /auth/verify-email');
      print('Request Data:');
      requestData.forEach((key, value) {
        print('  $key: $value');
      });
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _dio.post('/auth/verify-email', data: requestData);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        throw Exception(
          errorData?['message'] ??
              errorData?['error'] ??
              'Email verification failed. Please try again.',
        );
      } else {
        // Network or other error
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
