import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

// Helper extension for easier navigation
extension NavigationExtension on BuildContext {
  void goTo(String route) => go(route);
  void pushTo(String route) => push(route);
  void popScreen() => pop();

  // Named route helpers
  void goToLogin() => go(AppRoutes.login);
  void goToHome() => go(AppRoutes.home);
  void goToOnboarding() => go(AppRoutes.onboarding);
}
