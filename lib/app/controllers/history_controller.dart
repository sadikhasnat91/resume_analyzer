import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resume_item.dart';
import '../services/supabase_service.dart';

class HistoryController extends GetxController {
  final resumes = <ResumeItem>[].obs;
  final isLoading = false.obs;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges();
    fetchHistory();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  void _listenToAuthChanges() {
    try {
      if (!SupabaseService.isReady) return;
      _authSubscription = SupabaseService.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.initialSession ||
            event == AuthChangeEvent.tokenRefreshed) {
          fetchHistory();
        } else if (event == AuthChangeEvent.signedOut) {
          resumes.clear();
        }
      });
    } catch (e) {
      debugPrint('Error setting up auth subscription in HistoryController: $e');
    }
  }

  Future<void> fetchHistory() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      debugPrint('fetchHistory: Supabase user is not logged in');
      return;
    }

    final userId = user.id;

    // Load user-specific local cache
    await _loadUserLocalHistory(userId);

    // Auto-sync any pending local items that don't have an ID in Supabase yet
    final unsynced =
        resumes.where((r) => r.id == null || r.id!.isEmpty).toList();
    for (final item in unsynced) {
      try {
        final insertResponse = await SupabaseService.client
            .from('resume_history')
            .insert(item.toSupabaseMap(userId))
            .select();
        if (insertResponse.isNotEmpty) {
          final newId = insertResponse.first['id']?.toString();
          if (newId != null) {
            final idx = resumes.indexOf(item);
            if (idx != -1) {
              resumes[idx] = item.copyWith(id: newId);
            }
          }
        }
      } catch (e) {
        debugPrint('Auto-sync unsaved item to Supabase failed: $e');
      }
    }

    isLoading.value = true;
    try {
      final response = await SupabaseService.client
          .from('resume_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final cloudItems = <ResumeItem>[];
      for (final item in response) {
        try {
          final map = Map<String, dynamic>.from(item as Map);
          final createdAt = map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString())
              : null;
          final dateStr = createdAt != null
              ? '${_monthName(createdAt.month)} ${createdAt.day}, ’${createdAt.year % 100}'
              : 'Today';

          map['date'] = dateStr;
          cloudItems.add(ResumeItem.fromJson(map));
        } catch (e) {
          debugPrint('Error parsing cloud resume item: $e');
        }
      }

      // Preserve any still-unsynced local items (e.g., temporary network issue)
      final stillPending =
          resumes.where((r) => r.id == null || r.id!.isEmpty).toList();

      // Merge and deduplicate by id if present
      final seenIds = <String>{};
      final uniqueItems = <ResumeItem>[];
      for (final item in [...stillPending, ...cloudItems]) {
        if (item.id != null && item.id!.isNotEmpty) {
          if (!seenIds.add(item.id!)) continue;
        }
        uniqueItems.add(item);
      }

      resumes.assignAll(uniqueItems);
      await _saveUserLocalHistory(userId);
    } catch (e) {
      debugPrint('Error fetching history from Supabase: $e');
      // Do not wipe local resumes if Supabase fetch failed!
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addResume(Map<String, dynamic> analysisData) async {
    final now = DateTime.now();
    final dateStr = '${_monthName(now.month)} ${now.day}, ’${now.year % 100}';

    final scoreVal = analysisData['score'] as int? ?? 0;
    var newItem = ResumeItem(
      name: (analysisData['fileName'] ?? analysisData['name'])?.toString() ??
          'resume.pdf',
      category: analysisData['category']?.toString() ?? 'Software Engineering',
      seniority: analysisData['seniority']?.toString() ?? 'Senior',
      date: dateStr,
      score: '$scoreVal%',
      scoreValue: scoreVal,
      strengths: (analysisData['strengths'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      weaknesses: (analysisData['weaknesses'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      suggestions: (analysisData['suggestions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );

    resumes.insert(0, newItem);

    final user = SupabaseService.currentUser;
    if (user != null) {
      await _saveUserLocalHistory(user.id);
      try {
        final userId = user.id;
        final response = await SupabaseService.client
            .from('resume_history')
            .insert(newItem.toSupabaseMap(userId))
            .select();

        if (response.isNotEmpty) {
          final insertedId = response.first['id']?.toString();
          if (insertedId != null) {
            final idx = resumes.indexOf(newItem);
            if (idx != -1) {
              resumes[idx] = newItem.copyWith(id: insertedId);
              await _saveUserLocalHistory(user.id);
            }
          }
        }
      } catch (e) {
        debugPrint('Supabase insert error (saved locally): $e');
      }
    }
  }

  Future<void> deleteResume(int index) async {
    if (index >= 0 && index < resumes.length) {
      final item = resumes[index];
      resumes.removeAt(index);

      final user = SupabaseService.currentUser;
      if (user != null) {
        await _saveUserLocalHistory(user.id);

        if (item.id != null) {
          try {
            await SupabaseService.client
                .from('resume_history')
                .delete()
                .eq('id', item.id!);
          } catch (e) {
            debugPrint('Error deleting from Supabase: $e');
          }
        }
      }
    }
  }

  Future<void> _loadUserLocalHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Purge any legacy shared mock data key
      await prefs.remove('saved_resumes');

      final String? jsonStr = prefs.getString('saved_resumes_$userId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final items = <ResumeItem>[];
        for (final item in list) {
          if (item is Map) {
            try {
              final parsed =
                  ResumeItem.fromJson(Map<String, dynamic>.from(item));
              // Filter out any leftover mock resumes
              if (parsed.name != 'JohnDoe_SE.pdf' &&
                  parsed.name != 'Sarah_MK.pdf' &&
                  parsed.name != 'Michael_DS.pdf') {
                items.add(parsed);
              }
            } catch (e) {
              debugPrint('Error parsing local item: $e');
            }
          }
        }
        if (resumes.isEmpty) {
          resumes.assignAll(items);
        } else {
          final seenKeys = <String>{};
          for (final r in resumes) {
            seenKeys.add(r.id ?? '${r.name}_${r.date}_${r.scoreValue}');
          }
          for (final item in items) {
            final key =
                item.id ?? '${item.name}_${item.date}_${item.scoreValue}';
            if (seenKeys.add(key)) {
              resumes.add(item);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Local history load error: $e');
    }
    // No default mock resumes added here!
  }

  Future<void> _saveUserLocalHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = resumes.map((item) => item.toJson()).toList();
      await prefs.setString('saved_resumes_$userId', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Local history save error: $e');
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
