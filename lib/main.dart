import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/config_service.dart';
import 'app/services/supabase_service.dart';
import 'app/widgets/responsive_builder.dart';

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
    );
  }
}
