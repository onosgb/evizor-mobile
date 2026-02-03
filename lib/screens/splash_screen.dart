import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/tenant_provider.dart';
import '../providers/user_provider.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  final StorageService _storageService = StorageService();
  bool _tenantsLoaded = false;
  bool _minTimeElapsed = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -20.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Preload tenants
    _preloadTenants();

    // Minimum splash screen time (2 seconds)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _minTimeElapsed = true;
        });
        _checkAndNavigate();
      }
    });
  }

  Future<void> _preloadTenants() async {
    try {
      // Trigger tenant loading by reading the provider's future
      // This will wait for the data to load or throw an error
      await ref.read(tenantsProvider.future);

      // Successfully loaded tenants
      if (mounted) {
        setState(() {
          _tenantsLoaded = true;
          _hasError = false;
          _errorMessage = null;
        });
        _checkAndNavigate();
      }
    } catch (e) {
      // Error loading tenants - show error and prevent navigation
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load location data';
          _tenantsLoaded = false; // Ensure navigation is blocked
        });
        _controller.stop(); // Stop animation when error occurs
      }
    }
  }

  void _retryLoading() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _tenantsLoaded = false;
    });

    // Restart animation
    _controller.repeat(reverse: true);

    // Invalidate the provider cache to force a fresh load
    ref.invalidate(tenantsProvider);

    // Retry loading tenants
    _preloadTenants();
  }

  Future<void> _checkAndNavigate() async {
    // Navigate only when both conditions are met:
    // 1. Minimum time has elapsed
    // 2. Tenants are successfully loaded (not on error)
    // This ensures we never navigate if location loading failed
    if (_minTimeElapsed && _tenantsLoaded && !_hasError && mounted) {
      _controller.stop();

      // Check if user is logged in
      final isLoggedIn = await _storageService.isLoggedIn();

      if (isLoggedIn) {
        // Load user data into sync provider
        await refreshUserData(ref);

        // User is logged in - go to home
        if (mounted) {
          context.go(AppRoutes.home);
        }
      } else {
        // User is not logged in - check if they've seen onboarding
        final hasSeenOnboarding = await _storageService.hasSeenOnboarding();

        if (mounted) {
          if (hasSeenOnboarding) {
            // User has seen onboarding before - go to login
            context.go(AppRoutes.login);
          } else {
            // First time user - show onboarding
            context.go(AppRoutes.onboarding);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo - Circular white background with blue heart outline
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'images/logo.png',
                        height: 75,
                        width: 75,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // App Name
            const Text(
              'HealthCare',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            const Text(
              'Your Virtual Doctor',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 48),
            // Loading Indicator or Error Message
            if (_hasError) ...[
              Text(
                _errorMessage ?? 'Something went wrong',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _retryLoading,
                icon: const Icon(Icons.refresh, color: AppColors.primaryColor),
                label: const Text(
                  'Refresh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
              ),
            ] else ...[
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
