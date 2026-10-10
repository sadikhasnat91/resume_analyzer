import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/config_service.dart';

class GeminiService {
	static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

	static const List<String> _candidateModels = [
		'gemini-3.5-flash',
		'gemini-3.5-flash-lite',
		'gemini-3.8-flash',
		'gemini-3.7-flash',
		'gemini-3.6-flash',
		'gemini-flash-latest',
	];

	static bool isQuotaExceededError(Object error) {
		final message = error.toString().toLowerCase();
		return message.contains('429') ||
				message.contains('resource_exhausted') ||
				message.contains('quota exceeded') ||
				message.contains('quota has been exceeded') ||
				message.contains('free-tier quota');
	}

	static String friendlyErrorMessage(Object error) {
		if (isQuotaExceededError(error)) {
			return 'The AI free-tier quota has been used up for now. Please wait a little while before trying again.';
		}

		if (error is StateError) {
			return error.message;
		}

		return 'We could not analyze your resume right now. Please try again later.';
	}

	static Uri buildRequestUri(String model, [String? apiKey]) {
		final query = (apiKey != null && apiKey.isNotEmpty) ? '?key=$apiKey' : '';
		return Uri.parse('$_baseUrl/models/$model:generateContent$query');
	}

	static Map<String, String> buildHeaders(String apiKey) {
		final headers = {'Content-Type': 'application/json'};
		if (apiKey.isNotEmpty) {
			headers['x-goog-api-key'] = apiKey;
		}
		return headers;
	}

	static Future<Map<String, dynamic>> analyzeResume({
		required String fileName,
		required String category,
		required String seniority,
		required String resumeText,
		Uint8List? fileBytes,
		String? fileExtension,
	}) async {
		final apiKey = ConfigService.to.geminiApiKey.value.trim();
		if (apiKey.isEmpty) {
			debugPrint('No Gemini API key configured. Using fallback analysis.');
			return buildFallbackAnalysis(
				fileName: fileName,
				category: category,
				seniority: seniority,
				resumeText: resumeText,
			);
		}

		final prompt = _buildPrompt(
			fileName: fileName,
			category: category,
			seniority: seniority,
			resumeText: resumeText,
		);

		// If user provided an xAI Grok Key format (starts with 'xai-')
		if (apiKey.startsWith('xai-')) {
			try {
				debugPrint('Detected xAI Grok API key. Routing to Grok AI...');
				final response = await http.post(
					Uri.parse('https://api.x.ai/v1/chat/completions'),
					headers: {
						'Content-Type': 'application/json',
						'Authorization': 'Bearer $apiKey',
					},
					body: jsonEncode({
						'model': 'grok-2-latest',
						'messages': [
							{'role': 'user', 'content': prompt},
						],
						'temperature': 0.3,
						'max_tokens': 2000,
					}),
				);

				debugPrint('Grok API Status: ${response.statusCode}');
				if (response.statusCode == 200) {
					debugPrint('✓ Grok AI model succeeded!');
					final payload = jsonDecode(response.body) as Map<String, dynamic>;
					final choices = payload['choices'] as List<dynamic>? ?? [];
					if (choices.isNotEmpty) {
						final content =
								choices.first['message']?['content']?.toString() ?? '';
						return _parseResponse(
							content,
							fileName: fileName,
							category: category,
							seniority: seniority,
						);
					}
				} else {
					debugPrint('Grok API Error Body: ${response.body}');
				}
			} catch (e) {
				debugPrint('Grok API Exception: $e');
			}
		}

		// Multimodal parts if PDF bytes are available
		List<Map<String, dynamic>> multimodalParts = [];
		final ext = (fileExtension ?? fileName.split('.').last).toLowerCase();
		if (fileBytes != null && fileBytes.isNotEmpty && ext == 'pdf') {
			final base64Data = base64Encode(fileBytes);
			multimodalParts.add({
				'inline_data': {
					'mime_type': 'application/pdf',
					'data': base64Data,
				},
			});
		}
		multimodalParts.add({'text': prompt});

		final List<Map<String, dynamic>> textOnlyParts = [
			{'text': prompt}
		];

		// Try multimodal first (if PDF attached); if rejected (e.g. invalid PDF/size), fall back to text-only
		final attempts = [
			if (multimodalParts.length > 1) multimodalParts,
			textOnlyParts,
		];

		String lastError = '';
		bool quotaExceeded = false;

		for (final partsToTry in attempts) {
			final isMultimodal = partsToTry.length > 1;
			for (final model in _candidateModels) {
				try {
					debugPrint('Attempting Gemini API with model: $model (multimodal: $isMultimodal)...');
					final response = await http.post(
						buildRequestUri(model, apiKey),
						headers: buildHeaders(apiKey),
						body: jsonEncode({
							'contents': [
								{
									'role': 'user',
									'parts': partsToTry,
								},
							],
							'generationConfig': {
								'temperature': 0.3,
								'maxOutputTokens': 2000,
								'responseMimeType': 'application/json',
							},
						}),
					);

					debugPrint('Gemini Model [$model] Status: ${response.statusCode}');

					if (response.statusCode == 200) {
						debugPrint('✓ Gemini AI model [$model] succeeded!');
						final payload = jsonDecode(response.body) as Map<String, dynamic>;
						final message = _extractResponseText(payload);

						return _parseResponse(
							message,
							fileName: fileName,
							category: category,
							seniority: seniority,
						);
					} else {
						lastError = response.body;
						debugPrint('Gemini Model [$model] Error Body: ${response.body}');
						if (isQuotaExceededError(response.body)) {
							quotaExceeded = true;
						}
					}
				} catch (e) {
					lastError = e.toString();
					debugPrint('Gemini Model [$model] Exception: $e');
					if (isQuotaExceededError(e)) {
						quotaExceeded = true;
					}
				}
			}
		}

		if (quotaExceeded) {
			throw StateError(
				'The AI free-tier quota has been used up for now. Please wait a little while before trying again.',
			);
		}

		debugPrint('All Gemini AI model attempts failed. Last error: $lastError. Using fallback analyzer.');
		return buildFallbackAnalysis(
			fileName: fileName,
			category: category,
			seniority: seniority,
			resumeText: resumeText,
		);
	}

	static Map<String, dynamic> buildFallbackAnalysis({
		required String fileName,
		required String category,
		required String seniority,
		required String resumeText,
	}) {
		final normalized = resumeText.toLowerCase();
		final wordCount = resumeText
				.split(RegExp(r'\s+'))
				.where((word) => word.trim().isNotEmpty)
				.length;

		final hasEmail = RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')
				.hasMatch(resumeText);
		final hasPhone = RegExp(r'(\+?\d[\d\s().-]{7,}\d)').hasMatch(resumeText);
		final hasNumbers = RegExp(r'\b\d+(?:[%+]|\s*(years?|months?|k|m))?\b')
				.hasMatch(normalized);

		final sectionKeywords = <String, List<String>>{
			'summary': ['summary', 'profile', 'objective', 'about'],
			'experience': ['experience', 'employment', 'work history'],
			'education': ['education', 'university', 'college', 'degree'],
			'skills': ['skills', 'tech stack', 'technologies', 'tools'],
			'projects': ['projects', 'portfolio', 'case study'],
		};

		final sectionHits = <String>[];
		for (final entry in sectionKeywords.entries) {
			if (entry.value.any(normalized.contains)) {
				sectionHits.add(entry.key);
			}
		}

		final categoryTerms = category
				.toLowerCase()
				.split(RegExp(r'[^a-z0-9]+'))
				.where((term) => term.length > 2)
				.toSet();
		final categoryMatches = categoryTerms.where(normalized.contains).length;

		var score = 40;
		if (hasEmail) score += 8;
		if (hasPhone) score += 7;
		if (hasNumbers) score += 10;
		score += sectionHits.length * 6;
		score += (categoryMatches * 5).clamp(0, 15);

		if (wordCount >= 250 && wordCount <= 900) {
			score += 12;
		} else if (wordCount >= 150) {
			score += 6;
		}

		final boundedScore = score.clamp(45, 92);

		final strengths = <String>[];
		final weaknesses = <String>[];
		final suggestions = <String>[];

		if (hasEmail && hasPhone) {
			strengths.add('Includes direct contact details for recruiter follow-up.');
		} else {
			weaknesses.add('Contact information appears incomplete or hard to detect.');
			suggestions.add('Place phone number and professional email clearly at the top.');
		}

		if (sectionHits.contains('experience')) {
			strengths.add('Work experience section is present and structured.');
		} else {
			weaknesses.add('Experience history is not clearly labeled.');
			suggestions.add('Add a dedicated Experience section with role, company, and dates.');
		}

		if (sectionHits.contains('skills')) {
			strengths.add('Core technical or professional skills are explicitly listed.');
		} else {
			weaknesses.add('Skills are not grouped into a dedicated section.');
			suggestions.add('Create a Skills section tailored to $category requirements.');
		}

		if (hasNumbers) {
			strengths.add('Contains measurable metrics that support project achievements.');
		} else {
			weaknesses.add('Impact is difficult to measure due to lack of quantified metrics.');
			suggestions.add('Add numbers such as percentages, scope, performance or sales gains.');
		}

		if (sectionHits.contains('projects')) {
			strengths.add('Projects or portfolio highlights help demonstrate practical experience.');
		} else {
			suggestions.add('Include 1-2 relevant projects matching $category at $seniority level.');
		}

		if (wordCount < 180) {
			weaknesses.add('Resume content is quite brief to show deep experience.');
			suggestions.add('Expand bullet points with context, technical tools, and results.');
		} else if (wordCount > 1000) {
			weaknesses.add('Resume is very lengthy for quick recruiter screening.');
			suggestions.add('Condense older or lower impact bullet points for better scannability.');
		} else {
			strengths.add('Overall resume length is appropriate for a quick review.');
		}

		while (strengths.length < 3) {
			strengths.add('Resume structure supports quick first-pass evaluation.');
		}
		while (weaknesses.length < 3) {
			weaknesses.add('Role alignment for $category could be highlighted more prominently.');
		}
		while (suggestions.length < 3) {
			suggestions.add('Tailor bullet keywords to match target job descriptions.');
		}

		return {
			'fileName': fileName,
			'category': category,
			'seniority': seniority,
			'score': boundedScore,
			'strengths': strengths.take(5).toList(),
			'weaknesses': weaknesses.take(5).toList(),
			'suggestions': suggestions.take(5).toList(),
		};
	}

	static String _extractResponseText(Map<String, dynamic> payload) {
		final candidates = payload['candidates'] as List<dynamic>? ?? const [];
		if (candidates.isEmpty) {
			throw FormatException('Gemini response does not contain any candidates.');
		}

		final parts =
				candidates.first['content']?['parts'] as List<dynamic>? ?? const [];
		if (parts.isEmpty) {
			throw FormatException('Gemini response does not contain content parts.');
		}

		for (final part in parts) {
			if (part is Map<String, dynamic> && part['text'] is String) {
				final text = (part['text'] as String).trim();
				if (text.isNotEmpty) {
					return text;
				}
			}
		}

		throw FormatException('Gemini response did not contain text content.');
	}

	static String _buildPrompt({
		required String fileName,
		required String category,
		required String seniority,
		required String resumeText,
	}) {
		final hasText = resumeText.trim().isNotEmpty &&
				resumeText != 'PDF Resume Document' &&
				resumeText != 'DOCX Resume Document';

		return '''
You are an expert HR and Technical Hiring Manager.
Evaluate the candidate's resume for a $category position at the $seniority level.
Resume filename: $fileName

${hasText ? 'Extracted resume content:\n$resumeText\n' : 'Please analyze the attached document thoroughly.'}

Evaluate the resume objectively according to industry standards for $seniority $category.
Provide tailored, high-value, actionable feedback.

Return a JSON object with the following schema:
{
  "score": <integer from 0 to 100 based on fit, experience, skills, and presentation>,
  "strengths": [<array of 3-5 concise, specific bullet points highlighting real strengths in the resume>],
  "weaknesses": [<array of 3-5 concise, constructive bullet points highlighting real areas of improvement>],
  "suggestions": [<array of 3-5 specific, actionable steps to boost this resume for a $seniority $category role>]
}

Return ONLY valid JSON.
''';
	}

	static Map<String, dynamic> _parseResponse(
		String message, {
		required String fileName,
		required String category,
		required String seniority,
	}) {
		final trimmed = message.trim();
		final jsonStart = trimmed.indexOf('{');
		final jsonEnd = trimmed.lastIndexOf('}');

		if (jsonStart < 0 || jsonEnd < jsonStart) {
			throw FormatException('AI response is not valid JSON.');
		}

		final jsonString = trimmed.substring(jsonStart, jsonEnd + 1);
		final responseJson = jsonDecode(jsonString) as Map<String, dynamic>;

		final rawScore = responseJson['score'];
		final int parsedScore = rawScore is num
				? rawScore.round().clamp(0, 100)
				: (int.tryParse(rawScore?.toString() ?? '') ?? 70).clamp(0, 100);

		List<String> parseList(dynamic list) {
			if (list is! List) return [];
			return list
					.map((item) => item?.toString().trim() ?? '')
					.where((item) => item.isNotEmpty)
					.toList();
		}

		final strengths = parseList(responseJson['strengths']);
		final weaknesses = parseList(responseJson['weaknesses']);
		final suggestions = parseList(responseJson['suggestions']);

		return {
			'fileName': fileName,
			'category': category,
			'seniority': seniority,
			'score': parsedScore,
			'strengths': strengths.isNotEmpty
					? strengths
					: ['Clear overview of background and relevant competencies.'],
			'weaknesses': weaknesses.isNotEmpty
					? weaknesses
					: ['Could include more measurable results and quantified impact.'],
			'suggestions': suggestions.isNotEmpty
					? suggestions
					: ['Align technical keywords and metrics with target role specifications.'],
		};
	}
}
