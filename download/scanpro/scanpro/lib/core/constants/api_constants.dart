/// API constants for external service integration.
///
/// Centralizes endpoints, model identifiers, and configuration
/// values for Gemini AI and ML Kit services.
class ApiConstants {
  ApiConstants._();

  // ── Gemini AI ─────────────────────────────────────────────────
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiGenerateEndpoint = '/models/{model}:generateContent';
  static const String geminiStreamEndpoint =
      '/models/{model}:streamGenerateContent';
  static const String geminiVisionModel = 'gemini-1.5-flash';
  static const String geminiTextModel = 'gemini-1.5-flash';
  static const String geminiProModel = 'gemini-1.5-pro';

  /// Rate limits for Gemini API calls.
  static const int geminiRequestsPerMinute = 15;
  static const int geminiTokensPerRequest = 8192;
  static const int geminiMaxOutputTokens = 4096;
  static const double geminiTemperature = 0.4;
  static const double geminiTopP = 0.95;
  static const int geminiTopK = 40;

  // ── Gemini AI Prompts ─────────────────────────────────────────
  static const String documentSummaryPrompt =
      'Provide a concise summary of the following document content. '
      'Focus on key information, important dates, and action items.';
  static const String documentCategorizePrompt =
      'Categorize this document into one of these categories: '
      'Invoice, Receipt, Contract, Report, Letter, ID Document, '
      'Note, Form, Other. Return only the category name.';
  static const String documentExtractFieldsPrompt =
      'Extract key fields from this document as structured data. '
      'Include dates, amounts, names, addresses, and reference numbers.';
  static const String documentTranslatePrompt =
      'Translate the following document text to {language}. '
      'Preserve formatting and structure.';
  static const String ocrCorrectionPrompt =
      'Correct any OCR errors in the following text while preserving '
      'the original meaning and formatting. Fix common OCR mistakes '
      'like confused characters (0/O, 1/l/I, 5/S).';

  // ── ML Kit Configuration ─────────────────────────────────────
  static const double mlKitMinTextConfidence = 0.5;
  static const double mlKitMinBlockConfidence = 0.6;
  static const int mlKitMaxResults = 50;
  static const bool mlKitEnableSubpixel = true;
  static const bool mlKitEnableSegmentation = true;

  /// Supported OCR language codes for ML Kit.
  static const List<String> mlKitSupportedLanguages = [
    'en',   // English
    'es',   // Spanish
    'fr',   // French
    'de',   // German
    'it',   // Italian
    'pt',   // Portuguese
    'zh',   // Chinese
    'ja',   // Japanese
    'ko',   // Korean
    'ar',   // Arabic
    'hi',   // Hindi
    'ru',   // Russian
  ];

  /// Default OCR script for ML Kit text recognizer.
  static const String mlKitDefaultScript = 'LATIN';

  // ── Document Scanner (ML Kit) ─────────────────────────────────
  static const double scannerMinConfidence = 0.7;
  static const double scannerEdgeThreshold = 50.0;
  static const int scannerMaxRetries = 3;

  // ── OpenCV Processing ─────────────────────────────────────────
  static const int opencvGaussianKernelSize = 5;
  static const double opencvCannyThreshold1 = 50.0;
  static const double opencvCannyThreshold2 = 150.0;
  static const int opencvMorphKernelSize = 3;
  static const double opencvAdaptiveBlocksize = 11;
  static const double opencvAdaptiveC = 2.0;
  static const double opencvPerspectiveEpsilon = 0.02;

  // ── HTTP Headers ──────────────────────────────────────────────
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerBearerPrefix = 'Bearer ';
  static const String headerJsonContentType = 'application/json';
  static const String headerMultipartContentType = 'multipart/form-data';

  // ── Error Response Codes ──────────────────────────────────────
  static const int codeRateLimited = 429;
  static const int codeUnauthorized = 401;
  static const int codeForbidden = 403;
  static const int codeNotFound = 404;
  static const int codeServerError = 500;
  static const int codeServiceUnavailable = 503;
}
