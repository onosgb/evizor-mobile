import 'package:dio/dio.dart';
import '../models/tenant_model.dart';
import '../models/api_response.dart';
import '../models/api_error_response.dart';
import 'api_client.dart';

/// Tenant API service
class TenantService {
  final Dio _dio = ApiClient().dio;

  /// Fetch all available tenants
  ///
  /// Endpoint: GET /tenant/all-tenants
  /// Response: { "message": "string", "statusCode": number, "data": [...] }
  Future<List<Tenant>> fetchAllTenants() async {
    try {
      final response = await _dio.get('/tenant/all-tenants');
      print(response.data);
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw Exception(apiResponse.message);
      }

      // Convert the list of dynamic to list of Tenant
      final tenants = (apiResponse.data)
          .map((json) => Tenant.fromJson(json as Map<String, dynamic>))
          .toList();

      return tenants;
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
