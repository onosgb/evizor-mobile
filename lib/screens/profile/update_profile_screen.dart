import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../models/update_profile_request_model.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/toastification.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../address/address_search_screen.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  final bool forceUpdate;

  const UpdateProfileScreen({super.key, this.forceUpdate = false});

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
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedBloodGroup;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  final ImagePicker _picker = ImagePicker();

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
    // Use addPostFrameCallback to ensure the provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // 1. Try immediate read
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        _populateFields(user);
      }

      // 2. Listen for data updates (in case it's still loading)
      // This helps if the profile fetch in SplashScreen hasn't finished yet
      // or if it was triggered elsewhere.
      ref.listenManual(currentUserProvider, (previous, next) {
        if (next.hasValue && next.value != null && mounted) {
          // Only populate if controllers are still mostly empty to avoid overwriting user input
          if (_firstNameController.text.isEmpty &&
              _lastNameController.text.isEmpty) {
            _populateFields(next.value!);
          }
        }
      });
    });
  }

  void _populateFields(User user) {
    setState(() {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber;
      _addressController.text = user.address ?? '';
      _selectedDate = user.dob;
      _selectedGender = user.gender;
      _selectedBloodGroup = user.bloodGroup;
      _dateOfBirthController.text = _formatDate(_selectedDate);
      _weightController.text = user.weight?.toString() ?? '';
      _heightController.text = user.height?.toString() ?? '';
    });
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      final file = File(image.path);
      final sizeInBytes = await file.length();
      if (sizeInBytes > 5 * 1024 * 1024) {
        if (mounted) errorSnack('Image must be smaller than 5MB');
        return;
      }

      setState(() => _isUploadingPhoto = true);
      await ref
          .read(currentUserProvider.notifier)
          .uploadProfilePicture(image.path);

      if (mounted) successSnack('Profile photo updated');
    } catch (e) {
      if (mounted) errorSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Update Profile Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primaryColor,
              ),
              title: const Text('Take Photo'),
              onTap: () => _pickAndUploadPhoto(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primaryColor,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () => _pickAndUploadPhoto(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _openAddressSearch(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const AddressSearchScreen()),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _addressController.text = result);
    }
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
              weight: double.tryParse(_weightController.text.trim()),
              height: double.tryParse(_heightController.text.trim()),
            );

        // Update profile through notifier
        await ref
            .read(currentUserProvider.notifier)
            .updateProfile(updateRequest);

        // Also update the persistent storage for profile completion
        await ref
            .read(storageServiceProvider)
            .saveProfileCompletionStatus(true);

        setState(() => _isLoading = false);

        if (mounted) {
          successSnack('Profile updated successfully');
          if (widget.forceUpdate) {
            context.go(AppRoutes.home);
          } else {
            context.pop();
          }
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

  Widget _buildAvatarWidget(WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final photoUrl = user?.profilePictureUrl;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightBlue,
        border: Border.all(color: AppColors.primaryColor, width: 2),
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
                errorWidget: (_, _, _) => const Icon(
                  Icons.person,
                  size: 56,
                  color: AppColors.primaryPurple,
                ),
              )
            : const Icon(
                Icons.person,
                size: 56,
                color: AppColors.primaryPurple,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.forceUpdate,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.forceUpdate) {
          infoSnack('Please complete your profile to continue');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: !widget.forceUpdate,
          leading: widget.forceUpdate
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
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
                  // Profile photo
                  Center(
                    child: GestureDetector(
                      onTap: _isUploadingPhoto ? null : _showPhotoOptions,
                      child: Stack(
                        children: [
                          _buildAvatarWidget(ref),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: _isUploadingPhoto
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  // Weight
                  CustomTextField(
                    label: 'Weight (kg)',
                    hint: 'Enter your weight',
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  ),
                  const SizedBox(height: 20),
                  // Height
                  CustomTextField(
                    label: 'Height (cm)',
                    hint: 'Enter your height',
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: const Icon(Icons.height_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Height is required';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Address
                  GestureDetector(
                    onTap: () => _openAddressSearch(context),
                    behavior: HitTestBehavior.opaque,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        label: 'Address',
                        hint: 'Enter your address',
                        controller: _addressController,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        maxLines: 2,
                        readOnly: true,
                        enabled: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                    ),
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
      ),
    );
  }
}
