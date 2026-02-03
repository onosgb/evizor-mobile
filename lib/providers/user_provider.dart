import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Provider for current user data
/// This provider loads user data from storage and can be watched throughout the app
final currentUserProvider = FutureProvider<User?>((ref) async {
  final storageService = ref.watch(storageServiceProvider);
  return await storageService.getUser();
});

/// Provider for synchronous access to user data (cached)
/// Use this when you need immediate access without async/await
/// Initializes from storage on first access
final currentUserSyncProvider = StateProvider<User?>((ref) {
  // Initialize from storage synchronously if possible
  // Note: This will be null initially and should be populated via refreshUserData
  return null;
});

/// Helper function to refresh user data from storage
Future<void> refreshUserData(WidgetRef ref) async {
  final storageService = ref.read(storageServiceProvider);
  final user = await storageService.getUser();
  ref.read(currentUserSyncProvider.notifier).state = user;
}

/// Fetch and update full user profile from API
/// This should be called when user visits profile screen or updates profile
Future<User?> fetchAndUpdateFullProfile(WidgetRef ref) async {
  try {
    final authService = ref.read(authServiceProvider);
    final storageService = ref.read(storageServiceProvider);

    // Fetch full profile from API
    final response = await authService.fetchUserProfile();
    final userData = response['data'] as Map<String, dynamic>?;

    if (userData == null) {
      return null;
    }

    // Get current user to preserve basic info if API doesn't return it
    final currentUser = await storageService.getUser();

    // Merge current user with full profile data
    final updatedUserData = {...?currentUser?.toJson(), ...userData};

    // Create user with full profile
    final fullUser = User.fromJson(updatedUserData);

    // Save updated user
    await storageService.saveUser(fullUser);

    // Update provider
    ref.read(currentUserSyncProvider.notifier).state = fullUser;

    return fullUser;
  } catch (e) {
    // Return current user if fetch fails
    final storageService = ref.read(storageServiceProvider);
    return await storageService.getUser();
  }
}
