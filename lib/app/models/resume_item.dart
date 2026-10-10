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
    };
  }

  factory ResumeItem.fromJson(Map<String, dynamic> json) {
    final rawScore = json['score'];
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

    final rawScoreText = json['score_text'] ?? json['score'];
    final scoreStr = rawScoreText?.toString() ?? '$parsedScore%';

    final nameStr =
        (json['fileName'] ?? json['file_name'] ?? json['name'])?.toString() ??
        'resume.pdf';
    final categoryStr = json['category']?.toString() ?? 'Software Engineering';
    final seniorityStr = json['seniority']?.toString() ?? 'Senior';
    final dateStr = json['date']?.toString() ?? 'Today';

    final strengthsList =
        (json['strengths'] as List?)
            ?.map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        <String>[];

    final weaknessesList =
        (json['weaknesses'] as List?)
            ?.map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        <String>[];

    final suggestionsList =
        (json['suggestions'] as List?)
            ?.map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        <String>[];

    return ResumeItem(
      id: json['id']?.toString(),
      name: nameStr,
      category: categoryStr,
      seniority: seniorityStr,
      date: dateStr,
      score: scoreStr.contains('%') ? scoreStr : '$scoreStr%',
      scoreValue: parsedScore,
      strengths: strengthsList,
      weaknesses: weaknessesList,
      suggestions: suggestionsList,
    );
  }
}
