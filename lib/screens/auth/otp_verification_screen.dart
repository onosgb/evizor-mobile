import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _timerSeconds = 60;
  bool _canResend = false;
  bool _isLoading = false;
  String _currentOTP = '';

  // Auth service
  final AuthService _authService = AuthService();

  // Data from previous screen
  Map<String, dynamic>? _extraData;

  @override
  void initState() {
    super.initState();
    // Get data from previous screen - defer until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
        if (extra != null) {
          setState(() {
            _extraData = extra;
          });
        }
      }
    });
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_timerSeconds > 0) {
            _timerSeconds--;
            _startTimer();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  Future<void> _handleVerify() async {
    final otpCode = _otpController.text.trim();

    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit OTP code'),
        ),
      );
      return;
    }

    // Get email from registration data
    final email = _extraData?['registrationData']?['email'] as String?;
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not found. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call email verification API
      final response = await _authService.verifyEmail(
        email: email,
        otpCode: '${otpCode}',
      );

      setState(() => _isLoading = false);

      if (mounted) {}
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

  void _handleResend() {
    setState(() {
      _canResend = false;
      _timerSeconds = 60;
      _currentOTP = '';
      _otpController.clear();
    });
    _startTimer();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP code resent')));
  }

  String _getEmail() {
    final email = _extraData?['registrationData']?['email'] as String?;
    return email ?? 'user@example.com';
  }

  /// Masks email address for privacy
  /// Example: "john.doe@example.com" -> "jo***@example.com"
  String _maskEmail(String email) {
    if (email.isEmpty) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.isEmpty) {
      return '***@$domain';
    } else if (localPart.length == 1) {
      // If local part is 1 char, show it and mask
      return '${localPart[0]}***@$domain';
    } else if (localPart.length == 2) {
      // If local part is 2 chars, show first char and mask
      return '${localPart[0]}***@$domain';
    } else {
      // Show first 2 characters, mask the rest
      return '${localPart.substring(0, 2)}***@$domain';
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _getEmail();
    final maskedEmail = _maskEmail(email);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    size: 40,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  'We\'ve sent a verification code to\n$maskedEmail',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // OTP Input - 6 digit code using pin_code_fields
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 60,
                    fieldWidth: 50,
                    activeFillColor: Colors.white,
                    inactiveFillColor: AppColors.backgroundGrey,
                    selectedFillColor: Colors.white,
                    activeColor: AppColors.primaryColor,
                    inactiveColor: Colors.grey[300]!,
                    selectedColor: AppColors.primaryColor,
                  ),
                  cursorColor: AppColors.primaryColor,
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _currentOTP = value;
                    });
                    // Auto-verify when 6 digits are entered (works for paste too)
                    if (value.length == 6 && !_isLoading) {
                      // Small delay to ensure the text is fully set
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted && _currentOTP.length == 6) {
                          _handleVerify();
                        }
                      });
                    }
                  },
                  onCompleted: (value) {
                    // Verify when all 6 digits are entered
                    if (value.length == 6 && !_isLoading) {
                      _handleVerify();
                    }
                  },
                ),
                const SizedBox(height: 8),
                // Helper text
                Text(
                  'Enter the 6-digit code sent to your email',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Didn\'t receive the code? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (_canResend)
                      TextButton(
                        onPressed: _handleResend,
                        child: const Text(
                          'Resend',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Resend in ${_timerSeconds}s',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                // Verify Button
                CustomButton(
                  text: 'Verify',
                  onPressed: _handleVerify,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
