import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../providers/user_provider.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/toastification.dart';

class TwoFactorVerificationScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> extra;

  const TwoFactorVerificationScreen({super.key, required this.extra});

  @override
  ConsumerState<TwoFactorVerificationScreen> createState() =>
      _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState
    extends ConsumerState<TwoFactorVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AuthService _authService = AuthService(ApiClient().dio);
  final StorageService _storageService = StorageService();
  final BiometricService _biometricService = BiometricService();

  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  Timer? _timer;
  late String _email;
  late String _password;

  @override
  void initState() {
    super.initState();
    _email = widget.extra['email'] ?? '';
    _password = widget.extra['password'] ?? '';
    _startResendTimer();
    // Auto-focus the PIN input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
      _isResending = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _handleVerify(String pin) async {
    if (pin.length != 6) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.verify2FA(
        email: _email,
        otpCode: pin,
      );

      // Validate response has tokens
      final token = response.accessToken;
      final refreshToken = response.refreshToken;
      final user = response.user;

      if (token == null || refreshToken == null) {
        throw Exception('Invalid response from server');
      }

      // Check user role
      if (user.role.toUpperCase() != 'PATIENT') {
        throw Exception(
          'Access denied. This mobile app is only available for patients.',
        );
      }

      if (mounted) {
        // Update user provider
        await ref.read(currentUserProvider.notifier).setUser(user);

        // Save tokens
        await _storageService.saveTokens(token, refreshToken);

        // Set auth header
        ApiClient().setAuthToken(token);

        // Handle biometric prompt
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

        // Navigate based on profile completion
        if (mounted) {
          if (!response.profileCompleted) {
            context.go(AppRoutes.updateProfile, extra: {'forceUpdate': true});
          } else {
            context.go(AppRoutes.home);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        errorSnack(e.toString().replaceFirst('Exception: ', ''));
        _pinController.clear();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendCode() async {
    if (_resendTimer > 0) return;

    setState(() => _isResending = true);

    try {
      await _authService.resend2FA(email: _email);

      if (mounted) {
        successSnack('Verification code resent successfully');
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        errorSnack(e.toString().replaceFirst('Exception: ', ''));
      }
      setState(() => _isResending = false);
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
        email: _email,
        password: _password,
      );
      if (mounted) {
        infoSnack('Biometric login enabled successfully');
      }
    } else if (shouldEnable == false) {
      await _biometricService.markPromptAsDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primaryColor),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 40,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Two-Factor Authentication',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the verification code sent to $_email',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Pinput(
                length: 6,
                controller: _pinController,
                focusNode: _focusNode,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                onCompleted: _handleVerify,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    CustomButton(
                      text: 'Verify',
                      onPressed: () => _handleVerify(_pinController.text),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive code? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: (_resendTimer > 0 || _isResending)
                              ? null
                              : _handleResendCode,
                          child: _isResending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey,
                                    ),
                                  ),
                                )
                              : Text(
                                  _resendTimer > 0
                                      ? 'Resend in ${_resendTimer}s'
                                      : 'Resend Code',
                                  style: TextStyle(
                                    color: _resendTimer > 0
                                        ? Colors.grey
                                        : AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
