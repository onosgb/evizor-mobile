import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../models/registration_model.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/toastification.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignUpContactScreen extends StatefulWidget {
  const SignUpContactScreen({super.key});

  @override
  State<SignUpContactScreen> createState() => _SignUpContactScreenState();
}

class _SignUpContactScreenState extends State<SignUpContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  // Data from previous screen
  Map<String, dynamic>? _personalData;
  bool _hasInitialized = false;

  // Auth service
  final AuthService _authService = AuthService(ApiClient().dio);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Update personal data whenever route data changes
    // This ensures that if user goes back, edits personal info, and comes forward again,
    // we have the latest personal data
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra != null) {
      // Extract personal data from route extra
      final personalData = <String, dynamic>{
        if (extra['firstName'] != null) 'firstName': extra['firstName'],
        if (extra['lastName'] != null) 'lastName': extra['lastName'],
        if (extra['socialId'] != null) 'socialId': extra['socialId'],
        if (extra['healthCardNo'] != null)
          'healthCardNo': extra['healthCardNo'],
        if (extra['tenantId'] != null) 'tenantId': extra['tenantId'],
      };

      // Update personal data state
      setState(() {
        _personalData = personalData.isNotEmpty ? personalData : null;
      });

      // Only restore contact form fields on first initialization
      if (!_hasInitialized) {
        _hasInitialized = true;

        // Restore contact form fields
        if (extra['email'] != null) {
          final email = extra['email'].toString();
          if (email.isNotEmpty) {
            _emailController.text = email;
          }
        }
        if (extra['phone'] != null) {
          final phone = extra['phone'].toString();
          if (phone.isNotEmpty) {
            // Ensure phone starts with +
            if (phone.startsWith('+')) {
              _phoneController.text = phone;
            } else {
              _phoneController.text = '+$phone';
            }
          }
        }

        // Restore checkbox state
        if (extra['acceptTerms'] != null) {
          setState(() {
            _acceptTerms = extra['acceptTerms'] as bool;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        errorSnack('Please accept the terms and privacy policy');
        return;
      }

      // Create registration request
      if (_personalData != null) {
        setState(() => _isLoading = true);

        try {
          final registrationRequest = RegistrationRequest(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phoneNumber: _phoneController.text.trim(),
            firstName: _personalData!['firstName'] as String,
            lastName: _personalData!['lastName'] as String,
            socialId: _personalData!['socialId'] as String,
            healthCardNo: _personalData!['healthCardNo'] as String,
            tenantId: _personalData!['tenantId'] as String,
            role: 'PATIENT',
          );

          // Call registration API
          final response = await _authService.register(registrationRequest);

          setState(() => _isLoading = false);

          if (mounted) {
            // Navigate to OTP verification on success
            context.push(
              AppRoutes.otpVerification,
              extra: {
                'phone': _phoneController.text,
                'registrationData': registrationRequest.toJson(),
                'apiResponse': response,
              },
            );
          }
        } catch (e) {
          setState(() => _isLoading = false);

          if (mounted) {
            errorSnack(e.toString().replaceFirst('Exception: ', ''));
          }
        }
      }
    }
  }

  void _handleBackNavigation() {
    // Pass ALL data back when navigating back (both personal and contact)
    context.pop({
      // Personal data (preserve it)
      if (_personalData != null) ..._personalData!,
      // Contact data (current form values)
      'email': _emailController.text,
      'phone': _phoneController.text,
      'acceptTerms': _acceptTerms,
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: _handleBackNavigation,
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 5.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Contact & Security',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your registration',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  // Email
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
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Phone
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\d+]'),
                              ),
                            ],
                            onChanged: (value) {
                              // Force + at the start
                              if (value.isNotEmpty && !value.startsWith('+')) {
                                // Remove all non-digits and non-plus, then add + at start
                                final digitsOnly = value.replaceAll(
                                  RegExp(r'[^\d]'),
                                  '',
                                );
                                _phoneController.value = TextEditingValue(
                                  text: '+$digitsOnly',
                                  selection: TextSelection.collapsed(
                                    offset: '+$digitsOnly'.length,
                                  ),
                                );
                              } else if (value.isEmpty) {
                                // If user deletes everything, ensure + is added when they type
                                _phoneController.text = '+';
                                _phoneController.selection =
                                    TextSelection.collapsed(offset: 1);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              // Validate country code format: must start with + and have digits
                              if (!value.startsWith('+')) {
                                return 'Phone number must start with country code (e.g., +1)';
                              }
                              // Remove + and check if remaining are all digits
                              final digitsOnly = value
                                  .substring(1)
                                  .replaceAll(RegExp(r'[^\d]'), '');
                              if (digitsOnly.isEmpty) {
                                return 'Please enter a valid phone number with country code';
                              }
                              if (digitsOnly.length < 10) {
                                return 'Phone number is too short. Include country code (e.g., +1238143651142)';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '+1238143651142',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              filled: true,
                              fillColor: AppColors.backgroundGrey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                  width: 1,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Include country code (e.g., +1 for USA, +44 for UK)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Password
                  CustomTextField(
                    label: 'Password',
                    hint: 'Create a password',
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
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Terms & Privacy
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() => _acceptTerms = value ?? false);
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Show terms and privacy
                          },
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Sign Up Button
                  CustomButton(
                    text: 'Sign Up',
                    onPressed: _handleSignUp,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
