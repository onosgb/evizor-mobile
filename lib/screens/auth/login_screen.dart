import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:local_auth/local_auth.dart'; // Removed for design phase
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  // final LocalAuthentication _localAuth = LocalAuthentication(); // Removed for design phase

  // Auth service
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Call login API
        final response = await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (mounted) {
          // Extract response data (likely contains token and user info)
          // TODO: Save token to secure storage for authenticated requests
          final data = response['data'];
          final token = data['accessToken'];
          final refreshToken = data['refreshToken'];
          final role = data['role'];
          final user = data['user'];

          // Check if user role exists (either directly in response or in user object)
          final userRole = role ?? user?['role'] as String?;

          if (token == null) {
            throw Exception('Invalid login response');
          }

          // Validate that only patients can login on mobile app
          if (userRole == null || userRole.toUpperCase() != 'PATIENT') {
            throw Exception(
              'Access denied. This mobile app is only available for patients. '
              'Please use the appropriate platform for your account type.',
            );
          }

          // Set auth token in API client for future requests
          // ApiClient().setAuthToken(token);

          // Navigate to home on success (only for patients)
          context.go(AppRoutes.home);
        }
      } catch (e) {
        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    // Biometric login temporarily disabled for design phase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biometric login coming soon')),
    );
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
                  label: 'Email or Phone',
                  hint: 'Enter your email or phone number',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email or phone';
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
                // Biometric Login - Temporarily disabled for design phase
                // FutureBuilder<bool>(
                //   future: _localAuth.canCheckBiometrics,
                //   builder: (context, snapshot) {
                //     if (snapshot.data == true) {
                //       return Column(
                //         children: [
                //           Row(
                //             children: [
                //               Expanded(child: Divider(color: Colors.grey[300])),
                //               Padding(
                //                 padding: const EdgeInsets.symmetric(
                //                   horizontal: 16,
                //                 ),
                //                 child: Text(
                //                   'OR',
                //                   style: TextStyle(color: Colors.grey[600]),
                //                 ),
                //               ),
                //               Expanded(child: Divider(color: Colors.grey[300])),
                //             ],
                //           ),
                //           const SizedBox(height: 24),
                //           OutlinedButton.icon(
                //             onPressed: _handleBiometricLogin,
                //             icon: const Icon(Icons.fingerprint),
                //             label: const Text('Login with Biometric'),
                //             style: OutlinedButton.styleFrom(
                //               padding: const EdgeInsets.symmetric(vertical: 16),
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(12),
                //               ),
                //             ),
                //           ),
                //         ],
                //       );
                //     }
                //     return const SizedBox.shrink();
                //   },
                // ),
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
