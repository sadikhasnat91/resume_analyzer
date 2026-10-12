import 'dart:convert';

class ResumeItem {
  final String? id;
  final String name;
  final String category;
  final String seniority;
  final String date;
  final String score;
  final int scoreValue;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> suggestions;

  ResumeItem({
    this.id,
    required this.name,
    this.category = 'Software Engineering',
    this.seniority = 'Senior',
    required this.date,
    required this.score,
    this.scoreValue = 78,
    this.strengths = const [],
    this.weaknesses = const [],
    this.suggestions = const [],
  });

  ResumeItem copyWith({
    String? id,
    String? name,
    String? category,
    String? seniority,
    String? date,
    String? score,
    int? scoreValue,
    List<String>? strengths,
    List<String>? weaknesses,
    List<String>? suggestions,
  }) {
    return ResumeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      seniority: seniority ?? this.seniority,
      date: date ?? this.date,
      score: score ?? this.score,
      scoreValue: scoreValue ?? this.scoreValue,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fileName': name,
      'file_name': name,
      'category': category,
      'seniority': seniority,
      'date': date,
      'score': scoreValue,
      'score_text': score,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'suggestions': suggestions,
      'metadata': {
        'category': category,
        'seniority': seniority,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'suggestions': suggestions,
      },
    };
  }

  Map<String, dynamic> toSupabaseMap(String userId) {
    return {
      'user_id': userId,
      'file_name': name,
      'score': scoreValue,
      'metadata': {
        'category': category,
        'seniority': seniority,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'suggestions': suggestions,
        'feedback': suggestions.isNotEmpty ? suggestions.join('\n') : '',
      },
    };
  }

  factory ResumeItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> meta = {};
    if (json['metadata'] is Map) {
      meta = Map<String, dynamic>.from(json['metadata'] as Map);
    } else if (json['metadata'] is String) {
      try {
        final decoded = jsonDecode(json['metadata'] as String);
        if (decoded is Map) {
          meta = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    final rawScore = json['score'] ?? meta['score'];
    int parsedScore = 78;
    if (rawScore is int) {
      parsedScore = rawScore;
    } else if (rawScore is num) {
      parsedScore = rawScore.toInt();
    } else if (rawScore != null) {
      parsedScore =
          int.tryParse(rawScore.toString().replaceAll(RegExp(r'[^\d]'), '')) ??
          78;
    }

    final rawScoreText =
        json['score_text'] ?? meta['score_text'] ?? json['score'];
    final scoreStr = rawScoreText != null
        ? (rawScoreText.toString().contains('%')
            ? rawScoreText.toString()
            : '$rawScoreText%')
        : '$parsedScore%';

    final nameStr = (json['fileName'] ??
            json['file_name'] ??
            json['name'] ??
            meta['fileName'] ??
            meta['file_name'] ??
            meta['name'])
        ?.toString() ??
        'resume.pdf';

    final categoryStr =
        (json['category'] ?? meta['category'])?.toString() ??
        'Software Engineering';
    final seniorityStr =
        (json['seniority'] ?? meta['seniority'])?.toString() ?? 'Senior';
    final dateStr = (json['date'] ?? meta['date'])?.toString() ?? 'Today';

    List<String> parseList(dynamic raw) {
      if (raw == null) return <String>[];
      if (raw is List) {
        return raw
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            return decoded
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          }
        } catch (_) {}
        if (raw.trim().isNotEmpty) {
          if (raw.contains('\n')) {
            return raw
                .split('\n')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }
          return [raw.trim()];
        }
      }
      return <String>[];
    }

    final strengthsList =
        parseList(json['strengths'] ?? meta['strengths']);
    final weaknessesList =
        parseList(json['weaknesses'] ?? meta['weaknesses']);
    final suggestionsList =
        parseList(json['suggestions'] ?? meta['suggestions'] ?? json['feedback']);

    return ResumeItem(
      id: json['id']?.toString(),
      name: nameStr,
      category: categoryStr,
      seniority: seniorityStr,
      date: dateStr,
      score: scoreStr,
      scoreValue: parsedScore,
      strengths: strengthsList,
      weaknesses: weaknessesList,
      suggestions: suggestionsList,
    );
  }
}
