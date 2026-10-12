import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/config_service.dart';
import 'app/services/supabase_service.dart';
import 'app/controllers/auth_controller.dart';
import 'app/views/splash_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configService = Get.put(ConfigService());

  // ✅ Local Supabase credentials (for development)
  configService.setSupabaseCredentials(
    url: 'https://iyvnjtlbistpaovwhxdr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml5dm5qdGxiaXN0cGFvdndoeGRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk0MjczOTQsImV4cCI6MjA5NTAwMzM5NH0.HdRtDRxjGNdqEeATGMlpBTxG5e-ThXtIhWJdixIjYH8',
  );

  configService.setGeminiApiKey(
    const String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: 'AQ.Ab8RN6Kt28OTa-MhqklaVahh5KiMKLom_5miZggjQLRm1ouFTA',
    ),
  );

  configService.printCurrentConfig();

  await SupabaseService.initialize();

  // Listen to auth state changes globally immediately after initialization
  SupabaseService.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    debugPrint('Global Auth Event: \$event');
    
    if (event == AuthChangeEvent.passwordRecovery) {
      debugPrint('Password recovery event detected!');
      // Wait for navigation to be ready
      Future.delayed(const Duration(milliseconds: 800), () {
        if (Get.currentRoute != AppRoutes.resetPassword) {
          Get.offAllNamed(AppRoutes.resetPassword);
        }
      });
    } else if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
      // If SplashView was holding the navigation because of a 'code' in the URL,
      // and it wasn't a password recovery, route to dashboard.
      if (Uri.base.queryParameters.containsKey('code') && event != AuthChangeEvent.passwordRecovery) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (Get.currentRoute == AppRoutes.splash) {
             Get.offAllNamed(AppRoutes.dashboard);
          }
        });
      }
    }
  });

  runApp(const ResumeAnalyzerApp());
}

class ResumeAnalyzerApp extends StatelessWidget {
  final String initialRoute;
  const ResumeAnalyzerApp({super.key, this.initialRoute = AppRoutes.splash});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ResumeAI',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE9F2F7),
        primaryColor: const Color(0xFF176D8D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176D8D),
          primary: const Color(0xFF176D8D),
          onPrimary: Colors.white,
          surface: const Color(0xFFE9F2F7),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF176D8D)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF176D8D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      unknownRoute: GetPage(name: '/404', page: () => const SplashView()),
      onInit: () {
        Get.put(AuthController(), permanent: true);
      },
    );
  }
}
