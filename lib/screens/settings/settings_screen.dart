import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/toastification.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final AuthService _authService = AuthService(ApiClient().dio);
  final BiometricService _biometricService = BiometricService();
  bool _isBiometricEnabled = false;
  bool _canUseBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    final canUse = await _biometricService.canUseBiometrics();
    if (mounted) {
      setState(() {
        _isBiometricEnabled = isEnabled;
        _canUseBiometric = canUse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final is2FAEnabled = user?.isTwoFAEnabled ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      'Manage your app preferences',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // PREFERENCES Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREFERENCES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSettingsItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'On',
                        onTap: () {
                          context.push(AppRoutes.notifications);
                        },
                      ),
                      _buildDivider(),
                      // _buildSettingsItem(
                      //   icon: Icons.language_outlined,
                      //   title: 'Language',
                      //   subtitle: 'English',
                      //   onTap: () {
                      //     // Handle language selection
                      //   },
                      // ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // SECURITY Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SECURITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSettingsItem(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: null,
                        onTap: () {
                          context.push(AppRoutes.changePassword);
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy & Data',
                        subtitle: null,
                        onTap: () {
                          context.push(AppRoutes.privacyControls);
                        },
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        icon: Icons.security,
                        title: 'Two-Factor Authentication',
                        subtitle: 'Add an extra layer of security',
                        value: is2FAEnabled,
                        onChanged: (value) async {
                          try {
                            // Call API to toggle 2FA
                            await _authService.toggle2FA(enable: value);

                            // Refresh user profile to get updated 2FA status
                            await ref
                                .read(currentUserProvider.notifier)
                                .fetchProfile();

                            if (mounted) {
                              successSnack(
                                value
                                    ? '2FA enabled successfully'
                                    : '2FA disabled successfully',
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              errorSnack(
                                e.toString().replaceFirst('Exception: ', ''),
                              );
                            }
                          }
                        },
                      ),
                      if (_canUseBiometric) ...[
                        _buildDivider(),
                        _buildSwitchItem(
                          icon: Icons.fingerprint,
                          title: 'Biometric Login',
                          subtitle: 'Use fingerprint or face recognition',
                          value: _isBiometricEnabled,
                          onChanged: (value) async {
                            if (value) {
                              // Enable biometric - need to authenticate and get credentials
                              final shouldEnable = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Enable Biometric Login?'),
                                  content: const Text(
                                    'You will need to login with your password to enable biometric authentication.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Continue'),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldEnable == true && mounted) {
                                // Show dialog to enter password
                                final credentials = await _showPasswordDialog();
                                if (credentials != null) {
                                  await _biometricService.saveCredentials(
                                    email: credentials['email']!,
                                    password: credentials['password']!,
                                  );
                                  await _checkBiometricStatus();
                                  if (mounted) {
                                    successSnack('Biometric login enabled');
                                  }
                                }
                              }
                            } else {
                              // Disable biometric
                              await _biometricService.disableBiometric();
                              await _checkBiometricStatus();
                              if (mounted) {
                                successSnack('Biometric login disabled');
                              }
                            }
                          },
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // App Version Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSettingsCard([
                  _buildSettingsItem(
                    icon: null,
                    title: 'App Version',
                    subtitle: 'Version 1.0.0',
                    onTap: null,
                  ),
                ]),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    IconData? icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 20,
      endIndent: 20,
    );
  }

  Future<Map<String, String>?> _showPasswordDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final user = ref.read(currentUserProvider).value;

    // Pre-fill email if available
    if (user?.email != null) {
      emailController.text = user!.email;
    }

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Your Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                Navigator.of(context).pop({
                  'email': emailController.text.trim(),
                  'password': passwordController.text,
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
