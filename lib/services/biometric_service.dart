import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Service for handling biometric authentication
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyStoredEmail = 'biometric_email';
  static const String _keyStoredPassword = 'biometric_password';
  static const String _keyBiometricPromptDismissed =
      'biometric_prompt_dismissed';

  /// Check if device supports biometric authentication
  Future<bool> canUseBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  /// Authenticate user with biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to login',
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricEnabled() async {
    final String? enabled = await _secureStorage.read(
      key: _keyBiometricEnabled,
    );
    return enabled == 'true';
  }

  /// Save credentials securely for biometric login
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: _keyBiometricEnabled, value: 'true');
    await _secureStorage.write(key: _keyStoredEmail, value: email);
    await _secureStorage.write(key: _keyStoredPassword, value: password);
  }

  /// Get stored credentials (requires biometric authentication first)
  Future<Map<String, String>?> getStoredCredentials() async {
    try {
      final email = await _secureStorage.read(key: _keyStoredEmail);
      final password = await _secureStorage.read(key: _keyStoredPassword);

      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Disable biometric login and clear stored credentials
  Future<void> disableBiometric() async {
    await _secureStorage.delete(key: _keyBiometricEnabled);
    await _secureStorage.delete(key: _keyStoredEmail);
    await _secureStorage.delete(key: _keyStoredPassword);
    // Clear the dismissed flag when biometric is disabled
    await _secureStorage.delete(key: _keyBiometricPromptDismissed);
  }

  /// Clear all biometric data (called on logout)
  Future<void> clearBiometricData() async {
    await disableBiometric();
  }

  /// Check if user has dismissed the biometric prompt before
  Future<bool> hasUserDismissedPrompt() async {
    final String? dismissed = await _secureStorage.read(
      key: _keyBiometricPromptDismissed,
    );
    return dismissed == 'true';
  }

  /// Mark that user has dismissed the biometric prompt
  Future<void> markPromptAsDismissed() async {
    await _secureStorage.write(
      key: _keyBiometricPromptDismissed,
      value: 'true',
    );
  }
}
