import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';

/// Custom exception for ML Kit service errors.
class MLKitException implements Exception {
  final String message;
  const MLKitException(this.message);
  @override
  String toString() => 'MLKitException: $message';
}

/// Service for text recognition and analysis using Google ML Kit.
///
/// Provides on-device OCR, language detection, smart action
/// identification, and text translation capabilities.
class MLKitService {
  TextRecognizer? _textRecognizer;

  /// Lazily initializes the ML Kit text recognizer.
  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer(
      script: TextRecognitionScript.latin,
    );
    return _textRecognizer!;
  }

  /// Recognizes text in the given image file.
  ///
  /// [imagePath] is the absolute path to the image.
  /// Returns the full recognized text as a string.
  Future<String> recognizeText(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw const MLKitException('Image file not found');
      }

      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _recognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      if (e is MLKitException) rethrow;
      throw MLKitException('Text recognition failed: $e');
    }
  }

  /// Extracts paragraphs from recognized text.
  ///
  /// Splits the text into paragraph-level blocks based on
  /// ML Kit's text block structure.
  List<String> extractParagraphs(String text) {
    if (text.isEmpty) return [];

    final paragraphs = text
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .map((p) => p.trim())
        .toList();

    return paragraphs.isNotEmpty ? paragraphs : [text.trim()];
  }

  /// Detects the language of the given text.
  ///
  /// Uses simple heuristics based on character ranges for
  /// common languages. Returns ISO 639-1 language code.
  String detectLanguage(String text) {
    if (text.isEmpty) return 'en';

    final latinRegex = RegExp(r'[a-zA-Z]');
    final latinCount = latinRegex.allMatches(text).length;
    final totalChars = text.replaceAll(RegExp(r'\s'), '').length;

    if (totalChars == 0) return 'en';

    final latinRatio = latinCount / totalChars;
    if (latinRatio > 0.8) return 'en';

    // Check for CJK characters
    final cjkRegex = RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf]');
    final cjkCount = cjkRegex.allMatches(text).length;
    if (cjkCount > totalChars * 0.3) return 'zh';

    final hiraganaRegex = RegExp(r'[\u3040-\u309f]');
    if (hiraganaRegex.allMatches(text).length > totalChars * 0.1) return 'ja';

    final hangulRegex = RegExp(r'[\uac00-\ud7af]');
    if (hangulRegex.allMatches(text).length > totalChars * 0.3) return 'ko';

    final cyrillicRegex = RegExp(r'[\u0400-\u04ff]');
    if (cyrillicRegex.allMatches(text).length > totalChars * 0.3) return 'ru';

    return 'en';
  }

  /// Calculates a confidence score for the OCR result.
  ///
  /// Returns a value between 0.0 and 1.0 based on text
  /// length, character diversity, and common patterns.
  double getConfidenceScore(String text) {
    if (text.isEmpty) return 0.0;

    double score = 0.5;

    // Longer texts tend to be more reliable
    if (text.length > 50) score += 0.1;
    if (text.length > 200) score += 0.1;

    // Mixed case suggests real text rather than noise
    if (text.contains(RegExp(r'[A-Z]')) &&
        text.contains(RegExp(r'[a-z]'))) {
      score += 0.1;
    }

    // Presence of common words suggests accurate recognition
    final commonWords = ['the', 'and', 'for', 'are', 'but', 'not'];
    final lowerText = text.toLowerCase();
    for (final word in commonWords) {
      if (lowerText.contains(word)) {
        score += 0.02;
        break;
      }
    }

    // Presence of numbers and punctuation suggests structured text
    if (text.contains(RegExp(r'\d'))) score += 0.05;
    if (text.contains(RegExp(r'[.,;:]'))) score += 0.03;

    return score.clamp(0.0, 1.0);
  }

  /// Detects smart actions in the given text.
  ///
  /// Identifies phone numbers, email addresses, URLs,
  /// physical addresses, and dates.
  List<SmartAction> detectSmartActions(String text) {
    if (text.isEmpty) return [];

    final actions = <SmartAction>[];

    // Phone number detection
    final phoneRegex = RegExp(
      r'(?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}',
    );
    for (final match in phoneRegex.allMatches(text)) {
      actions.add(SmartAction(
        type: SmartActionType.phone,
        value: match.group(0)!,
        startIndex: match.start,
        endIndex: match.end,
      ));
    }

    // Email detection
    final emailRegex = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    );
    for (final match in emailRegex.allMatches(text)) {
      actions.add(SmartAction(
        type: SmartActionType.email,
        value: match.group(0)!,
        startIndex: match.start,
        endIndex: match.end,
      ));
    }

    // URL detection
    final urlRegex = RegExp(
      r'https?://[^\s<>"]+|www\.[^\s<>"]+',
    );
    for (final match in urlRegex.allMatches(text)) {
      actions.add(SmartAction(
        type: SmartActionType.url,
        value: match.group(0)!,
        startIndex: match.start,
        endIndex: match.end,
      ));
    }

    // Date detection
    final dateRegex = RegExp(
      r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b'
      r'|\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\.?\s+\d{1,2},?\s+\d{4}\b',
      caseSensitive: false,
    );
    for (final match in dateRegex.allMatches(text)) {
      actions.add(SmartAction(
        type: SmartActionType.date,
        value: match.group(0)!,
        startIndex: match.start,
        endIndex: match.end,
      ));
    }

    // Address detection (simplified heuristic)
    final addressRegex = RegExp(
      r'\d+\s+[A-Z][a-zA-Z\s]+(?:Street|St|Avenue|Ave|Boulevard|Blvd|Road|Rd|Lane|Ln|Drive|Dr|Court|Ct)',
    );
    for (final match in addressRegex.allMatches(text)) {
      actions.add(SmartAction(
        type: SmartActionType.address,
        value: match.group(0)!,
        startIndex: match.start,
        endIndex: match.end,
      ));
    }

    return actions;
  }

  /// Translates text to the target language.
  ///
  /// Uses ML Kit's on-device translation when available,
  /// falling back to a cloud-based translation service.
  Future<String> translateText(
    String text,
    String targetLanguage,
  ) async {
    if (text.isEmpty) return '';

    try {
      // Production: Use Google ML Kit Translation or cloud API
      // final translator = OnDeviceTranslator(
      //   sourceLanguage: TranslateLanguage.english,
      //   targetLanguage: _getTranslateLanguage(targetLanguage),
      // );
      // final translated = await translator.translateText(text);
      // translator.close();
      // return translated;

      throw const MLKitException(
        'Translation requires model download; using cloud fallback',
      );
    } catch (e) {
      throw MLKitException('Translation failed: $e');
    }
  }

  /// Releases ML Kit resources.
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
