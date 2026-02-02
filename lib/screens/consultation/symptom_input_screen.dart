import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> {
  final _descriptionController = TextEditingController();
  final List<String> _symptoms = [
    'Fever',
    'Cough',
    'Headache',
    'Fatigue',
    'Nausea',
    'Pain',
    'Dizziness',
    'Shortness of breath',
  ];
  final Set<String> _selectedSymptoms = {};
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
        child: SingleChildScrollView(
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptoms.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(symptom),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryColor.withValues(
                      alpha: 0.2,
                    ),
                    checkmarkColor: AppColors.primaryColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // Description
              CustomTextField(
                label: 'Description',
                hint: 'Describe your symptoms in detail',
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
                          setState(() => _duration = selected ? duration : '');
                        },
                        selectedColor: AppColors.primaryColor.withValues(
                          alpha: 0.2,
                        ),
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
                  const Text('10', style: TextStyle(color: Colors.grey)),
                  Container(
                    width: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
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
              CustomButton(
                text: 'Continue',
                onPressed: () {
                  context.push(AppRoutes.uploadFiles);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
