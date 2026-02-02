import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class WaitingQueueScreen extends StatefulWidget {
  const WaitingQueueScreen({super.key});

  @override
  State<WaitingQueueScreen> createState() => _WaitingQueueScreenState();
}

class _WaitingQueueScreenState extends State<WaitingQueueScreen>
    with SingleTickerProviderStateMixin {
  int _queuePosition = 3;
  int _estimatedMinutes = 8;
  Timer? _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _queuePosition > 0) {
        setState(() {
          _queuePosition--;
          _estimatedMinutes = _estimatedMinutes > 1 ? _estimatedMinutes - 1 : 1;
          if (_queuePosition == 0) {
            context.go(AppRoutes.doctorAssigned);
          }
        });
      }
    });
  }

  void _handleCancel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text(
          'Are you sure you want to cancel your consultation request?',
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('No')),
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        24.0,
                        20.0,
                        24.0,
                        32.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Queue Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.people_outline,
                              color: AppColors.primaryColor,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Title
                          const Text(
                            "You're in the Queue",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Subtitle
                          Text(
                            'Please wait while we connect you with a doctor',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Queue Position Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 32,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '#$_queuePosition',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your position in queue',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Estimated Wait Time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Estimated wait: $_estimatedMinutes minutes',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Cancel Request Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _handleCancel,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel Request',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Animated Loading Dots - Outside the card
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      // Calculate delay for each dot (0, 0.2, 0.4)
                      final delay = index * 0.2;
                      final animationValue =
                          (_animationController.value + delay) % 1.0;

                      // Create pulsing effect
                      final scale =
                          0.5 + (0.5 * (1 - (animationValue * 2 - 1).abs()));
                      final opacity =
                          0.3 + (0.7 * (1 - (animationValue * 2 - 1).abs()));

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8 * scale,
                        height: 8 * scale,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(
                            alpha: opacity,
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
