import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/tenant_provider.dart';
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
  bool _tenantsLoaded = false;
  bool _minTimeElapsed = false;

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
      // Trigger tenant loading by reading the provider
      final tenantsAsync = ref.read(tenantsProvider);
      await tenantsAsync.value; // Wait for tenants to load

      if (mounted) {
        setState(() {
          _tenantsLoaded = true;
        });
        _checkAndNavigate();
      }
    } catch (e) {
      // Even if tenant loading fails, still navigate after min time
      if (mounted) {
        setState(() {
          _tenantsLoaded = true; // Allow navigation even on error
        });
        _checkAndNavigate();
      }
    }
  }

  void _checkAndNavigate() {
    // Navigate only when both conditions are met:
    // 1. Minimum time has elapsed
    // 2. Tenants are loaded (or failed to load)
    if (_minTimeElapsed && _tenantsLoaded && mounted) {
      _controller.stop();
      context.go(AppRoutes.onboarding);
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
            // Loading Indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
