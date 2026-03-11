/// Application environment configuration
class AppConfig {
  /// Base URL for the Patient API
  static const String apiBaseUrl =
      'https://evisor-backend-staging.up.railway.app/api/v1';

  // Socket base url
  static const String socketBaseUrl =
      'https://evisor-backend-staging.up.railway.app/signaling';

  // Injected at build time via --dart-define=MAPBOX_ACCESS_TOKEN=pk...
  // Never commit the actual token value here.
  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
  );
}
