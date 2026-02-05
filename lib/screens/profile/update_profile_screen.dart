import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/update_profile_request_model.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/toastification.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedBloodGroup;
  bool _isLoading = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.value;
      if (user != null) {
        setState(() {
          _firstNameController.text = user.firstName;
          _lastNameController.text = user.lastName;
          _phoneController.text = user.phoneNumber;
          _addressController.text = user.address ?? '';
          _selectedDate = user.dob;
          _selectedGender = user.gender;
          _selectedBloodGroup = user.bloodGroup;
          _dateOfBirthController.text = _formatDate(_selectedDate);
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Get current user from state
        final userAsync = ref.read(currentUserProvider);
        final currentUser = userAsync.value;

        if (currentUser == null) {
          throw Exception('User not found. Please login again.');
        }

        // Create update request from current user and apply form changes
        final updateRequest = UpdateProfileRequest.fromUser(currentUser)
            .copyWith(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              dob: _selectedDate,
              gender: _selectedGender,
              address: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
              bloodGroup: _selectedBloodGroup,
            );

        // Update profile through notifier
        await ref
            .read(currentUserProvider.notifier)
            .updateProfile(updateRequest);

        setState(() => _isLoading = false);

        if (mounted) {
          successSnack('Profile updated successfully');
          context.pop();
        }
      } catch (e) {
        setState(() => _isLoading = false);

        if (mounted) {
          errorSnack(e.toString().replaceFirst('Exception: ', ''));
        }
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return '${date.day}/${date.month}/${date.year}';
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
        title: const Text(
          'Update Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
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
                // Phone Number
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Date of Birth
                GestureDetector(
                  onTap: () => _selectDate(context),
                  behavior: HitTestBehavior.opaque,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: 'Date of Birth',
                      hint: 'Select your date of birth',
                      controller: _dateOfBirthController,
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      readOnly: true,
                      enabled: true,
                      validator: (value) {
                        if (_selectedDate == null) {
                          return 'Please select your date of birth';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Gender Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: InputDecoration(
                        hintText: 'Select gender',
                        prefixIcon: const Icon(Icons.person_outline),
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
                      items: _genders.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your gender';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Blood Group Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Blood Group',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBloodGroup,
                      decoration: InputDecoration(
                        hintText: 'Select blood group',
                        prefixIcon: const Icon(Icons.bloodtype_outlined),
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
                      items: _bloodGroups.map((String bloodGroup) {
                        return DropdownMenuItem<String>(
                          value: bloodGroup,
                          child: Text(bloodGroup),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBloodGroup = newValue;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Address
                CustomTextField(
                  label: 'Address',
                  hint: 'Enter your address',
                  controller: _addressController,
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Update Button
                CustomButton(
                  text: 'Update Profile',
                  onPressed: _handleUpdate,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
