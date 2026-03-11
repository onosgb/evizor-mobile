import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart'; // Removed for design phase
import '../../models/tenant_model.dart';
import '../../providers/tenant_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignUpPersonalScreen extends ConsumerStatefulWidget {
  const SignUpPersonalScreen({super.key});

  @override
  ConsumerState<SignUpPersonalScreen> createState() =>
      _SignUpPersonalScreenState();
}

class _SignUpPersonalScreenState extends ConsumerState<SignUpPersonalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _socialIdController = TextEditingController();
  final _healthCardController = TextEditingController();

  // Selected tenant/location
  Tenant? _selectedTenant;

  // Preserve contact form data when navigating back
  Map<String, dynamic>? _preservedContactData;

  @override
  void initState() {
    super.initState();
    // Restore form fields from route extra if available (when returning from contact screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
        if (extra != null) {
          // Restore personal form fields
          if (extra['firstName'] != null) {
            _firstNameController.text = extra['firstName'] as String;
          }
          if (extra['lastName'] != null) {
            _lastNameController.text = extra['lastName'] as String;
          }
          if (extra['socialId'] != null) {
            _socialIdController.text = extra['socialId'] as String;
          }
          if (extra['healthCardNo'] != null) {
            _healthCardController.text = extra['healthCardNo'] as String;
          }
          // Restore selected tenant
          if (extra['tenantId'] != null) {
            final tenantId = extra['tenantId'] as String;
            final tenantsAsync = ref.read(tenantsProvider);
            tenantsAsync.whenData((tenants) {
              final tenant = tenants.firstWhere((t) => t.id == tenantId);
              setState(() {
                _selectedTenant = tenant;
              });
              ref.read(selectedTenantProvider.notifier).state = tenant;
            });
          }

          // Store contact data for next navigation
          if (extra['email'] != null ||
              extra['phone'] != null ||
              extra['socialId'] != null ||
              extra['healthCardNo'] != null) {
            setState(() {
              _preservedContactData = {
                if (extra['email'] != null) 'email': extra['email'],
                if (extra['phone'] != null) 'phone': extra['phone'],
                if (extra['socialId'] != null) 'socialId': extra['socialId'],
                if (extra['healthCardNo'] != null)
                  'healthCardNo': extra['healthCardNo'],
                if (extra['acceptTerms'] != null)
                  'acceptTerms': extra['acceptTerms'],
              };
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    // _dobController.dispose();
    _healthCardController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_formKey.currentState!.validate()) {
      // Navigate to contact screen and wait for result
      final result = await context.push<Map<String, dynamic>>(
        AppRoutes.signUpContact,
        extra: {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'socialId': _socialIdController.text,
          'healthCardNo': _healthCardController.text,
          'tenantId': _selectedTenant!.id,
          // Include preserved contact data if available
          if (_preservedContactData != null) ..._preservedContactData!,
        },
      );

      // Store the result for next time user navigates forward
      if (result != null && mounted) {
        setState(() {
          _preservedContactData = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 5.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Personal Details',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us about yourself',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                // First Name
                CustomTextField(
                  label: 'First Name',
                  hint: 'Enter your first name',
                  controller: _firstNameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Last Name
                CustomTextField(
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  controller: _lastNameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Location Dropdown
                _buildLocationDropdown(),
                const SizedBox(height: 20),
                // Date of Birth
                CustomTextField(
                  label: 'Social ID',
                  hint: 'Enter your social ID',
                  controller: _socialIdController,
                  prefixIcon: const Icon(Icons.share_location_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your social ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Health Card Number
                CustomTextField(
                  label: 'Health Card Number',
                  hint: 'Enter your health card number',
                  controller: _healthCardController,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your health card number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Next Button
                CustomButton(text: 'Next', onPressed: _handleNext),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    // Read from cached provider data (already loaded by splash screen)
    final tenantsAsync = ref.watch(tenantsProvider);

    // Since location is loaded on splash screen, we only need to handle the data state
    // If data is not available here, it means splash screen didn't work correctly
    return tenantsAsync.when(
      data: (tenants) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Tenant>(
              initialValue: _selectedTenant,
              decoration: InputDecoration(
                hintText: 'Select your location',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
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
                  borderSide: const BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: tenants.map((tenant) {
                return DropdownMenuItem<Tenant>(
                  value: tenant,
                  child: Text(tenant.province),
                );
              }).toList(),
              onChanged: (Tenant? newValue) {
                setState(() {
                  _selectedTenant = newValue;
                });
                ref.read(selectedTenantProvider.notifier).state = newValue;
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select your location';
                }
                return null;
              },
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(child: Text('Loading locations...')),
          ),
        ],
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Location data not available. Please restart the app.',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
