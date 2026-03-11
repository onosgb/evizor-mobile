import 'package:dio/dio.dart';
import 'package:evizor/models/user_model.dart';
import '../models/registration_model.dart';
import '../models/update_profile_request_model.dart';
import '../models/api_response.dart';
import '../models/api_error_response.dart';
import '../models/login_response.dart';

/// Authentication API service
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Register a new patient account
  ///
  /// Endpoint: POST /auth/register
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<Map<String, dynamic>> register(RegistrationRequest request) async {
    try {
      final requestData = request.toJson();
      final response = await _dio.post('/auth/register', data: requestData);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Login with email and password
  ///
  /// Endpoint: POST /auth/login
  /// Request: { "email": "string", "password": "string" }
  /// Response: { "message": "string", "statusCode": number, "data": { "accessToken": "string", "refreshToken": "string", "user": {...} } }
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final requestData = {'email': email, 'password': password};
      final response = await _dio.post('/auth/login', data: requestData);
      final apiResponse = ApiResponse<LoginResponse>.fromJson(
        response.data,
        (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Refresh access token using refresh token
  ///
  /// Endpoint: POST /auth/refresh-token
  /// Request: { "refreshToken": "string" }
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final requestData = {'refreshToken': refreshToken};
      final response = await _dio.post(
        '/auth/refresh-token',
        data: requestData,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Fetch full user profile
  ///
  /// Endpoint: GET /users/my-profile
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<User> fetchUserProfile() async {
    try {
      final response = await _dio.get('/users/my-profile');

      final apiResponse = ApiResponse<User>.fromJson(
        response.data,
        (json) => User.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Upload profile picture
  ///
  /// Endpoint: POST /users/upload-picture
  /// Request: multipart/form-data with "file" field
  /// Response: { "message": "string", "statusCode": number, "data": { "url": "string" } }
  Future<String> uploadProfilePicture(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/users/upload-picture', data: formData);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data['url'] as String;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Update user profile
  ///
  /// Endpoint: PUT /users/update-profile
  /// Request: UpdateProfileRequest model
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<User> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _dio.put(
        '/users/update-profile',
        data: request.toJson(),
      );
      final apiResponse = ApiResponse<User>.fromJson(
        response.data,
        (json) => User.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Resend email verification OTP
  ///
  /// Endpoint: POST /auth/resend-email-verification
  /// Request: { "email": "string" }
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<void> resendEmailVerification({required String email}) async {
    try {
      final requestData = {'email': email};
      final response = await _dio.post(
        '/auth/resend-email-verification',
        data: requestData,
      );

      if (!response.data['status']) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Verify email with OTP code
  ///
  /// Endpoint: POST /auth/verify-email
  /// Request: { "email": "string", "token": "string" }
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otpCode,
  }) async {
    try {
      final requestData = {'email': email, 'token': otpCode};
      final response = await _dio.post('/auth/verify-email', data: requestData);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Request password reset OTP
  ///
  /// Endpoint: POST /auth/forgot-password
  /// Request: { "email": "string" }
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<void> forgotPassword({required String email}) async {
    try {
      final requestData = {'email': email};
      final response = await _dio.post(
        '/auth/forgot-password',
        data: requestData,
      );

      if (!response.data['status']) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Verify password reset OTP
  ///
  /// Endpoint: POST /auth/verify-reset-password
  /// Request: { "email": "string", "token": "string" }
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<Map<String, dynamic>> verifyResetPasswordOTP({
    required String email,
    required String otpCode,
  }) async {
    try {
      final requestData = {'email': email, 'token': otpCode};
      final response = await _dio.post(
        '/auth/verify-reset-password',
        data: requestData,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Resend password reset OTP
  ///
  /// Endpoint: POST /auth/resend-password-reset
  /// Request: { "email": "string" }
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<void> resendPasswordReset({required String email}) async {
    try {
      final requestData = {'email': email};
      final response = await _dio.post(
        '/auth/resend-password-reset',
        data: requestData,
      );

      if (!response.data['status']) {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Toggle Two-Factor Authentication
  ///
  /// Endpoint: PUT /users/update-profile
  /// Request: { "isTwoFAEnabled": bool }
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<Map<String, dynamic>> toggle2FA({required bool enable}) async {
    try {
      final requestData = {'enabled': enable};
      final response = await _dio.put('/users/enable-2fa', data: requestData);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Reset password with OTP token
  ///
  /// Endpoint: POST /auth/reset-password
  /// Request: { "token": "string", "newPassword": "string" }
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      final requestData = {
        'email': email,
        'token': token,
        'newPassword': newPassword,
      };
      final response = await _dio.post(
        '/auth/reset-password',
        data: requestData,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Logout user
  ///
  /// Endpoint: POST /auth/logout
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<void> logout() async {
    try {
      final response = await _dio.post('/auth/logout');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      // Silently fail if logout endpoint fails - still clear local data
      // This ensures user can logout even if network is unavailable
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      // Silently fail - still allow local logout
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Change password for authenticated user
  ///
  /// Endpoint: POST /auth/change-password
  /// Request: { "oldPassword": "string", "newPassword": "string" }
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final requestData = {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      };
      await _dio.post('/auth/change-password', data: requestData);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Verify 2FA OTP
  ///
  /// Endpoint: POST /auth/verify-2fa
  /// Request: { "email": "string", "token": "string" }
  /// Response: LoginResponse
  Future<LoginResponse> verify2FA({
    required String email,
    required String otpCode,
  }) async {
    try {
      final requestData = {'email': email, 'token': otpCode};
      final response = await _dio.post('/auth/verify-2fa', data: requestData);
      final apiResponse = ApiResponse<LoginResponse>.fromJson(
        response.data,
        (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Resend 2FA OTP
  ///
  /// Endpoint: POST /auth/resend-2fa
  /// Request: { "email": "string" }
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<Map<String, dynamic>> resend2FA({required String email}) async {
    try {
      final requestData = {'email': email};
      final response = await _dio.post('/auth/resend-2fa', data: requestData);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorResponse = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorResponse.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
