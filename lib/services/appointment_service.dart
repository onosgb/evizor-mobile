import 'package:dio/dio.dart';
import '../models/api_error_response.dart';
import '../models/api_response.dart';
import '../models/appointment.dart';
import '../models/prescription_model.dart';
import 'api_client.dart';

/// Service for managing appointments
class AppointmentService {
  final Dio _dio = ApiClient().dio;

  /// Fetch the latest appointment for the current patient.
  /// Returns null if the patient has no appointments yet.
  ///
  /// Endpoint: GET /appointments/patient/latest
  Future<Appointment?> fetchLatestAppointment() async {
    try {
      final response = await _dio.get('/appointments/latest');
      final data = response.data;
      // API returns null / empty body when no appointment exists
      if (data == null || data['data'] == null) return null;

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) return null;

      return Appointment.fromJson(apiResponse.data);
    } on DioException catch (e) {
      // 404 means no appointment exists yet — treat as null
      if (e.response?.statusCode == 404) return null;
      if (e.response != null) {
        final errorData = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorData.message);
      }
      throw Exception(
        e.message ?? 'Network error. Please check your connection.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Fetch all appointments history for the current user
  ///
  /// Endpoint: GET /appointments/history
  Future<List<Appointment>> fetchAppointments({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/appointments/history',
        queryParameters: {'page': page, 'limit': limit},
      );
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorData.message);
      } else {
        throw Exception(
          e.message ?? 'Network error. Please check your connection.',
        );
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Fetch Dyte token/URL for an active appointment (Session Recovery)
  ///
  /// Endpoint: GET /appointments/:id/token
  Future<String> fetchAppointmentToken(String appointmentId) async {
    try {
      final response = await _dio.get('/appointments/$appointmentId/token');
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      // Return the meetingUrl if available, otherwise token
      return apiResponse.data['meetingUrl'] ?? apiResponse.data['token'] ?? '';
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorData.message);
      }
      throw Exception(e.message ?? 'Failed to fetch appointment token');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  /// Patient accepts an appointment and gets their Dyte token.
  /// Per the client guide: patient calls /accept, doctor calls /start.
  ///
  /// Endpoint: POST /appointments/:id/accept
  Future<String> acceptAppointment(String appointmentId) async {
    try {
      final response = await _dio.post('/appointments/$appointmentId/accept');
      final data = response.data;
      // API wraps the result in { success, data: { dyteToken, meetingUrl } }
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      // Prefer dyteToken, fall back to meetingUrl if backend changes shape
      final token =
          apiResponse.data['dyteToken'] ?? apiResponse.data['meetingUrl'] ?? '';
      if (token.isEmpty) throw Exception('No Dyte token returned by server.');
      return token;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorData.message);
      }
      throw Exception(e.message ?? 'Failed to start video call');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  /// Reject/Miss an appointment call
  ///
  /// Endpoint: POST /appointments/:id/missed
  Future<void> rejectAppointment(String appointmentId) async {
    try {
      await _dio.post('/appointments/$appointmentId/missed');
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorData.message);
      }
      throw Exception(e.message ?? 'Failed to reject appointment');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  /// Cancel an appointment
  ///
  /// Endpoint: PUT /appointments/:id/cancel
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _dio.put('/appointments/$appointmentId/cancel');
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorData.message);
      }
      throw Exception(e.message ?? 'Failed to cancel appointment');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  /// Fetch prescription for an appointment
  ///
  /// Endpoint: GET /clinical-records/appointment/:id/prescription
  Future<Prescription> fetchPrescription(String appointmentId) async {
    print('Fetching prescription for appointment: $appointmentId');
    try {
      final response = await _dio.get(
        '/clinical-records/appointment/$appointmentId/prescription',
      );
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return Prescription.fromJson(apiResponse.data);
    } on DioException catch (e) {
      if (e.response != null) {
        // The error response might not follow ApiErrorResponse if it's a different module
        try {
          final errorData = ApiErrorResponse.fromJson(e.response!.data);
          throw Exception(errorData.message);
        } catch (_) {
          throw Exception(
            e.response?.data['message'] ?? 'Failed to fetch prescription',
          );
        }
      }
      throw Exception(e.message ?? 'Failed to fetch prescription');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}
