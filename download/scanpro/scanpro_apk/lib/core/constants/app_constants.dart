/// Application-wide constants for ScanPro.
///
/// Centralizes all magic values, configuration strings, and
/// feature flags that are referenced throughout the codebase.
class AppConstants {
  AppConstants._();

  // ── App Identity ────────────────────────────────────────────────
  static const String appName = 'ScanPro';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  static const String appPackageName = 'com.scanpro.app';
  static const String appDescription =
      'Professional Document Scanning & Management';

  // ── API Keys (placeholders – inject from .env in production) ────
  static const String geminiApiKey = 'GEMINI_API_KEY';
  static const String firebaseApiKey = 'FIREBASE_API_KEY';
  static const String firebaseProjectId = 'FIREBASE_PROJECT_ID';
  static const String firebaseMessagingSenderId = 'FIREBASE_MESSAGING_SENDER_ID';
  static const String firebaseAppId = 'FIREBASE_APP_ID';

  // ── Storage Keys ────────────────────────────────────────────────
  static const String secureStoragePinKey = 'app_pin_hash';
  static const String secureStorageBiometricKey = 'biometric_enabled';
  static const String secureStorageEncryptionKey = 'encryption_key';
  static const String prefsThemeModeKey = 'theme_mode';
  static const String prefsOnboardingCompleteKey = 'onboarding_complete';
  static const String prefsFirstLaunchKey = 'first_launch';
  static const String prefsLastSyncKey = 'last_sync_timestamp';
  static const String prefsAutoSyncKey = 'auto_sync_enabled';
  static const String prefsWifiOnlySyncKey = 'wifi_only_sync';
  static const String prefsDefaultScanQualityKey = 'default_scan_quality';
  static const String prefsDefaultExportFormatKey = 'default_export_format';
  static const String prefsLanguageKey = 'app_language';

  // ── Hive Box Names ──────────────────────────────────────────────
  static const String documentsBox = 'documents_box';
  static const String foldersBox = 'folders_box';
  static const String tagsBox = 'tags_box';
  static const String syncRecordsBox = 'sync_records_box';
  static const String signaturesBox = 'signatures_box';
  static const String annotationsBox = 'annotations_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
  static const String searchBox = 'search_box';
  static const String qrResultsBox = 'qr_results_box';

  // ── Route Paths ─────────────────────────────────────────────────
  static const String homeRoute = '/home';
  static const String scannerRoute = '/scanner';
  static const String scannerResultRoute = '/scanner/result';
  static const String documentsRoute = '/documents';
  static const String documentDetailRoute = '/documents/detail';
  static const String documentFolderRoute = '/documents/folder';
  static const String ocrRoute = '/ocr';
  static const String ocrResultRoute = '/ocr/result';
  static const String pdfToolsRoute = '/pdf-tools';
  static const String pdfCreateRoute = '/pdf-tools/create';
  static const String pdfMergeRoute = '/pdf-tools/merge';
  static const String pdfSplitRoute = '/pdf-tools/split';
  static const String pdfCompressRoute = '/pdf-tools/compress';
  static const String searchRoute = '/search';
  static const String cloudSyncRoute = '/cloud-sync';
  static const String securityRoute = '/security';
  static const String securitySetupRoute = '/security/setup';
  static const String securityVerifyRoute = '/security/verify';
  static const String aiFeaturesRoute = '/ai-features';
  static const String aiSummaryRoute = '/ai-features/summary';
  static const String signatureRoute = '/signature';
  static const String signatureDrawRoute = '/signature/draw';
  static const String annotationsRoute = '/annotations';
  static const String qrScannerRoute = '/qr-scanner';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';

  // ── Route Names (for named navigation) ──────────────────────────
  static const String homeName = 'home';
  static const String scannerName = 'scanner';
  static const String scannerResultName = 'scanner-result';
  static const String documentsName = 'documents';
  static const String documentDetailName = 'document-detail';
  static const String documentFolderName = 'document-folder';
  static const String ocrName = 'ocr';
  static const String ocrResultName = 'ocr-result';
  static const String pdfToolsName = 'pdf-tools';
  static const String pdfCreateName = 'pdf-create';
  static const String pdfMergeName = 'pdf-merge';
  static const String pdfSplitName = 'pdf-split';
  static const String pdfCompressName = 'pdf-compress';
  static const String searchName = 'search';
  static const String cloudSyncName = 'cloud-sync';
  static const String securityName = 'security';
  static const String securitySetupName = 'security-setup';
  static const String securityVerifyName = 'security-verify';
  static const String aiFeaturesName = 'ai-features';
  static const String aiSummaryName = 'ai-summary';
  static const String signatureName = 'signature';
  static const String signatureDrawName = 'signature-draw';
  static const String annotationsName = 'annotations';
  static const String qrScannerName = 'qr-scanner';
  static const String profileName = 'profile';
  static const String settingsName = 'settings';

  // ── Security ────────────────────────────────────────────────────
  static const int pinLength = 6;
  static const int maxPinAttempts = 5;
  static const int lockoutDurationMinutes = 5;
  static const int encryptionKeyLength = 256;
  static const int sessionTimeoutMinutes = 30;

  // ── Scan Defaults ───────────────────────────────────────────────
  static const double defaultJpegQuality = 0.85;
  static const int defaultDpi = 300;
  static const double defaultEdgeDetectionConfidence = 0.7;
  static const int maxBatchScanPages = 50;
  static const double maxImageSizeMb = 20.0;

  // ── PDF Defaults ────────────────────────────────────────────────
  static const double pdfCompressionQualityLow = 0.3;
  static const double pdfCompressionQualityMedium = 0.6;
  static const double pdfCompressionQualityHigh = 0.85;
  static const int pdfMaxMergeFiles = 20;
  static const int pdfDefaultPageWidth = 595; // A4 in points
  static const int pdfDefaultPageHeight = 842;

  // ── Cloud Sync ──────────────────────────────────────────────────
  static const int syncBatchSize = 50;
  static const int syncMaxRetries = 3;
  static const int syncRetryDelaySeconds = 30;
  static const int syncConflictResolutionTimeout = 300; // seconds
  static const int maxCloudStorageMb = 2048; // 2 GB free tier

  // ── OCR ─────────────────────────────────────────────────────────
  static const double ocrMinConfidence = 0.5;
  static const int ocrMaxFileSizeMb = 20;
  static const List<String> ocrSupportedLanguages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'zh',
    'ja',
    'ko',
    'ar',
    'hi',
    'ru',
  ];

  // ── AI ──────────────────────────────────────────────────────────
  static const int aiSummaryMaxWordsDefault = 200;
  static const int aiSummaryMaxWordsLimit = 500;
  static const double aiMinConfidence = 0.6;
  static const int aiRequestTimeoutSeconds = 60;
  static const int aiMaxRetries = 2;

  // ── UI / Animation ──────────────────────────────────────────────
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration splashDuration = Duration(seconds: 2);
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // ── File Extensions ─────────────────────────────────────────────
  static const List<String> supportedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.bmp',
    '.tiff',
  ];
  static const List<String> supportedDocumentExtensions = [
    '.pdf',
  ];
  static const String defaultExportExtension = '.pdf';

  // ── Date Formats ────────────────────────────────────────────────
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';
  static const String displayDateTimeFormat = 'MMM dd, yyyy hh:mm a';
  static const String fileDateFormat = 'yyyy-MM-dd_HH-mm-ss';
  static const String syncDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  // ── Pagination ──────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ── URLs ────────────────────────────────────────────────────────
  static const String privacyPolicyUrl =
      'https://scanpro.app/privacy-policy';
  static const String termsOfServiceUrl =
      'https://scanpro.app/terms-of-service';
  static const String helpCenterUrl = 'https://scanpro.app/help';
  static const String feedbackUrl = 'https://scanpro.app/feedback';
  static const String premiumPageUrl = 'https://scanpro.app/premium';
}
