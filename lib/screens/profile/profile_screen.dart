import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../services/api_client.dart';
import '../../services/storage_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Blue Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 60),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          context.push(AppRoutes.settings);
                        },
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 90),
                        // Personal Information Section
                        _buildPersonalInformationSection(ref),
                        const SizedBox(height: 16),
                        // Medical History Section
                        _buildMedicalHistorySection(),
                        const SizedBox(height: 24),
                        // Logout Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildLogoutButton(context, ref),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // User Profile Card - Positioned to overlap header
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: _buildUserProfileCard(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserSyncProvider);
    final userName = user?.fullName ?? 'John Doe';
    final patientId = user?.id.isNotEmpty == true
        ? '#P-${user!.id.substring(0, 8)}'
        : '#P-2024-001';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(width: 16),
          // Name and Patient ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Patient ID: $patientId',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Edit Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationSection(WidgetRef ref) {
    final user = ref.watch(currentUserSyncProvider);
    final email = user?.email ?? 'john.doe@email.com';
    final phone = user?.phoneNumber ?? '+1 (555) 123-4567';
    final dob = user?.dateOfBirth != null
        ? '${user!.dateOfBirth!.day} ${_getMonthName(user.dateOfBirth!.month)}, ${user.dateOfBirth!.year}'
        : 'Jan 15, 1990';
    final gender = user?.gender ?? 'Male';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Email', email),
          const SizedBox(height: 12),
          _buildInfoRow('Phone', phone),
          const SizedBox(height: 12),
          _buildInfoRow('Date of Birth', dob),
          const SizedBox(height: 12),
          _buildInfoRow('Gender', gender),
          const SizedBox(height: 12),
          _buildInfoRow('Blood Group', 'O+'),
        ],
      ),
    );
  }

  Widget _buildMedicalHistorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medical History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Consultations',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                '12',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Prescriptions',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                '2',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last Visit',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                'Jan 27, 2026',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (shouldLogout == true && context.mounted) {
            // Clear all user data and tokens
            final storageService = StorageService();
            await storageService.logout(); // Clears tokens and user data

            // Clear user provider state
            ref.read(currentUserSyncProvider.notifier).state = null;

            // Remove auth token from API client
            ApiClient().removeAuthToken();

            // Navigate to login
            if (context.mounted) {
              context.go(AppRoutes.login);
            }
          }
        },
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
