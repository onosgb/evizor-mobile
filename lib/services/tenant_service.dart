import 'package:dio/dio.dart';
import '../models/tenant_model.dart';
import 'api_client.dart';

/// Tenant API service
class TenantService {
  final Dio _dio = ApiClient().dio;

  /// Fetch all available tenants
  ///
  /// Endpoint: GET /tenant/all-tenants
  Future<List<Tenant>> fetchAllTenants() async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 FETCHING ALL TENANTS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Endpoint: GET /tenant/all-tenants');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _dio.get('/tenant/all-tenants');

      if (response.data is List) {
        final tenants = (response.data as List)
            .map((json) => Tenant.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ Successfully fetched ${tenants.length} tenants');
        return tenants;
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.response != null) {
        // Server responded with error status
        final errorData = e.response?.data;
        throw Exception(
          errorData?['message'] ??
              errorData?['error'] ??
              'Failed to fetch tenants. Please try again.',
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
