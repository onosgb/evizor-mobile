import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/consultation_provider.dart';
import '../../providers/symptoms_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/toastification.dart';
import '../../widgets/custom_button.dart';

class ReviewConfirmScreen extends ConsumerStatefulWidget {
  const ReviewConfirmScreen({super.key});

  @override
  ConsumerState<ReviewConfirmScreen> createState() =>
      _ReviewConfirmScreenState();
}

class _ReviewConfirmScreenState extends ConsumerState<ReviewConfirmScreen> {
  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentNotifierProvider);
    final symptomsAsync = ref.watch(symptomsProvider);

    // Get draft data
    final draftSymptomIds = appointmentState.draftSymptomIds ?? [];
    final draftDescription = appointmentState.draftDescription ?? '';
    final draftDuration = appointmentState.draftDuration ?? '';
    final draftSeverity = appointmentState.draftSeverity ?? 0;
    final draftFiles = appointmentState.draftUploadedFiles ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    const Text(
                      'Review & Confirm',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      'Check your information before joining the queue',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    // Symptoms Summary Card
                    symptomsAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (_, _) => const SizedBox(),
                      data: (allSymptoms) {
                        // Get symptom names from IDs
                        final selectedSymptoms = allSymptoms
                            .where((s) => draftSymptomIds.contains(s.id))
                            .toList();

                        return _buildSection(
                          title: 'Symptoms Summary',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedSymptoms.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedSymptoms.map((symptom) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.lightBlue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        symptom.name,
                                        style: const TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 12),
                              Text(
                                '$draftDescription\n\nDuration: $draftDuration\nSeverity: $draftSeverity/10',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Attachments Card
                    _buildSection(
                      title: 'Attachments',
                      child: Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            draftFiles.isEmpty
                                ? 'No files uploaded'
                                : '${draftFiles.length} file${draftFiles.length == 1 ? '' : 's'} uploaded',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Estimated Wait Time Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.access_time,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Estimated Wait Time',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Approximately 5-10 minutes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Join Queue Button - Fixed at bottom
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: CustomButton(
                text: appointmentState.isLoading
                    ? 'Joining Queue...'
                    : 'Join Queue',
                onPressed: appointmentState.isLoading
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(appointmentNotifierProvider.notifier)
                              .submitAppointment();

                          if (context.mounted) {
                            successSnack('Appointment created successfully');
                            context.go(AppRoutes.waitingQueue);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            errorSnack(
                              appointmentState.error ??
                                  'Failed to create appointment. Please try again.',
                            );
                          }
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
