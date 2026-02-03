import 'package:dio/dio.dart';
import '../routes/app_router.dart';
import '../utils/app_routes.dart';
import 'auth_service.dart';
import 'storage_service.dart';

/// Interceptor to handle authentication tokens and refresh logic
class AuthInterceptor extends Interceptor {
  final StorageService _storageService = StorageService();
  late final AuthService _authService;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<({RequestOptions requestOptions, ErrorInterceptorHandler handler})>
  _pendingRequests = [];

  AuthInterceptor(this._dio) {
    // Create AuthService with the Dio instance to avoid circular dependency
    _authService = AuthService(_dio);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for auth endpoints
    if (!_isAuthEndpoint(options.path)) {
      final accessToken = await _storageService.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // Skip refresh for auth endpoints (login, register, refresh)
      if (_isAuthEndpoint(requestOptions.path)) {
        return handler.next(err);
      }

      // If already refreshing, queue this request
      if (_isRefreshing) {
        _pendingRequests.add((
          requestOptions: requestOptions,
          handler: handler,
        ));
        return;
      }

      _isRefreshing = true;

      try {
        // Get refresh token
        final refreshToken = await _storageService.getRefreshToken();

        if (refreshToken == null || refreshToken.isEmpty) {
          // No refresh token - logout user
          await _handleLogout();
          return handler.next(err);
        }

        // Try to refresh the token
        final response = await _authService.refreshToken(refreshToken);
        final data = response['data'];
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken == null || newRefreshToken == null) {
          // Invalid refresh response - logout user
          await _handleLogout();
          return handler.next(err);
        }

        // Save new tokens
        await _storageService.saveTokens(newAccessToken, newRefreshToken);

        // Update API client with new token
        // Note: This will be handled by onRequest interceptor

        // Retry the original request with new token
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        // Use the same Dio instance to retry
        final retryResponse = await _dio.fetch(requestOptions);

        // Process pending requests
        _processPendingRequests(newAccessToken);

        return handler.resolve(retryResponse);
      } catch (e) {
        // Refresh failed - logout user
        await _handleLogout();

        // Reject all pending requests
        for (final pending in _pendingRequests) {
          pending.handler.next(err);
        }
        _pendingRequests.clear();

        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }

    return handler.next(err);
  }

  void _processPendingRequests(String newAccessToken) {
    for (final pending in _pendingRequests) {
      pending.requestOptions.headers['Authorization'] =
          'Bearer $newAccessToken';

      _dio
          .fetch(pending.requestOptions)
          .then(
            (response) => pending.handler.resolve(response),
            onError: (error) => pending.handler.next(error as DioException),
          );
    }
    _pendingRequests.clear();
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/verify-email') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password');
  }

  Future<void> _handleLogout() async {
    // Clear tokens and user data
    await _storageService.logout();

    // Navigate to login screen
    // Using appRouter from routes/app_router.dart
    appRouter.go(AppRoutes.login);
  }
}
