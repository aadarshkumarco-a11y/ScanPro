/// Application-wide constants for ScanPro.
///
/// Centralizes app name, version info, timeouts, and operational limits
/// used throughout the entire application layer.
class AppConstants {
  AppConstants._();

  // ── App Identity ──────────────────────────────────────────────
  static const String appName = 'ScanPro';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appPackageName = 'com.scanpro.app';
  static const String appDescription = 'Professional Document Scanner';

  // ── Timeouts (milliseconds) ───────────────────────────────────
  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  static const int aiRequestTimeout = 60000;
  static const int ocrProcessingTimeout = 120000;
  static const int pdfGenerationTimeout = 180000;

  // ── Operational Limits ────────────────────────────────────────
  static const int maxScanPages = 100;
  static const int maxFileSizeMB = 50;
  static const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;
  static const int maxBatchSize = 20;
  static const int maxOCRPagesPerSession = 50;
  static const int maxAIRequestsPerDay = 100;
  static const int maxDocumentNameLength = 120;
  static const int maxFolderDepth = 5;
  static const int maxTagsPerDocument = 10;
  static const int maxTagNameLength = 30;

  // ── Image Processing ─────────────────────────────────────────
  static const int defaultCompressionQuality = 85;
  static const int thumbnailSize = 200;
  static const int previewSize = 800;
  static const int maxImageDimension = 4096;
  static const int minImageDimension = 100;

  // ── PDF Settings ──────────────────────────────────────────────
  static const double defaultPdfPageWidth = 210.0; // A4 mm
  static const double defaultPdfPageHeight = 297.0; // A4 mm
  static const double defaultPdfMargin = 10.0;
  static const int defaultPdfDPI = 300;

  // ── Sync & Storage ────────────────────────────────────────────
  static const int syncRetryAttempts = 3;
  static const int syncRetryDelaySeconds = 5;
  static const int syncBatchSize = 10;
  static const int cacheMaxAgeDays = 30;
  static const int recentDocumentsCount = 10;

  // ── UI ────────────────────────────────────────────────────────
  static const int animationDurationMs = 300;
  static const int splashDurationMs = 2000;
  static const int debounceMs = 500;
  static const int snackDurationMs = 4000;
  static const int toastDurationMs = 3000;

  // ── File Extensions ───────────────────────────────────────────
  static const String pdfExtension = '.pdf';
  static const String jpegExtension = '.jpg';
  static const String pngExtension = '.png';
  static const String tiffExtension = '.tiff';

  // ── Supported Formats ─────────────────────────────────────────
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'tiff',
    'bmp',
  ];
  static const List<String> supportedDocumentFormats = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'tiff',
  ];
}
