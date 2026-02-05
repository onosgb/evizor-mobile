import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/update_profile_request_model.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// Provider for StorageService instance
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Provider for AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ApiClient().dio);
});

/// Main user provider using AsyncNotifier pattern
/// This is the single source of truth for user state
final currentUserProvider = AsyncNotifierProvider<UserNotifier, User?>(
  UserNotifier.new,
);

/// User state notifier - handles all user-related operations
class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // Load user from storage on initialization
    final storageService = ref.read(storageServiceProvider);
    return await storageService.getUser();
  }

  /// Fetch and update user profile from API
  Future<void> fetchProfile() async {
    try {
      final authService = ref.read(authServiceProvider);
      final storageService = ref.read(storageServiceProvider);

      // Fetch from API
      final response = await authService.fetchUserProfile();
      final userData = response as Map<String, dynamic>?;

      if (userData == null) {
        throw Exception('No user data received');
      }

      // Get current user to preserve basic info if API doesn't return it
      final currentUser = await storageService.getUser();

      // Merge current user with full profile data
      final updatedUserData = {...?currentUser?.toJson(), ...userData};

      // Create user from response
      final user = User.fromJson(updatedUserData);

      // Save to storage
      await storageService.saveUser(user);

      // Update state
      state = AsyncData(user);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile(UpdateProfileRequest request) async {
    try {
      final authService = ref.read(authServiceProvider);
      final storageService = ref.read(storageServiceProvider);

      // Call API to update profile
      final response = await authService.updateProfile(request);

      // Create user from API response
      final updatedUser = User.fromJson(response);

      // Save to storage
      await storageService.saveUser(updatedUser);

      // Update state
      state = AsyncData(updatedUser);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  /// Refresh user data from storage
  Future<void> refreshFromStorage() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final user = await storageService.getUser();
      state = AsyncData(user);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  /// Set user state directly (for login, etc.)
  Future<void> setUser(User user) async {
    try {
      final storageService = ref.read(storageServiceProvider);

      // Save to storage
      await storageService.saveUser(user);

      // Update state
      state = AsyncData(user);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  /// Clear user state (for logout)
  void clear() {
    state = const AsyncData(null);
  }
}
