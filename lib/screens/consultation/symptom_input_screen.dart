import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/symptoms_provider.dart';
import '../../providers/consultation_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/toastification.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SymptomInputScreen extends ConsumerStatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  ConsumerState<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends ConsumerState<SymptomInputScreen> {
  final _descriptionController = TextEditingController();

  // Store selected components by ID
  final Set<String> _selectedSymptomIds = {};
  String _duration = '';
  double _severity = 5.0;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Describe Symptoms'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final symptomsAsync = ref.watch(symptomsProvider);

            return symptomsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error.toString().replaceFirst('Exception: ', ''),
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          ref.invalidate(symptomsProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (symptoms) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'What are your symptoms?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Symptom Chips
                      const Text(
                        'Select symptoms',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      symptoms.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No symptoms available',
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton.icon(
                                    onPressed: () {
                                      ref.invalidate(symptomsProvider);
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _buildSymptomCarousel(symptoms),
                      const SizedBox(height: 32),
                      // Description
                      CustomTextField(
                        label: 'Description',
                        hint: '(Optional) Describe your symptoms in detail',
                        controller: _descriptionController,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 32),
                      // Duration
                      const Text(
                        'How long have you had these symptoms?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            [
                              'Less than 1 day',
                              '1-3 days',
                              '4-7 days',
                              'More than 1 week',
                            ].map((duration) {
                              final isSelected = _duration == duration;
                              return ChoiceChip(
                                label: Text(duration),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(
                                    () => _duration = selected ? duration : '',
                                  );
                                },
                                selectedColor: AppColors.primaryColor
                                    .withValues(alpha: 0.2),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 32),
                      // Severity
                      const Text(
                        'Severity (1-10)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('1', style: TextStyle(color: Colors.grey)),
                          Expanded(
                            child: Slider(
                              value: _severity,
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: _severity.round().toString(),
                              onChanged: (value) {
                                setState(() => _severity = value);
                              },
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          const Text(
                            '10',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Container(
                            width: 40,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _severity.round().toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Continue Button
                      Consumer(
                        builder: (context, ref, child) {
                          final appointmentState = ref.watch(
                            appointmentNotifierProvider,
                          );

                          return CustomButton(
                            text: appointmentState.isLoading
                                ? 'Creating...'
                                : 'Continue',
                            onPressed: appointmentState.isLoading
                                ? null
                                : () async {
                                    // Validate inputs
                                    if (_selectedSymptomIds.isEmpty) {
                                      errorSnack(
                                        'Please select at least one symptom',
                                      );
                                      return;
                                    }

                                    // Description is optional now

                                    if (_duration.isEmpty) {
                                      errorSnack(
                                        'Please select symptom duration',
                                      );
                                      return;
                                    }

                                    // Save draft appointment data (don't submit to database yet)
                                    ref
                                        .read(
                                          appointmentNotifierProvider.notifier,
                                        )
                                        .saveDraftAppointment(
                                          symptomIds: _selectedSymptomIds
                                              .toList(),
                                          description: _descriptionController
                                              .text
                                              .trim(),
                                          duration: _duration,
                                          severity: _severity.round(),
                                        );

                                    // Navigate to upload files screen
                                    if (context.mounted) {
                                      context.push(AppRoutes.uploadFiles);
                                    }
                                  },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSymptomCarousel(List<dynamic> symptoms) {
    return Column(
      children: [
        // Horizontal scrollable symptoms with 3 rows
        SizedBox(
          height: 130, // Compact height for 3 rows
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 140, // Width of each item
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 0.3,
            ),
            itemCount: symptoms.length,
            itemBuilder: (context, index) {
              final symptom = symptoms[index];
              final isSelected = _selectedSymptomIds.contains(symptom.id);

              return FilterChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(
                    symptom.name,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSymptomIds.add(symptom.id);
                    } else {
                      _selectedSymptomIds.remove(symptom.id);
                    }
                  });
                },
                selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                // Ensure chip fills the grid cell
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Selected symptoms counter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_selectedSymptomIds.length} symptom${_selectedSymptomIds.length == 1 ? '' : 's'} selected',
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
