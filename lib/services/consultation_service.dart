import 'package:dio/dio.dart';
import 'api_client.dart';

/// Consultation API service
class ConsultationService {
  final Dio _dio = ApiClient().dio;

  /// Fetch all available symptoms
  ///
  /// Endpoint: GET /symptoms
  Future<List<String>> fetchSymptoms() async {
    try {
      final response = await _dio.get('/symtomps/tenant');

      if (response.data is List) {
        // If response is a list of strings
        final symptoms = (response.data as List)
            .map<String>((item) => item.toString())
            .toList();
        return symptoms;
      } else if (response.data is Map<String, dynamic>) {
        // If response is wrapped in a data object
        final data = response.data as Map<String, dynamic>;
        if (data['data'] is List) {
          final symptoms = <String>[];
          for (final item in data['data'] as List) {
            // Handle both string and object formats
            if (item is String) {
              symptoms.add(item);
            } else if (item is Map<String, dynamic>) {
              symptoms.add(item['name'] ?? item['symptom'] ?? item.toString());
            } else {
              symptoms.add(item.toString());
            }
          }
          return symptoms;
        } else if (data['symptoms'] is List) {
          final symptoms = <String>[];
          for (final item in data['symptoms'] as List) {
            if (item is String) {
              symptoms.add(item);
            } else if (item is Map<String, dynamic>) {
              symptoms.add(item['name'] ?? item['symptom'] ?? item.toString());
            } else {
              symptoms.add(item.toString());
            }
          }
          return symptoms;
        }
      }

      throw Exception('Unexpected response format');
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
