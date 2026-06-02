import 'dart:convert';
import 'dart:io';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Remote data source for AI operations using the Gemini API.
///
/// Sends text generation requests to
/// `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent`
/// and returns the AI-generated text responses.
///
/// Uses [HttpClient] from dart:io instead of the http package.
class AiRemoteDatasource {
  AiRemoteDatasource({
    HttpClient? client,
  }) : _client = client ?? HttpClient();

  final HttpClient _client;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  /// Sends a prompt to the Gemini API and returns the generated text.
  ///
  /// [prompt] – the full prompt to send.
  /// [maxTokens] – optional maximum output tokens.
  ///
  /// Throws [AIException] on any failure.
  Future<String> generateContent({
    required String prompt,
    int? maxTokens,
  }) async {
    try {
      final apiKey = AppConstants.geminiApiKey;

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          if (maxTokens != null) 'maxOutputTokens': maxTokens,
          'temperature': 0.4,
          'topP': 0.95,
          'topK': 40,
        },
      });

      final uri = Uri.parse('$_baseUrl?key=$apiKey');
      final request = await _client.postUrl(uri);

      request.headers.set('Content-Type', 'application/json');
      request.write(body);

      final response = await request.close().timeout(
        Duration(seconds: AppConstants.aiRequestTimeoutSeconds),
      );

      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 429) {
        throw AIException.rateLimited();
      }

      if (response.statusCode == 408) {
        throw AIException.timeout();
      }

      if (response.statusCode != 200) {
        throw AIException.requestFailed();
      }

      final json = jsonDecode(responseBody) as Map<String, dynamic>;

      // Parse Gemini response structure.
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw AIException.invalidResponse();
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      if (content == null) {
        throw AIException.invalidResponse();
      }

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw AIException.invalidResponse();
      }

      final text = parts[0]['text'] as String?;
      if (text == null || text.isEmpty) {
        throw AIException.invalidResponse();
      }

      return text;
    } on AIException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw AIException.timeout();
      }
      throw AIException.requestFailed();
    }
  }

  /// Generates a summary of the given [text].
  Future<String> summarize({
    required String text,
    int maxWords = AppConstants.aiSummaryMaxWordsDefault,
  }) async {
    final prompt = '''Summarize the following document in approximately $maxWords words. '
'Provide a clear, concise summary that captures the key points and main ideas.

Document:
$text

Summary:''';

    return generateContent(prompt: prompt, maxTokens: maxWords * 2);
  }

  /// Categorizes the given document text.
  Future<String> categorize({required String text}) async {
    final prompt = '''Analyze the following document and suggest categories for it. '
'Return a JSON object with:
- "primary_category": the main category
- "subcategories": a list of 2-4 subcategories
- "tags": a list of 5-8 relevant tags
- "confidence": a confidence score between 0.0 and 1.0

Categories should be from common document types like: Invoice, Receipt, Contract, '
'Report, Letter, Resume, Form, Certificate, Manual, Notes, Other.

Document:
$text

JSON Response:''';

    return generateContent(prompt: prompt, maxTokens: 256);
  }

  /// Generates smart rename suggestions.
  Future<String> smartRename({
    required String text,
    required String currentName,
  }) async {
    final prompt = '''Based on the following document content, suggest a better filename. '
'The current filename is "$currentName".

Rules:
- Use a descriptive, human-readable name
- Use underscores instead of spaces
- Include relevant date if found in the document
- Keep it concise but informative (3-6 words)
- No file extension

Return a JSON object with:
- "suggested_name": the primary suggestion
- "alternatives": a list of 2-3 alternative names
- "confidence": a confidence score between 0.0 and 1.0

Document:
$text

JSON Response:''';

    return generateContent(prompt: prompt, maxTokens: 200);
  }

  /// Extracts key information from the given document text.
  Future<String> extractKeyInfo({required String text}) async {
    final prompt = '''Extract key information from the following document. '
'Return a JSON object with:
- "key_points": a list of the 3-7 most important points
- "entities": a list of named entities found (people, organizations, dates, amounts)
- "summary": a one-sentence summary
- "confidence": a confidence score between 0.0 and 1.0

Document:
$text

JSON Response:''';

    return generateContent(prompt: prompt, maxTokens: 512);
  }

  /// Answers a question about the given document text.
  Future<String> askQuestion({
    required String text,
    required String question,
  }) async {
    final prompt = '''Based on the following document, answer the question.

Document:
$text

Question: $question

Answer the question concisely and accurately based only on the document content. '
'If the answer cannot be found in the document, say so.

Answer:''';

    return generateContent(prompt: prompt, maxTokens: 256);
  }
}
