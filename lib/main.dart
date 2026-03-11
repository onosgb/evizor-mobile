import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import 'services/api_client.dart';
import 'services/signaling_service.dart';
import 'providers/appointment_provider.dart';
import 'providers/call_provider.dart';
import 'models/appointment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client and load token from storage
  await ApiClient().initializeToken();

  // Initialize signaling service
  final signalingService = SignalingService();
  await signalingService.connect();

  signalingService.onCallProgress = (payload) {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      final container = ProviderScope.containerOf(context);
      container.read(callProvider.notifier).handleProgress(payload);

      // Update state immediately with progress data
      container
          .read(latestAppointmentProvider.notifier)
          .updateState(Appointment.fromJson(payload));

      // Ensure other lists are also fresh
      container.read(appointmentsNotifierProvider.notifier).refresh();

      // Only navigate to assigned if currently on the waiting queue page
      final currentPath = appRouter.routeInformationProvider.value.uri.path;
      if (currentPath == '/queue/waiting') {
        appRouter.go('/queue/assigned');
      }
    }
  };

  signalingService.onIncomingCall = (payload) {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      // Refresh appointment state immediately when a call comes in
      final container = ProviderScope.containerOf(context);
      container.read(appointmentsNotifierProvider.notifier).refresh();
      container.invalidate(latestAppointmentProvider);

      container.read(callProvider.notifier).handleIncoming(payload);

      appRouter.go('/queue/incoming');
    }
  };

  signalingService.onAppointmentAttended = (payload) {
    final currentPath = appRouter.routeInformationProvider.value.uri.path;
    if (currentPath == '/queue/waiting') {
      appRouter.go('/queue/assigned');
    }
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Evizor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
        builder: (context, child) {
          return ToastificationConfigProvider(
            config: const ToastificationConfig(
              // margin: EdgeInsets.fromLTRB(0, 16, 0, 110),
              alignment: Alignment.center,
              itemWidth: 440,
              animationDuration: Duration(milliseconds: 500),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
