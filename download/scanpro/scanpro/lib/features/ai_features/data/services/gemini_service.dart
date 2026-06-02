import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Custom exception for Gemini service errors.
class GeminiException implements Exception {
  final String message;
  const GeminiException(this.message);
  @override
  String toString() => 'GeminiException: $message';
}

/// Service for interacting with the Gemini AI API.
///
/// Provides text generation, analysis, and structured data
/// extraction capabilities using Google's Gemini models.
class GeminiService {
  late final GenerativeModel _model;
  late final GenerativeModel _jsonModel;

  /// The Gemini API key used for authentication.
  final String _apiKey;

  /// Creates a new GeminiService with the provided API key.
  GeminiService({required String apiKey}) : _apiKey = apiKey {
    _initializeModel();
  }

  /// Initializes the Gemini generative models.
  void _initializeModel() {
    if (_apiKey.isEmpty) {
      throw const GeminiException('API key cannot be empty');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        topP: 0.9,
        topK: 40,
        maxOutputTokens: 2048,
      ),
    );

    _jsonModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        topP: 0.9,
        topK: 40,
        maxOutputTokens: 2048,
        responseMimeType: 'application/json',
      ),
    );
  }

  /// Generates content based on the provided prompt.
  ///
  /// [prompt] is the text prompt to send to Gemini.
  /// Returns a map of parsed response fields.
  Future<Map<String, dynamic>> generateContent({
    required String prompt,
  }) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _jsonModel.generateContent(content);

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        throw const GeminiException('Empty response from Gemini');
      }

      return _parseJsonResponse(responseText);
    } on GeminiException {
      rethrow;
    } catch (e) {
      throw GeminiException('Content generation failed: $e');
    }
  }

  /// Generates a text completion without JSON formatting.
  ///
  /// [prompt] is the text prompt to send to Gemini.
  /// Returns the raw text response.
  Future<String> generateText({required String prompt}) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        throw const GeminiException('Empty response from Gemini');
      }

      return responseText;
    } on GeminiException {
      rethrow;
    } catch (e) {
      throw GeminiException('Text generation failed: $e');
    }
  }

  /// Generates content using multi-turn conversation context.
  ///
  /// [history] is the conversation history as a list of Content objects.
  /// [prompt] is the current user message.
  /// Returns the model's response text.
  Future<String> chat({
    required List<Content> history,
    required String prompt,
  }) async {
    try {
      final chatSession = _model.startChat(history: history);
      final response = await chatSession.sendMessage(Content.text(prompt));

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        throw const GeminiException('Empty chat response from Gemini');
      }

      return responseText;
    } on GeminiException {
      rethrow;
    } catch (e) {
      throw GeminiException('Chat generation failed: $e');
    }
  }

  /// Analyzes a document and extracts a summary with key points.
  ///
  /// [text] is the OCR-extracted document text.
  /// Returns a map containing 'summary', 'keyPoints', 'category',
  /// 'suggestedTags', and 'confidence'.
  Future<Map<String, dynamic>> analyzeDocument(String text) async {
    if (text.isEmpty) {
      throw const GeminiException('Document text cannot be empty');
    }

    return generateContent(
      prompt: 'Analyze this document and provide:\n'
          '1. A concise summary (max 150 words)\n'
          '2. 3-5 key points as a list\n'
          '3. A category from: invoice, receipt, contract, id_card, '
          'letter, report, certificate, form, other\n'
          '4. 3-5 suggested tags\n'
          '5. Confidence score (0.0-1.0)\n\n'
          'Return as JSON: {"summary": "...", "keyPoints": [...], '
          '"category": "...", "suggestedTags": [...], "confidence": 0.0}\n\n'
          'Document:\n$text',
    );
  }

  /// Extracts structured data from a document based on its type.
  ///
  /// [text] is the OCR-extracted document text.
  /// Returns a map with 'documentType', 'fields', and 'confidence'.
  Future<Map<String, dynamic>> extractStructuredData(String text) async {
    if (text.isEmpty) {
      throw const GeminiException('Document text cannot be empty');
    }

    return generateContent(
      prompt: 'Extract structured data from this document.\n'
          'Identify the document type and extract all relevant fields.\n\n'
          'Return as JSON: {"documentType": "...", "fields": {...}, '
          '"confidence": 0.0}\n\n'
          'Document:\n$text',
    );
  }

  /// Parses a JSON response string into a Map.
  ///
  /// Handles various response formats including raw JSON,
  /// JSON wrapped in markdown code blocks, and partial JSON.
  Map<String, dynamic> _parseJsonResponse(String response) {
    try {
      var cleaned = response.trim();

      // Remove markdown code block wrapper if present
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();

      return Map<String, dynamic>.from(json.decode(cleaned));
    } on FormatException catch (e) {
      throw GeminiException('Failed to parse JSON response: $e');
    }
  }
}
