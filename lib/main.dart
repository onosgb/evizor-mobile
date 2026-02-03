import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client and load token from storage
  await ApiClient().initializeToken();

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
