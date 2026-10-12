import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_resume_analyzer/app/models/resume_item.dart';

void main() {
  group('ResumeItem Supabase serialization & deserialization tests', () {
    test('toSupabaseMap produces payload matching Supabase resume_history schema', () {
      final item = ResumeItem(
        name: 'John_Doe_CV.pdf',
        category: 'Software Engineering',
        seniority: 'Senior',
        date: 'Oct 12, ’26',
        score: '88%',
        scoreValue: 88,
        strengths: ['Clean structure', 'Strong metrics'],
        weaknesses: ['Add GitHub links'],
        suggestions: ['Include more open source contributions'],
      );

      final supabaseMap = item.toSupabaseMap('user-uuid-1234');

      // Valid columns on Supabase `resume_history`
      expect(supabaseMap['user_id'], 'user-uuid-1234');
      expect(supabaseMap['file_name'], 'John_Doe_CV.pdf');
      expect(supabaseMap['score'], 88);
      expect(supabaseMap.containsKey('feedback'), isFalse);
      expect(supabaseMap['metadata'], isA<Map<String, dynamic>>());

      final meta = supabaseMap['metadata'] as Map<String, dynamic>;
      expect(meta['category'], 'Software Engineering');
      expect(meta['seniority'], 'Senior');
      expect(meta['strengths'], ['Clean structure', 'Strong metrics']);
      expect(meta['weaknesses'], ['Add GitHub links']);
      expect(meta['suggestions'], ['Include more open source contributions']);
      expect(meta['feedback'], 'Include more open source contributions');

      // Ensure disallowed standalone columns are not present at the root
      expect(supabaseMap.containsKey('category'), isFalse);
      expect(supabaseMap.containsKey('seniority'), isFalse);
      expect(supabaseMap.containsKey('strengths'), isFalse);
      expect(supabaseMap.containsKey('weaknesses'), isFalse);
      expect(supabaseMap.containsKey('suggestions'), isFalse);
    });

    test('fromJson correctly parses Supabase cloud response containing metadata', () {
      final cloudJson = {
        'id': 'rec-9988-uuid',
        'user_id': 'user-uuid-1234',
        'file_name': 'My_Resume.pdf',
        'score': 85,
        'metadata': {
          'category': 'Data Science',
          'seniority': 'Lead',
          'strengths': ['Solid Python', 'ML experience'],
          'weaknesses': ['Lacks cloud certifications'],
          'suggestions': ['Get AWS/GCP certified'],
        },
        'feedback': 'Get AWS/GCP certified',
        'created_at': '2026-10-12T08:30:00Z',
      };

      final parsed = ResumeItem.fromJson(cloudJson);

      expect(parsed.id, 'rec-9988-uuid');
      expect(parsed.name, 'My_Resume.pdf');
      expect(parsed.scoreValue, 85);
      expect(parsed.score, '85%');
      expect(parsed.category, 'Data Science');
      expect(parsed.seniority, 'Lead');
      expect(parsed.strengths, ['Solid Python', 'ML experience']);
      expect(parsed.weaknesses, ['Lacks cloud certifications']);
      expect(parsed.suggestions, ['Get AWS/GCP certified']);
    });

    test('fromJson correctly parses metadata when encoded as JSON string', () {
      final cloudJson = {
        'id': 'rec-5544-uuid',
        'file_name': 'DevOps_Engineer.pdf',
        'score': 90,
        'metadata': jsonEncode({
          'category': 'DevOps',
          'seniority': 'Mid-level',
          'strengths': ['Kubernetes', 'CI/CD pipeline'],
          'weaknesses': ['Monitoring tools'],
          'suggestions': ['Add Prometheus experience'],
        }),
        'created_at': '2026-10-12T08:30:00Z',
      };

      final parsed = ResumeItem.fromJson(cloudJson);

      expect(parsed.id, 'rec-5544-uuid');
      expect(parsed.name, 'DevOps_Engineer.pdf');
      expect(parsed.scoreValue, 90);
      expect(parsed.category, 'DevOps');
      expect(parsed.seniority, 'Mid-level');
      expect(parsed.strengths, ['Kubernetes', 'CI/CD pipeline']);
      expect(parsed.suggestions, ['Add Prometheus experience']);
    });

    test('copyWith properly updates ID after successful Supabase insert', () {
      final item = ResumeItem(
        name: 'test.pdf',
        date: 'Oct 12, ’26',
        score: '80%',
        scoreValue: 80,
      );

      expect(item.id, isNull);

      final updated = item.copyWith(id: 'new-supabase-id-777');
      expect(updated.id, 'new-supabase-id-777');
      expect(updated.name, 'test.pdf');
      expect(updated.scoreValue, 80);
    });
  });
}
