import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/resume_item.dart';
import '../services/supabase_service.dart';

class HistoryController extends GetxController {
  final resumes = <ResumeItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      await _loadLocalHistory();

      final user = SupabaseService.currentUser;
      if (user != null) {
        final userId = user.id;
        final response = await SupabaseService.client
            .from('resume_history')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        if (response.isNotEmpty) {
          final cloudItems = <ResumeItem>[];
          for (final item in response) {
            try {
              final map = Map<String, dynamic>.from(item as Map);
              final createdAt =
                  map['created_at'] != null
                      ? DateTime.tryParse(map['created_at'].toString())
                      : null;
              final dateStr =
                  createdAt != null
                      ? '${_monthName(createdAt.month)} ${createdAt.day}, ’${createdAt.year % 100}'
                      : 'Today';

              map['date'] = dateStr;
              cloudItems.add(ResumeItem.fromJson(map));
            } catch (e) {
              debugPrint('Error parsing cloud resume item: $e');
            }
          }

          if (cloudItems.isNotEmpty) {
            resumes.assignAll(cloudItems);
            await _saveLocalHistory();
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching history from Supabase: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addResume(Map<String, dynamic> analysisData) async {
    final now = DateTime.now();
    final dateStr = '${_monthName(now.month)} ${now.day}, ’${now.year % 100}';

    final scoreVal = analysisData['score'] as int? ?? 0;
    final newItem = ResumeItem(
      name:
          (analysisData['fileName'] ?? analysisData['name'])?.toString() ??
          'resume.pdf',
      category: analysisData['category']?.toString() ?? 'Software Engineering',
      seniority: analysisData['seniority']?.toString() ?? 'Senior',
      date: dateStr,
      score: '$scoreVal%',
      scoreValue: scoreVal,
      strengths:
          (analysisData['strengths'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      weaknesses:
          (analysisData['weaknesses'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      suggestions:
          (analysisData['suggestions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );

    resumes.insert(0, newItem);
    await _saveLocalHistory();

    final user = SupabaseService.currentUser;
    if (user != null) {
      try {
        final userId = user.id;
        await SupabaseService.client.from('resume_history').insert({
          'user_id': userId,
          'file_name': newItem.name,
          'category': newItem.category,
          'seniority': newItem.seniority,
          'score': newItem.scoreValue,
          'strengths': newItem.strengths,
          'weaknesses': newItem.weaknesses,
          'suggestions': newItem.suggestions,
        });
      } catch (e) {
        debugPrint('Supabase insert error (saved locally): $e');
      }
    }
  }

  Future<void> deleteResume(int index) async {
    if (index >= 0 && index < resumes.length) {
      final item = resumes[index];
      resumes.removeAt(index);
      await _saveLocalHistory();

      if (item.id != null && SupabaseService.currentUser != null) {
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

  Future<void> _loadLocalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('saved_resumes');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final items = <ResumeItem>[];
        for (final item in list) {
          if (item is Map) {
            try {
              items.add(ResumeItem.fromJson(Map<String, dynamic>.from(item)));
            } catch (e) {
              debugPrint('Error parsing local item: $e');
            }
          }
        }
        if (items.isNotEmpty) {
          resumes.assignAll(items);
          return;
        }
      }
    } catch (e) {
      debugPrint('Local history load error: $e');
    }

    if (resumes.isEmpty) {
      resumes.assignAll([
        ResumeItem(
          name: 'JohnDoe_SE.pdf',
          date: 'Oct 26, ’24',
          score: '78%',
          category: 'Software Engineering',
          seniority: 'Senior',
        ),
        ResumeItem(
          name: 'Sarah_MK.pdf',
          date: 'Oct 24, ’24',
          score: '84%',
          category: 'Marketing',
          seniority: 'Mid',
        ),
        ResumeItem(
          name: 'Michael_DS.pdf',
          date: 'Oct 20, ’24',
          score: '72%',
          category: 'Data Science',
          seniority: 'Junior',
        ),
      ]);
    }
  }

  Future<void> _saveLocalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = resumes.map((item) => item.toJson()).toList();
      await prefs.setString('saved_resumes', jsonEncode(jsonList));
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
