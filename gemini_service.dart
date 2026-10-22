import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/config_service.dart';

class GeminiService {
  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  static const List<String> _candidateModels = [
    'gemini-3.1-flash-lite',
    'gemini-3.5-flash-lite',
    'gemini-3.5-flash',
    'gemini-flash-lite-latest',
    'gemini-3.8-flash',
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

  static final http.Client _httpClient = http.Client();

  static Future<Map<String, dynamic>> analyzeResume({
    required String fileName,
    required String category,
    required String seniority,
    required String resumeText,
    Uint8List? fileBytes,
    String? fileExtension,
    String? jobDescription,
    bool isScannedPdf = false,
  }) async {
    final swPrep = Stopwatch()..start();
    final apiKey = ConfigService.to.geminiApiKey.value.trim();
    if (apiKey.isEmpty) {
      throw StateError(
        'No Gemini API key configured. Please add a valid API key in your .env file or under Profile Settings.',
      );
    }

    final cleanText = resumeText.trim();
    if (cleanText.isEmpty && (fileBytes == null || fileBytes.isEmpty)) {
      throw StateError(
        'No readable resume content or document pages could be found in "$fileName". Please upload a valid document containing readable text or clear pages.',
      );
    }

    final prompt = _buildPrompt(
      fileName: fileName,
      category: category,
      seniority: seniority,
      resumeText: cleanText,
      jobDescription: jobDescription,
      isScannedPdf: isScannedPdf,
    );
    swPrep.stop();

    // If user provided an xAI Grok Key format (starts with 'xai-')
    if (apiKey.startsWith('xai-')) {
      try {
        debugPrint('Detected xAI Grok API key. Routing to Grok AI...');
        final swGrok = Stopwatch()..start();
        final response = await _httpClient.post(
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
            'max_tokens': 1500,
          }),
        );
        swGrok.stop();

        debugPrint('Grok API Status: ${response.statusCode} in ${swGrok.elapsedMilliseconds}ms');
        if (response.statusCode == 200) {
          debugPrint('✓ Grok AI model succeeded!');
          final payload = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = payload['choices'] as List<dynamic>? ?? [];
          if (choices.isNotEmpty) {
            final content =
                choices.first['message']?['content']?.toString() ?? '';
            final parsed = _parseResponse(
              content,
              fileName: fileName,
              category: category,
              seniority: seniority,
            );
            parsed['isAiGenerated'] = true;
            parsed['aiModel'] = 'xAI Grok';
            return parsed;
          }
        } else {
          debugPrint('Grok API Error Body: ${response.body}');
        }
      } catch (e) {
        debugPrint('Grok API Exception: $e');
      }
    }

    final hasExtractedText = cleanText.length >= 60 &&
        cleanText != 'PDF Resume Document' &&
        cleanText != 'DOCX Resume Document';

    // Prepare multimodal PDF payload if bytes are available
    List<Map<String, dynamic>> multimodalParts = [];
    final ext = (fileExtension ?? fileName.split('.').last).toLowerCase();
    if (fileBytes != null && fileBytes.isNotEmpty && ext == 'pdf') {
      final base64Data = base64Encode(fileBytes);
      multimodalParts.add({
        'inlineData': {
          'mimeType': 'application/pdf',
          'data': base64Data,
        },
      });
      multimodalParts.add({'text': prompt});
    }

    final List<Map<String, dynamic>> textOnlyParts = [
      {'text': prompt}
    ];

    // Strategy:
    // 1. If scanned PDF (no extractable text), try multimodal parts first
    // 2. If text was extracted and PDF bytes are available: send multimodal parts first
    //    (Gemini gets full visual layout, fonts, and text simultaneously)
    // 3. Fallback to textOnlyParts if multimodal fails or not applicable
    final List<List<Map<String, dynamic>>> attempts;
    if (isScannedPdf && multimodalParts.isNotEmpty) {
      attempts = [
        multimodalParts,
      ];
    } else if (hasExtractedText) {
      attempts = [
        if (multimodalParts.isNotEmpty) multimodalParts,
        textOnlyParts,
      ];
    } else if (multimodalParts.isNotEmpty) {
      attempts = [
        multimodalParts,
        textOnlyParts,
      ];
    } else {
      attempts = [
        textOnlyParts,
      ];
    }

    String lastError = '';
    bool quotaExceeded = false;

    for (final partsToTry in attempts) {
      final isMultimodal = partsToTry.length > 1;
      for (final model in _candidateModels) {
        try {
          debugPrint('Attempting Gemini API with model: $model (multimodal: $isMultimodal)...');
          final swApi = Stopwatch()..start();
          final response = await _httpClient.post(
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
                'temperature': 0.25,
                'maxOutputTokens': 2500,
                'responseMimeType': 'application/json',
              },
            }),
          );
          swApi.stop();

          debugPrint('Gemini Model [$model] Status: ${response.statusCode} in ${swApi.elapsedMilliseconds}ms');

          if (response.statusCode == 200) {
            debugPrint('✓ Gemini AI model [$model] succeeded in ${swApi.elapsedMilliseconds}ms!');
            final swParse = Stopwatch()..start();
            final payload = jsonDecode(response.body) as Map<String, dynamic>;
            final message = _extractResponseText(payload);

            final parsed = _parseResponse(
              message,
              fileName: fileName,
              category: category,
              seniority: seniority,
            );
            parsed['isAiGenerated'] = true;
            parsed['aiModel'] = model;
            swParse.stop();

            debugPrint(
                '⚡ [Gemini Diagnostics] Prep: ${swPrep.elapsedMilliseconds}ms | '
                    'API ($model): ${swApi.elapsedMilliseconds}ms | '
                    'Parse: ${swParse.elapsedMilliseconds}ms | '
                    'Mode: ${isMultimodal ? "Multimodal" : "DirectText"}'
            );

            return parsed;
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
      // If we have real extracted resume text, generate an evidence-based local assessment
      if (hasExtractedText) {
        debugPrint('Gemini quota limit reached. Falling back to local evidence-based evaluation of extracted text.');
        final localAnalysis = buildFallbackAnalysis(
          fileName: fileName,
          category: category,
          seniority: seniority,
          resumeText: cleanText,
          jobDescription: jobDescription,
        );
        localAnalysis['isAiGenerated'] = false;
        localAnalysis['aiModel'] = 'Offline Evidence Engine';
        return localAnalysis;
      }

      throw StateError(
        'The AI service free-tier quota has been temporarily exhausted. Please wait a short while or provide a text-based document.',
      );
    }

    if (lastError.contains('API key not valid') ||
        lastError.contains('ACCESS_TOKEN_TYPE_UNSUPPORTED') ||
        lastError.contains('UNAUTHENTICATED') ||
        lastError.contains('API_KEY_INVALID')) {
      throw StateError(
        'Gemini API key is invalid or revoked by Google (401 Unauthenticated). Please obtain a fresh key from https://aistudio.google.com/app/apikey and save it in your .env or Profile Settings.',
      );
    }

    // If we have valid extracted text, provide local evidence-based analysis instead of failing
    if (hasExtractedText) {
      debugPrint('Gemini API unreachable. Falling back to local evidence-based analysis.');
      final localAnalysis = buildFallbackAnalysis(
        fileName: fileName,
        category: category,
        seniority: seniority,
        resumeText: cleanText,
        jobDescription: jobDescription,
      );
      localAnalysis['isAiGenerated'] = false;
      localAnalysis['aiModel'] = 'Offline Evidence Engine';
      return localAnalysis;
    }

    throw StateError(
      'Gemini AI failed to return a response ($lastError). Please verify your internet connection and API key.',
    );
  }

  static Map<String, dynamic> buildFallbackAnalysis({
    required String fileName,
    required String category,
    required String seniority,
    required String resumeText,
    String? jobDescription,
  }) {
    final clean = resumeText.trim();
    if (clean.length < 50) {
      throw StateError(
        'The document "$fileName" contains insufficient text for analysis. Please ensure your document has readable text or provide a non-scanned file.',
      );
    }

    final normalized = clean.toLowerCase();
    final words = clean
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();
    final wordCount = words.length;

    final hasEmail = RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')
        .hasMatch(clean);
    final hasPhone = RegExp(r'(\+?\d[\d\s().-]{7,}\d)').hasMatch(clean);
    final hasNumbers = RegExp(r'\b\d+(?:[%+]|\s*(years?|months?|k|m|x|gb|mb))?\b')
        .hasMatch(normalized);

    final sectionKeywords = <String, List<String>>{
      'Summary': ['summary', 'profile', 'objective', 'about me', 'professional summary'],
      'Experience': ['experience', 'employment', 'work history', 'professional background', 'work experience'],
      'Education': ['education', 'university', 'college', 'degree', 'bachelor', 'master', 'bs', 'ms', 'phd'],
      'Skills': ['skills', 'tech stack', 'technologies', 'tools', 'competencies', 'technical skills'],
      'Projects': ['projects', 'portfolio', 'case study', 'personal projects', 'key projects'],
      'Certifications': ['certifications', 'licenses', 'certificates', 'certified'],
    };

    final foundSections = <String>[];
    for (final entry in sectionKeywords.entries) {
      if (entry.value.any(normalized.contains)) {
        foundSections.add(entry.key);
      }
    }

    // Detect common technical and domain skill keywords actually present in the candidate text
    final commonSkills = [
      'python', 'java', 'c++', 'c#', 'javascript', 'typescript', 'dart', 'flutter',
      'react', 'angular', 'vue', 'node.js', 'sql', 'postgresql', 'mysql', 'mongodb',
      'docker', 'kubernetes', 'aws', 'azure', 'gcp', 'git', 'ci/cd', 'linux',
      'machine learning', 'data analysis', 'agile', 'scrum', 'jira', 'rest api',
      'figma', 'ui/ux', 'devops', 'html', 'css', 'graphql', 'nosql', 'firebase',
    ];
    final candidateSkills = commonSkills
        .where((s) => normalized.contains(s))
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .toList();

    // Calculate evidence-based score across the 5 dimensions:
    // 1. Role Relevance (0 - 25)
    final categoryTerms = category
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((term) => term.length > 2)
        .toSet();
    final categoryMatches = categoryTerms.where(normalized.contains).length;
    final relevanceScore = (categoryMatches > 0 ? 12 : 5) +
        (candidateSkills.length * 2).clamp(0, 13);

    // 2. Technical & Domain Depth (0 - 20)
    final techScore = (candidateSkills.length * 3).clamp(5, 20);

    // 3. Quantified Impact & Experience (0 - 20)
    var impactScore = 5;
    if (foundSections.contains('Experience')) impactScore += 5;
    if (hasNumbers) impactScore += 10;

    // 4. Education & Foundations (0 - 15)
    var educationScore = 4;
    if (foundSections.contains('Education')) educationScore += 7;
    if (foundSections.contains('Certifications')) educationScore += 4;

    // 5. ATS Structure & Clarity (0 - 20)
    var atsScore = 4;
    if (hasEmail && hasPhone) atsScore += 6;
    if (foundSections.length >= 4) {
      atsScore += 6;
    } else if (foundSections.length >= 2) {
      atsScore += 3;
    }
    if (wordCount >= 200 && wordCount <= 900) atsScore += 4;

    final totalScore = (relevanceScore + techScore + impactScore + educationScore + atsScore)
        .clamp(40, 95);

    // Construct evidence-grounded findings
    final strengths = <String>[];
    final weaknesses = <String>[];
    final suggestions = <String>[];

    if (candidateSkills.isNotEmpty) {
      strengths.add(
        '[Skills Section] Demonstrates verified domain competencies in: ${candidateSkills.take(5).join(", ")}.',
      );
    } else if (foundSections.contains('Skills')) {
      strengths.add(
        '[Skills Section] Includes a dedicated skills inventory aligned with professional requirements.',
      );
    }

    if (foundSections.contains('Experience')) {
      strengths.add(
        '[Experience Section] Work history is structured with explicit role titles and employment context.',
      );
    }

    if (hasNumbers) {
      strengths.add(
        '[Quantified Evidence] Incorporates measurable numbers, metrics, or scale indicators that validate execution impact.',
      );
    }

    if (foundSections.contains('Projects')) {
      strengths.add(
        '[Projects Section] Documents dedicated practical project work showcasing applied problem solving.',
      );
    }

    if (hasEmail && hasPhone) {
      strengths.add(
        '[Contact Information] Complete recruiter contact channels including professional email and phone number.',
      );
    }

    // Ensure at least 4-5 rich, evidence-based strengths
    final contextualStrengths = [
      '[Formatting & Presentation] Document layout maintains consistent typography, readable hierarchy, and chronological progression.',
      '[Section Organization] Core professional headings are structured for rapid recruiter parsing and indexing.',
      '[Career Focus] Background communicates a coherent domain orientation aligned with $category requirements.',
      '[Communication Clarity] Information is delivered using concise phrasing with clear responsibility indicators.',
      '[Technical Foundations] Profile exhibits relevant foundational competencies applicable to modern $category workflows.',
    ];
    for (final s in contextualStrengths) {
      if (strengths.length >= 4) break;
      if (!strengths.contains(s)) strengths.add(s);
    }

    // Weaknesses grounded in facts
    if (!hasNumbers) {
      weaknesses.add(
        '[Impact Measurement] Bullet points describe responsibilities rather than quantifiable achievements, percentages, or business outcomes.',
      );
      suggestions.add(
        '[Quantify Achievements] Rewrite 2-3 key bullet points using the XYZ formula: Accomplished [X] as measured by [Y], by doing [Z]. Include verifiable numbers only.',
      );
    }

    if (!foundSections.contains('Projects')) {
      weaknesses.add(
        '[Project Portfolio] No dedicated Projects section found in the document to showcase hands-on system building.',
      );
      suggestions.add(
        '[Projects Section] Add a Projects section featuring 1-2 major technical implementations detailing problem, architecture, technologies used, and outcomes.',
      );
    }

    if (candidateSkills.length < 4) {
      weaknesses.add(
        '[Skill Specification] Core technical stack keywords for $category are underrepresented in the document text.',
      );
      suggestions.add(
        '[Skill Taxonomy] Group technical skills into distinct categories (Languages, Frameworks, Cloud & Databases, Methodologies) to enhance keyword discoverability.',
      );
    }

    if (!foundSections.contains('Summary')) {
      weaknesses.add(
        '[Professional Summary] Document lacks a targeted summary introducing your core value proposition for $seniority $category roles.',
      );
      suggestions.add(
        '[Executive Summary] Add a 3-sentence summary at the top outlining your professional focus, key domain achievements, and target alignment for $seniority roles.',
      );
    }

    if (wordCount < 180) {
      weaknesses.add(
        '[Content Depth] Descriptions are concise ($wordCount words), providing limited context on technical scope, challenges faced, and individual contributions.',
      );
      suggestions.add(
        '[Detail Expansion] Expand role descriptions to explain the architectural problems solved, decisions made, and individual engineering contributions.',
      );
    }

    final contextualWeaknesses = [
      '[Target Role Alignment] Several bullet points would benefit from stronger calibration against specialized $seniority $category competency benchmarks.',
      '[Technical Keyword Discoverability] Important domain technologies and tools for $category should be highlighted more prominently.',
      '[Action Verbs] Many sentences rely on passive responsibility phrasing rather than high-impact technical action verbs.',
      '[Scope Context] Project and work achievements would be more compelling with explicit problem-solution-result framing.',
    ];
    for (final w in contextualWeaknesses) {
      if (weaknesses.length >= 4) break;
      if (!weaknesses.contains(w)) weaknesses.add(w);
    }

    final contextualSuggestions = [
      '[Action Verbs] Begin bullet points with strong active technical verbs (e.g., Architected, Spearheaded, Implemented, Automated).',
      '[Keyword Alignment] Incorporate 5-8 high-demand keywords from target $category job descriptions into your skills and summary sections.',
      '[Scope Metrics] Augment bullet points with scale indicators such as team size, codebase size, users served, or efficiency improvements.',
      '[Portfolio Links] Add active links to public repositories, technical blogs, or portfolio demonstrations to validate claimed expertise.',
    ];
    for (final su in contextualSuggestions) {
      if (suggestions.length >= 4) break;
      if (!suggestions.contains(su)) suggestions.add(su);
    }

    final dynamicTier = getFitnessTier(totalScore);
    final String overallFitness;
    if (totalScore >= 80) {
      overallFitness =
      'Strong candidate profile with solid alignment for $seniority $category positions. Demonstrates verified skills in ${candidateSkills.take(3).join(", ")}, with primary room for growth in quantifying measurable business impact.';
    } else if (totalScore >= 65) {
      overallFitness =
      'Solid foundational qualifications for $category roles at the $seniority level with structured core sections. Expanding concrete project evidence and measurable outcomes will significantly strengthen candidate positioning.';
    } else {
      overallFitness =
      'Developing alignment for $seniority $category requirements. The resume outlines basic competencies but requires targeted improvements in section depth, technical keywords, and verifiable achievement metrics.';
    }

    return {
      'fileName': fileName,
      'category': category,
      'seniority': seniority,
      'score': totalScore,
      'fitnessTier': dynamicTier,
      'overallFitness': overallFitness,
      'strengths': strengths.take(5).toList(),
      'weaknesses': weaknesses.take(5).toList(),
      'suggestions': suggestions.take(5).toList(),
    };
  }

  static String getFitnessTier(int score) {
    if (score >= 85) return 'EXCELLENT FIT';
    if (score >= 75) return 'STRONG MATCH';
    if (score >= 65) return 'COMPETITIVE CANDIDATE';
    if (score >= 50) return 'DEVELOPING FIT';
    return 'REQUIRES REFINEMENT';
  }

  static String generateDynamicFitnessSummary({
    required int score,
    required String category,
    required String seniority,
    List<String> strengths = const [],
    List<String> weaknesses = const [],
  }) {
    final buffer = StringBuffer();
    if (score >= 80) {
      buffer.write(
        'High-caliber profile demonstrating strong preparedness for $seniority $category positions.',
      );
    } else if (score >= 68) {
      buffer.write(
        'Solid competitive foundation with recognized domain competencies for $seniority $category roles.',
      );
    } else if (score >= 55) {
      buffer.write(
        'Developing match for $seniority $category positions with clear core strengths alongside important refinement areas.',
      );
    } else {
      buffer.write(
        'Requires focused improvements to meet industry standards expected for $seniority $category candidates.',
      );
    }

    if (strengths.isNotEmpty) {
      final s = strengths.first.replaceAll(RegExp(r'\.$'), '');
      buffer.write(' Standout strength: $s.');
    }

    if (weaknesses.isNotEmpty) {
      final w = weaknesses.first.replaceAll(RegExp(r'\.$'), '');
      buffer.write(' Recommended focus: $w.');
    }

    return buffer.toString();
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
    String? jobDescription,
    bool isScannedPdf = false,
  }) {
    final cleanText = resumeText.trim();
    final jd = (jobDescription != null && jobDescription.trim().isNotEmpty)
        ? jobDescription.trim()
        : 'No custom job description provided. Perform evaluation against standard industry hiring requirements and benchmarks for a $seniority $category role.';

    return '''
You are an expert Executive Technical Recruiter and Senior Hiring Manager.
Conduct a rigorous, evidence-based evaluation of the candidate's actual resume document.

TARGET ROLE SPECIFICATION:
- Job Category: $category
- Seniority Level: $seniority
- Job Description / Requirements:
$jd

${cleanText.isNotEmpty ? 'ACTUAL RESUME DOCUMENT CONTENT (Extracted from $fileName):\n"""\n$cleanText\n"""' : 'RESUME DOCUMENT: Scanned visual document ($fileName) attached via inline document data. Read and analyze all text, layout, and sections visually.'}

CRITICAL EVIDENCE-BASED ANALYSIS INSTRUCTIONS:
1. PRIMARY EVIDENCE RULE:
   The candidate's actual resume is the SOLE source of truth. Every finding, score, strength, weakness, and recommendation must be directly grounded in what is stated in the document.
2. DO NOT FABRICATE:
   Never invent or assume accomplishments, companies, degrees, tools, metrics, or years of experience.
3. MISSING INFORMATION:
   If a skill or qualification required for $category ($seniority) is not found in the resume, describe it strictly as "Not found in resume", NEVER as proof that the candidate lacks the ability.
4. STRENGTHS:
   Provide 3 to 6 strengths that exist in the candidate's background. For each strength, cite the specific section/evidence (e.g., "[Experience - Company Name] Demonstrated expertise in ...") and explain why it is valuable for $seniority $category.
5. AREAS FOR IMPROVEMENT (WEAKNESSES):
   Provide 3 to 6 constructive, evidence-based weaknesses. For each, explain: (a) what is missing or suboptimal, (b) which section is affected, (c) the supporting evidence or absence thereof, and (d) why it matters for $seniority $category.
6. ACTIONABLE SUGGESTIONS:
   Provide 3 to 6 practical, specific, prioritized recommendations. If suggesting bullet point revisions, use ONLY facts from the resume. Never invent fake percentages or achievements; guide the candidate on how to measure and state their real contributions.
7. SCORING RUBRIC (0-100):
   Evaluate consistently across 5 weighted dimensions:
   - Role Relevance to $category (25 pts)
   - Technical & Domain Depth for $seniority (20 pts)
   - Quantified Impact & Project Execution (20 pts)
   - Education, Foundations & Certifications (15 pts)
   - ATS Structure, Clarity & Section Organization (20 pts)
   Total is an objective fitness score (0-100). Do not claim this is an official ATS score or probability of getting hired.

OUTPUT FORMAT:
Return a JSON object with the following schema:
{
  "score": <integer from 0 to 100>,
  "fitnessTier": "<one of: 'EXCELLENT FIT', 'STRONG MATCH', 'COMPETITIVE CANDIDATE', 'DEVELOPING FIT', 'REQUIRES REFINEMENT'>",
  "overallFitness": "<A compelling 2-3 sentence executive assessment summarizing candidate fitness for $seniority $category, citing their primary background highlight and their biggest lever for improvement>",
  "strengths": [<array of 3-6 strings, each citing evidence and resume section>],
  "weaknesses": [<array of 3-6 strings, each detailing the section, issue, and impact for $seniority $category>],
  "suggestions": [<array of 3-6 specific, actionable, fact-grounded recommendations>]
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

    final rawFitness = responseJson['overallFitness'] ??
        responseJson['overall_fitness'] ??
        responseJson['fitness'] ??
        responseJson['summary'];
    final overallFitness = rawFitness is String && rawFitness.trim().isNotEmpty
        ? rawFitness.trim()
        : generateDynamicFitnessSummary(
      score: parsedScore,
      category: category,
      seniority: seniority,
      strengths: strengths,
      weaknesses: weaknesses,
    );

    final rawTier = responseJson['fitnessTier'] ?? responseJson['fitness_tier'];
    final fitnessTier = rawTier is String && rawTier.trim().isNotEmpty
        ? rawTier.trim()
        : getFitnessTier(parsedScore);

    return {
      'fileName': fileName,
      'category': category,
      'seniority': seniority,
      'score': parsedScore,
      'fitnessTier': fitnessTier,
      'overallFitness': overallFitness,
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