import 'package:dio/dio.dart';
import '../models/symptom_model.dart';
import 'api_client.dart';

/// Consultation API service
class ConsultationService {
  final Dio _dio = ApiClient().dio;

  /// Fetch all available symptoms
  ///
  /// Endpoint: GET /symptoms
  /// Fetch all available symptoms
  ///
  /// Endpoint: GET /symptoms
  Future<List<Symptom>> fetchSymptoms() async {
    try {
      final response = await _dio.get('/symtomps/tenant');
      // If response is a list
      final data = response.data['data'] as List;
      return data.map<Symptom>((item) {
        if (item is Map<String, dynamic>) {
          return Symptom.fromJson(item);
        }
        // Fallback if item is not a map (unexpected)
        return Symptom(id: item.toString(), name: item.toString());
      }).toList();
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        throw Exception(
          errorData?['message'] ??
              errorData?['error'] ??
              'Failed to fetch symptoms. Please try again.',
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

  /// Create a new appointment with symptoms
  ///
  /// Endpoint: POST /api/v1/appointments
  /// Request: {
  ///   "symptoms": {
  ///     "tags": ["symptomId-1", "symptomId-2"],
  ///     "description": "string",
  ///     "duration": "string",
  ///     "severity": number
  ///   }
  /// }
  Future<Map<String, dynamic>> createAppointment({
    required List<String> symptomIds,
    required String description,
    required String duration,
    required int severity,
  }) async {
    try {
      final requestData = {
        'symptoms': {
          'tags': symptomIds,
          'description': description,
          'duration': duration,
          'severity': severity,
        },
      };

      final response = await _dio.post('/appointments', data: requestData);

      // Handle both String and Map responses
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        return {'message': response.data as String};
      } else {
        return {'message': 'Appointment created successfully'};
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
              'Failed to create appointment. Please try again.';
        } else if (errorData is String) {
          errorMessage = errorData;
        } else {
          errorMessage = 'Failed to create appointment. Please try again.';
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
