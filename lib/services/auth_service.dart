import 'package:dio/dio.dart';
import '../models/registration_model.dart';

/// Authentication API service
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

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

  /// Refresh access token using refresh token
  ///
  /// Endpoint: POST /auth/refresh
  /// Request: { "refreshToken": "string" }
  /// Response: { "data": { "accessToken": "string", "refreshToken": "string" } }
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final requestData = {'refreshToken': refreshToken};

      final response = await _dio.post('/auth/refresh', data: requestData);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        throw Exception(
          errorData?['message'] ??
              errorData?['error'] ??
              'Token refresh failed. Please login again.',
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

  /// Fetch full user profile
  ///
  /// Endpoint: GET /auth/profile or GET /users/me
  /// Response: { "data": { ...full user profile... } }
  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        throw Exception(
          errorData?['message'] ??
              errorData?['error'] ??
              'Failed to fetch user profile.',
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

  /// Resend email verification OTP
  ///
  /// Endpoint: POST /auth/resend-email-verification
  /// Request: { "email": "string" }
  /// Response: { "message": "string" }
  Future<Map<String, dynamic>> resendEmailVerification({
    required String email,
  }) async {
    try {
      // Log data before sending
      final requestData = {'email': email};
      final response = await _dio.post(
        '/auth/resend-email-verification',
        data: requestData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        throw Exception(
          errorData?['message'] ??
              errorData?['error'] ??
              'Failed to resend verification code. Please try again.',
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

  /// Request password reset OTP
  ///
  /// Endpoint: POST /auth/forgot-password
  /// Request: { "email": "string" }
  /// Response: { "message": "string" }
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      // Log data before sending
      final requestData = {'email': email};

      final response = await _dio.post(
        '/auth/forgot-password',
        data: requestData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        throw Exception(
          errorData?['message'] ??
              errorData?['error'] ??
              'Failed to send password reset code. Please try again.',
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

  /// Verify password reset OTP
  ///
  /// Endpoint: POST /auth/verify-reset-password
  /// Request: { "email": "string", "token": "string" }
  /// Response: { "message": "string" }
  Future<Map<String, dynamic>> verifyResetPasswordOTP({
    required String email,
    required String otpCode,
  }) async {
    try {
      // Log data before sending
      final requestData = {'email': email, 'token': otpCode};
      final response = await _dio.post(
        '/auth/verify-reset-password',
        data: requestData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        throw Exception(
          errorData?['message'] ??
              errorData?['error'] ??
              'Invalid verification code. Please try again.',
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

  /// Resend password reset OTP
  ///
  /// Endpoint: POST /auth/resend-password-reset
  /// Request: { "email": "string" }
  /// Response: { "message": "string" }
  Future<Map<String, dynamic>> resendPasswordReset({
    required String email,
  }) async {
    try {
      // Log data before sending
      final requestData = {'email': email};
      final response = await _dio.post(
        '/auth/resend-password-reset',
        data: requestData,
      );

      // Handle both String and Map responses
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        return {'message': response.data as String};
      } else {
        return {'message': 'Password reset code sent successfully'};
      }
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        String errorMessage;
        if (errorData is Map<String, dynamic>) {
          errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              'Failed to resend password reset code. Please try again.';
        } else if (errorData is String) {
          errorMessage = errorData;
        } else {
          errorMessage =
              'Failed to resend password reset code. Please try again.';
        }
        throw Exception(errorMessage);
      } else {
        // Network or other error
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Reset password with OTP token
  ///
  /// Endpoint: POST /auth/reset-password
  /// Request: { "token": "string", "newPassword": "string" }
  /// Response: { "message": "string" }
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      // Log data before sending
      final requestData = {'token': token, 'newPassword': newPassword};

      final response = await _dio.post(
        '/auth/reset-password',
        data: requestData,
      );

      // Handle both String and Map responses
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        return {'message': response.data as String};
      } else {
        return {'message': 'Password reset successfully'};
      }
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        String errorMessage;
        if (errorData is Map<String, dynamic>) {
          errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              'Password reset failed. Please try again.';
        } else if (errorData is String) {
          errorMessage = errorData;
        } else {
          errorMessage = 'Password reset failed. Please try again.';
        }
        throw Exception(errorMessage);
      } else {
        // Network or other error
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
