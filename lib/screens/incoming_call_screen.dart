import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/call_provider.dart';
import '../routes/app_router.dart';
import '../widgets/incoming_call_banner.dart';
import '../utils/app_routes.dart';

class IncomingCallScreen extends ConsumerStatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen> {
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    FlutterRingtonePlayer().playRingtone();
  }

  @override
  void dispose() {
    if (_handled) {
      FlutterRingtonePlayer().stop();
    }
    super.dispose();
  }

  void _minimizeCall() {
    if (!_handled) {
      final callState = ref.read(callProvider);
      if (callState.status == CallStatus.incoming &&
          callState.payload != null) {
        _showBanner(callState.payload!);
      }
      setState(() => _handled = true); // Mark handled so dispose doesn't act
    }
    Navigator.of(context).pop();
  }

  void _showBanner(Map<String, dynamic> payload) {
    if (rootNavigatorKey.currentContext != null) {
      toastification.showCustom(
        context: rootNavigatorKey.currentContext,
        autoCloseDuration: const Duration(seconds: 30),
        alignment: Alignment.topCenter,
        animationDuration: const Duration(milliseconds: 400),
        builder: (BuildContext context, ToastificationItem holder) {
          return IncomingCallBanner(payload: payload, toastItem: holder);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callProvider);
    final payload = callState.payload ?? {};
    final status = callState.status;

    final doctorName = payload['doctorName'] ?? 'Doctor';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _minimizeCall();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E), // Dark background
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Row for "Minimize" button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: _minimizeCall,
                  ),
                ),
              ),
              const Spacer(),

              // Incoming call ID section
              if (status == CallStatus.calling) ...[
                const CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 2,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Connecting...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Doctor is joining the consultation",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ] else if (status == CallStatus.incoming) ...[
                // Avatar Placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  doctorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Incoming Video Consultation",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ] else if (status == CallStatus.active) ...[
                // Token acquired — navigating to call screen
                const CircularProgressIndicator(
                  color: Colors.greenAccent,
                  strokeWidth: 2,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Joining consultation...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                // True idle/ended fallback
                const Text(
                  "Consultation session has ended",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ],

              const Spacer(),

              if (status == CallStatus.incoming)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Decline Button
                      _CallActionButton(
                        icon: Icons.call_end,
                        color: Colors.redAccent,
                        label: "Decline",
                        onPressed: () => _showConfirmationDialog(
                          context,
                          title: "Decline Call",
                          message:
                              "Are you sure you want to decline this consultation?",
                          onConfirm: () async {
                            final appointmentId = payload['appointmentId'];
                            if (appointmentId != null) {
                              try {
                                await ref
                                    .read(callProvider.notifier)
                                    .rejectCall(appointmentId.toString());
                              } catch (e) {
                                // Error handled in provider
                              }
                            }
                            setState(() {
                              _handled = true;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      // Accept Button
                      _CallActionButton(
                        icon: Icons.videocam,
                        color: Colors.greenAccent,
                        label: "Accept",
                        onPressed: () async {
                          final appointmentId = payload['appointmentId'];
                          if (appointmentId != null) {
                            setState(() {
                              _handled = true;
                            });
                            FlutterRingtonePlayer().stop();
                            final messenger = ScaffoldMessenger.of(context);
                            final router = GoRouter.of(context);
                            try {
                              await ref
                                  .read(callProvider.notifier)
                                  .acceptCall(appointmentId.toString());

                              if (mounted) router.push(AppRoutes.videoCall);
                            } catch (e) {
                              setState(() => _handled = false);
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceAll('Exception: ', ''),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: title.contains("Decline")
                    ? Colors.redAccent
                    : Colors.greenAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onPressed;

  const _CallActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
