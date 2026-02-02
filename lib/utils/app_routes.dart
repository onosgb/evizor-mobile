// Route names for navigation
class AppRoutes {
  // Onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Authentication
  static const String login = '/login';
  static const String signUpPersonal = '/signup/personal';
  static const String signUpContact = '/signup/contact';
  static const String otpVerification = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Home & Navigation
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String health = '/health';

  // Virtual Visit Flow
  static const String consultationType = '/consultation/type';
  static const String symptomInput = '/consultation/symptoms';
  static const String uploadFiles = '/consultation/upload';
  static const String reviewConfirm = '/consultation/review';

  // Queue & Waiting
  static const String waitingQueue = '/queue/waiting';
  static const String doctorAssigned = '/queue/assigned';
  static const String incomingCall = '/queue/incoming';

  // Video Consultation
  static const String videoCall = '/video/call';
  static const String inCallChat = '/video/chat';
  static const String connectionIssue = '/video/reconnecting';

  // Post-Consultation
  static const String consultationSummary = '/consultation/summary';
  static const String prescription = '/prescription';
  static const String followUpRecommendations = '/follow-up';

  // Records & History
  static const String visitHistory = '/history/visits';
  static const String visitDetails = '/history/visit-details';
  static const String prescriptionsList = '/history/prescriptions';

  // Profile & Settings
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String changePassword = '/settings/change-password';
  static const String privacyControls = '/settings/privacy';

  // System & Edge Cases
  static const String noDoctorsAvailable = '/error/no-doctors';
  static const String networkError = '/error/network';
  static const String sessionExpired = '/error/session-expired';
}
