import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_routes.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_personal_screen.dart';
import '../screens/auth/signup_contact_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/home/home_dashboard_screen.dart';
import '../screens/home/main_shell_screen.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/health/health_screen.dart';
import '../screens/consultation/consultation_type_screen.dart';
import '../screens/consultation/symptom_input_screen.dart';
import '../screens/consultation/upload_files_screen.dart';
import '../screens/consultation/review_confirm_screen.dart';
import '../screens/queue/waiting_queue_screen.dart';
import '../screens/queue/doctor_assigned_screen.dart';
import '../screens/queue/incoming_call_screen.dart';
import '../screens/video/video_call_screen.dart';
import '../screens/video/in_call_chat_screen.dart';
import '../screens/video/connection_issue_screen.dart';
import '../screens/post_consultation/consultation_summary_screen.dart';
import '../screens/post_consultation/prescription_screen.dart';
import '../screens/post_consultation/followup_recommendations_screen.dart';
import '../screens/history/visit_history_screen.dart';
import '../screens/history/visit_details_screen.dart';
import '../screens/history/prescriptions_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/update_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/change_password_screen.dart';
import '../screens/settings/privacy_controls_screen.dart';
import '../screens/system/no_doctors_available_screen.dart';
import '../screens/system/network_error_screen.dart';
import '../screens/system/session_expired_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  // Deep linking is automatically supported by GoRouter
  // Supported formats:
  // - Custom scheme: evizor://login
  // - Universal links: https://evizor.app/login
  errorBuilder: (context, state) {
    // Handle deep link errors gracefully
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The requested page "${state.uri}" could not be found.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.home),
              label: const Text('Go Home'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
  routes: [
    // Splash & Onboarding
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Authentication
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup/personal',
      name: 'signup-personal',
      builder: (context, state) => const SignUpPersonalScreen(),
    ),
    GoRoute(
      path: '/signup/contact',
      name: 'signup-contact',
      builder: (context, state) => const SignUpContactScreen(),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      builder: (context, state) => const OTPVerificationScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),

    // Main Shell with Bottom Navigation
    ShellRoute(
      builder: (context, state, child) => MainShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeDashboardScreen(),
        ),
        GoRoute(
          path: '/history/visits',
          name: 'visit-history',
          builder: (context, state) => const VisitHistoryScreen(),
        ),
        GoRoute(
          path: '/history/prescriptions',
          name: 'prescriptions-list',
          builder: (context, state) => const PrescriptionsListScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/profile/update',
      name: 'update-profile',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final forceUpdate = extra?['forceUpdate'] as bool? ?? false;
        return UpdateProfileScreen(forceUpdate: forceUpdate);
      },
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/health',
      name: 'health',
      builder: (context, state) => const HealthScreen(),
    ),

    // Consultation Flow
    GoRoute(
      path: '/consultation/type',
      name: 'consultation-type',
      builder: (context, state) => const ConsultationTypeScreen(),
    ),
    GoRoute(
      path: '/consultation/symptoms',
      name: 'symptom-input',
      builder: (context, state) => const SymptomInputScreen(),
    ),
    GoRoute(
      path: '/consultation/upload',
      name: 'upload-files',
      builder: (context, state) => const UploadFilesScreen(),
    ),
    GoRoute(
      path: '/consultation/review',
      name: 'review-confirm',
      builder: (context, state) => const ReviewConfirmScreen(),
    ),

    // Queue & Waiting
    GoRoute(
      path: '/queue/waiting',
      name: 'waiting-queue',
      builder: (context, state) => const WaitingQueueScreen(),
    ),
    GoRoute(
      path: '/queue/assigned',
      name: 'doctor-assigned',
      builder: (context, state) => const DoctorAssignedScreen(),
    ),
    GoRoute(
      path: '/queue/incoming',
      name: 'incoming-call',
      builder: (context, state) => const IncomingCallScreen(),
    ),

    // Video Consultation
    GoRoute(
      path: '/video/call',
      name: 'video-call',
      builder: (context, state) => const VideoCallScreen(),
    ),
    GoRoute(
      path: '/video/chat',
      name: 'in-call-chat',
      builder: (context, state) => const InCallChatScreen(),
    ),
    GoRoute(
      path: '/video/reconnecting',
      name: 'connection-issue',
      builder: (context, state) => const ConnectionIssueScreen(),
    ),

    // Post-Consultation
    GoRoute(
      path: '/consultation/summary',
      name: 'consultation-summary',
      builder: (context, state) => const ConsultationSummaryScreen(),
    ),
    GoRoute(
      path: '/prescription',
      name: 'prescription',
      builder: (context, state) => const PrescriptionScreen(),
    ),
    GoRoute(
      path: '/follow-up',
      name: 'follow-up-recommendations',
      builder: (context, state) => const FollowUpRecommendationsScreen(),
    ),

    // History & Records
    GoRoute(
      path: '/history/visit-details',
      name: 'visit-details',
      builder: (context, state) => const VisitDetailsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/change-password',
      name: 'change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/settings/privacy',
      name: 'privacy-controls',
      builder: (context, state) => const PrivacyControlsScreen(),
    ),

    // System & Error Screens
    GoRoute(
      path: '/error/no-doctors',
      name: 'no-doctors-available',
      builder: (context, state) => const NoDoctorsAvailableScreen(),
    ),
    GoRoute(
      path: '/error/network',
      name: 'network-error',
      builder: (context, state) => const NetworkErrorScreen(),
    ),
    GoRoute(
      path: '/error/session-expired',
      name: 'session-expired',
      builder: (context, state) => const SessionExpiredScreen(),
    ),
  ],
);
