import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'router/app_router.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase Core initialization skipped: $e');
  }

  await initializeDateFormatting('en_IN', null);
  final container = ProviderContainer();
  
  // Initialize notification service early
  try {
    await container.read(notificationServiceProvider).initialize();
  } catch (e) {
     debugPrint('Notification Service initialization failed: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SolapurTurfApp(),
    ),
  );
}

class SolapurTurfApp extends ConsumerWidget {
  const SolapurTurfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Solapur Turf Booking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
