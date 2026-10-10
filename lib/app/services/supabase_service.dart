import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config_service.dart';

class SupabaseService {
  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String _supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool _initialized = false;

  static bool get isConfigured {
    final configService = ConfigService.to;
    final envUrl = _supabaseUrl.isNotEmpty ? _supabaseUrl : '';
    final envKey = _supabasePublishableKey.isNotEmpty
        ? _supabasePublishableKey
        : '';

    return (envUrl.isNotEmpty && envKey.isNotEmpty) ||
        (configService.supabaseUrl.value.isNotEmpty &&
            configService.supabaseKey.value.isNotEmpty);
  }

  static bool get isInitialized => _initialized;

  static bool get isReady => _initialized && isConfigured;

  static User? get currentUser {
    try {
      if (isReady) {
        return client.auth.currentUser;
      }
    } catch (_) {}
    return null;
  }

  static GoTrueClient get auth => client.auth;

  static Future<bool> initialize() async {
    final configService = ConfigService.to;

    // Priority: environment variables > config service
    String url = _supabaseUrl.isNotEmpty
        ? _supabaseUrl
        : configService.supabaseUrl.value;
    String key = _supabasePublishableKey.isNotEmpty
        ? _supabasePublishableKey
        : configService.supabaseKey.value;

    debugPrint('=== Supabase Initialization ===');
    debugPrint('URL: ${url.isEmpty ? "NOT SET" : url}');
    debugPrint('Key: ${key.isEmpty ? "NOT SET" : "SET"}');
    debugPrint('Using env vars: ${_supabaseUrl.isNotEmpty}');

    if (url.isEmpty || key.isEmpty) {
      debugPrint('ERROR: Supabase not configured!');
      debugPrint(
        'Add credentials via: flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key',
      );
      debugPrint('OR set in ConfigService.setSupabaseCredentials()');
      return false;
    }

    try {
      await Supabase.initialize(url: url, publishableKey: key);
      _initialized = true;
      debugPrint('✓ Supabase initialized successfully');
      return true;
    } catch (e, stackTrace) {
      debugPrint('✗ Supabase initialization failed: $e');
      debugPrint(stackTrace.toString());
      return false;
    }
  }

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        'Supabase has not been initialized. Call SupabaseService.initialize() first.',
      );
    }
    return Supabase.instance.client;
  }
}
