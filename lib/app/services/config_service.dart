import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService extends GetxService {
  static const String defaultSupabaseUrl =
      'https://iyvnjtlbistpaovwhxdr.supabase.co';
  static const String defaultSupabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml5dm5qdGxiaXN0cGFvdndoeGRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk0MjczOTQsImV4cCI6MjA5NTAwMzM5NH0.HdRtDRxjGNdqEeATGMlpBTxG5e-ThXtIhWJdixIjYH8';
  static const String defaultGeminiKey =
      'AQ.Ab8RN6Kt28OTa-MhqklaVahh5KiMKLom_5miZggjQLRm1ouFTA';

  final supabaseUrl = defaultSupabaseUrl.obs;
  final supabaseKey = defaultSupabaseKey.obs;
  final geminiApiKey = defaultGeminiKey.obs;

  static ConfigService get to => Get.find();

  bool get isConfigured =>
      supabaseUrl.value.isNotEmpty && supabaseKey.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadSavedKey();
  }

  Future<void> _loadSavedKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString('gemini_api_key');
      if (savedKey != null && savedKey.trim().isNotEmpty) {
        geminiApiKey.value = savedKey.trim();
      }
    } catch (_) {}
  }

  void setSupabaseCredentials({required String url, required String anonKey}) {
    supabaseUrl.value = url;
    supabaseKey.value = anonKey;
  }

  void setGeminiApiKey(String apiKey) {
    geminiApiKey.value = apiKey.trim();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('gemini_api_key', apiKey.trim());
    }).catchError((_) {});
  }

  void printCurrentConfig() {
    debugPrint('=== App Configuration ===');
    debugPrint(
      'URL: ${supabaseUrl.value.isEmpty ? "NOT SET" : supabaseUrl.value}',
    );
    debugPrint('Key: ${supabaseKey.value.isEmpty ? "NOT SET" : "SET"}');
    debugPrint('Configured: $isConfigured');
    debugPrint(
      'Gemini Key: ${geminiApiKey.value.isEmpty ? "NOT SET" : "CONFIGURED (${geminiApiKey.value.length} chars)"}',
    );
    debugPrint('==============================');
  }
}
