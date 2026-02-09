import 'package:dio/dio.dart';
import 'package:evizor/models/api_error_response.dart';
import '../models/symptom_model.dart';
import '../models/appointment_model.dart';
import '../models/api_response.dart';
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
      final response = await _dio.get('/symptoms/tenant');
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
        final errorData = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorData.message);
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

  /// Endpoint: POST /appointments
  /// Request: { symptoms, description, duration, severity, attachments? }
  /// Response: { "message": "string", "statusCode": number, "data": {...} }
  Future<Map<String, dynamic>> createAppointment(
    Appointment appointment,
  ) async {
    try {
      final Map<String, dynamic> mapWithFiles = {
        'symptoms ': appointment.symptoms,
        'description': appointment.description,
        'duration': appointment.duration,
        'severity': appointment.severity,
      };

      if (appointment.attachments != null &&
          appointment.attachments!.isNotEmpty) {
        final files = <MultipartFile>[];
        for (var path in appointment.attachments!) {
          files.add(await MultipartFile.fromFile(path));
        }
        mapWithFiles['attachments'] = files;
      }

      final formData = FormData.fromMap(mapWithFiles);
      print('Form Data: $formData');

      final response = await _dio.post('/appointments', data: formData);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      return apiResponse.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Extract error message directly from response
        final errorData = ApiErrorResponse.fromJson(e.response!.data);
        throw Exception(errorData.message);
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
