
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService extends GetxService {
  static const String defaultSupabaseUrl =
      'https://vtnxkpvgnkvonbateich.supabase.co';

  // Use the same publishable key that you use in main.dart.
  static const String defaultSupabaseKey =
      'YOUR_SUPABASE_PUBLISHABLE_KEY';

  static const String defaultGeminiKey = '';

  final supabaseUrl = defaultSupabaseUrl.obs;
  final supabaseKey = defaultSupabaseKey.obs;
  final geminiApiKey = defaultGeminiKey.obs;

  static ConfigService get to => Get.find<ConfigService>();

  bool get isConfigured =>
      supabaseUrl.value.isNotEmpty &&
          supabaseKey.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadSavedKey();
  }

  Future<void> loadSavedKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString('gemini_api_key');

      if (savedKey != null) {
        geminiApiKey.value = savedKey.trim();
      }
    } catch (error) {
      debugPrint('Unable to load saved Gemini key: $error');
    }
  }

  void setSupabaseCredentials({
    required String url,
    required String anonKey,
  }) {
    supabaseUrl.value = url.trim();
    supabaseKey.value = anonKey.trim();
  }

  Future<void> setGeminiApiKey(String apiKey) async {
    final trimmedKey = apiKey.trim();

    try {
      final prefs = await SharedPreferences.getInstance();

      if (trimmedKey.isEmpty) {
        await prefs.remove('gemini_api_key');
      } else {
        await prefs.setString('gemini_api_key', trimmedKey);
      }

      geminiApiKey.value = trimmedKey;
    } catch (error) {
      debugPrint('Unable to save Gemini key: $error');
      rethrow;
    }
  }

  void printCurrentConfig() {
    debugPrint('=== App Configuration ===');
    debugPrint('URL: ${supabaseUrl.value}');
    debugPrint(
      'Supabase Key: ${supabaseKey.value.isEmpty ? "NOT SET" : "SET"}',
    );
    debugPrint('Configured: $isConfigured');
    debugPrint(
      'Gemini Key: ${geminiApiKey.value.isEmpty ? "NOT SET" : "CONFIGURED"}',
    );
    debugPrint('==========================');
  }
}
