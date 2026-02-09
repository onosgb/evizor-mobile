import 'package:evizor/utils/toastification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Services
  final AuthService _authService = AuthService(ApiClient().dio);
  final StorageService _storageService = StorageService();
  final BiometricService _biometricService = BiometricService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin({
    required String email,
    required String password,
    bool checkBiometric = false,
  }) async {
    setState(() => _isLoading = true);

    try {
      // Call login API
      final response = await _authService.login(
        email: email,
        password: password,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        // Extract data from LoginResponse model
        final token = response.accessToken;
        final refreshToken = response.refreshToken;
        final user = response.user;

        // Validate that only patients can login on mobile app
        if (user.role.toUpperCase() != 'PATIENT') {
          throw Exception(
            'Access denied. This mobile app is only available for patients. '
            'Please use the appropriate platform for your account type.',
          );
        }

        // Update user provider with the user from login response
        if (mounted) {
          await ref.read(currentUserProvider.notifier).setUser(user);
        }

        // Save tokens to storage
        await _storageService.saveTokens(token, refreshToken);

        // Set auth token in API client for future requests
        ApiClient().setAuthToken(token);

        // Prompt to enable biometric login if not already enabled or dismissed
        // Only valid for standard login flow
        if (checkBiometric) {
          final biometricEnabled = await _biometricService.isBiometricEnabled();
          final canUseBiometric = await _biometricService.canUseBiometrics();
          final hasUserDismissed = await _biometricService
              .hasUserDismissedPrompt();

          if (mounted &&
              !biometricEnabled &&
              canUseBiometric &&
              !hasUserDismissed) {
            await _promptEnableBiometric();
          }
        }

        // Check if profile is verified
        if (!response.profileVerified) {
          // Auto resend OTP
          await _authService.resendEmailVerification(email: email);

          if (mounted) {
            infoSnack(
              'Account not verified. A new verification code has been sent to your email.',
            );
            context.push(
              AppRoutes.otpVerification,
              extra: {
                'flowType': 'emailVerification',
                'registrationData': {'email': email},
              },
            );
          }
          return;
        }

        // Check if profile is completed
        if (!response.profileCompleted) {
          if (mounted) {
            context.go(AppRoutes.updateProfile, extra: {'forceUpdate': true});
          }
          return;
        }

        // Navigate to home on success (only for patients)
        if (mounted) {
          context.go(AppRoutes.home);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        errorSnack(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await _performLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        checkBiometric: true,
      );
    }
  }

  Future<void> _handleBiometricLogin() async {
    try {
      // Check if biometric is enabled
      final isEnabled = await _biometricService.isBiometricEnabled();
      if (!isEnabled) {
        errorSnack('Biometric login is not enabled');
        return;
      }

      // Authenticate with biometrics
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to login to your account',
      );

      if (!authenticated) {
        errorSnack('Biometric authentication failed');
        return;
      }

      // Get stored credentials
      final credentials = await _biometricService.getStoredCredentials();
      if (credentials == null) {
        errorSnack('No stored credentials found');
        await _biometricService.disableBiometric();
        return;
      }

      // Perform login with stored credentials
      await _performLogin(
        email: credentials['email']!,
        password: credentials['password']!,
        checkBiometric: false,
      );
    } catch (e) {
      if (mounted) {
        errorSnack(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _promptEnableBiometric() async {
    final shouldEnable = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Login?'),
        content: const Text(
          'Would you like to enable biometric login for faster access next time?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (shouldEnable == true) {
      await _biometricService.saveCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        infoSnack('Biometric login enabled successfully');
      }
    } else if (shouldEnable == false) {
      // User clicked "Not Now", mark as dismissed so we don't ask again
      await _biometricService.markPromptAsDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Email/Phone Input
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Password Input
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push(AppRoutes.forgotPassword);
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Login Button
                CustomButton(
                  text: 'Login',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),
                // Biometric Login Icon
                FutureBuilder<bool>(
                  future: _biometricService.isBiometricEnabled(),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return Column(
                        children: [
                          const SizedBox(height: 24),
                          Center(
                            child: InkWell(
                              onTap: _handleBiometricLogin,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.fingerprint,
                                  size: 32,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 32),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(AppRoutes.signUpPersonal);
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
