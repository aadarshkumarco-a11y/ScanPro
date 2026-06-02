/// Database constants for Hive local storage.
///
/// Centralizes all Hive box names and field keys to prevent
/// hard-coded strings from scattering across the codebase.
class DbConstants {
  DbConstants._();

  // ── Hive Box Names ────────────────────────────────────────────
  static const String settingsBox = 'settings';
  static const String documentsBox = 'documents';
  static const String foldersBox = 'folders';
  static const String recentBox = 'recent';
  static const String trashBox = 'trash';
  static const String syncQueueBox = 'sync_queue';
  static const String cacheBox = 'cache';
  static const String authBox = 'auth';
  static const String onboardingBox = 'onboarding';
  static const String preferencesBox = 'preferences';

  // ── Settings Field Keys ───────────────────────────────────────
  static const String themeModeKey = 'theme_mode';
  static const String languageCodeKey = 'language_code';
  static const String defaultScanQualityKey = 'default_scan_quality';
  static const String autoEnhanceKey = 'auto_enhance';
  static const String autoCropKey = 'auto_crop';
  static const String defaultExportFormatKey = 'default_export_format';
  static const String cloudSyncEnabledKey = 'cloud_sync_enabled';
  static const String wifiOnlySyncKey = 'wifi_only_sync';
  static const String biometricLockKey = 'biometric_lock';
  static const String pinCodeKey = 'pin_code';
  static const String ocrLanguageKey = 'ocr_language';
  static const String pdfPageSizeKey = 'pdf_page_size';
  static const String pdfOrientationKey = 'pdf_orientation';
  static const String pdfMarginKey = 'pdf_margin';
  static const String compressionQualityKey = 'compression_quality';

  // ── Document Field Keys ───────────────────────────────────────
  static const String documentIdKey = 'id';
  static const String documentTitleKey = 'title';
  static const String documentPathKey = 'path';
  static const String documentThumbnailKey = 'thumbnail_path';
  static const String documentPagesKey = 'pages';
  static const String documentSizeKey = 'size_bytes';
  static const String documentFormatKey = 'format';
  static const String documentTagsKey = 'tags';
  static const String documentFolderIdKey = 'folder_id';
  static const String documentCreatedAtKey = 'created_at';
  static const String documentUpdatedAtKey = 'updated_at';
  static const String documentSyncedAtKey = 'synced_at';
  static const String documentIsSyncedKey = 'is_synced';
  static const String documentIsFavoriteKey = 'is_favorite';
  static const String documentIsTrashedKey = 'is_trashed';
  static const String documentOcrTextKey = 'ocr_text';
  static const String documentAiSummaryKey = 'ai_summary';
  static const String documentSourceKey = 'source';

  // ── Folder Field Keys ─────────────────────────────────────────
  static const String folderIdKey = 'id';
  static const String folderNameKey = 'name';
  static const String folderParentIdKey = 'parent_id';
  static const String folderColorKey = 'color';
  static const String folderIconKey = 'icon';
  static const String folderCreatedAtKey = 'created_at';
  static const String folderUpdatedAtKey = 'updated_at';

  // ── Sync Queue Field Keys ─────────────────────────────────────
  static const String syncIdKey = 'id';
  static const String syncOperationKey = 'operation';
  static const String syncEntityTypeKey = 'entity_type';
  static const String syncEntityIdKey = 'entity_id';
  static const String syncPayloadKey = 'payload';
  static const String syncAttemptsKey = 'attempts';
  static const String syncCreatedAtKey = 'created_at';
  static const String syncLastErrorKey = 'last_error';

  // ── Auth Field Keys ───────────────────────────────────────────
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String displayNameKey = 'display_name';
  static const String photoUrlKey = 'photo_url';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String isLoggedInKey = 'is_logged_in';

  // ── Cache Field Keys ──────────────────────────────────────────
  static const String cacheDataKey = 'data';
  static const String cacheExpiryKey = 'expiry';
  static const String cacheCreatedAtKey = 'created_at';

  // ── Onboarding Field Keys ─────────────────────────────────────
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String lastAppVersionKey = 'last_app_version';
  static const String changelogShownKey = 'changelog_shown_version';
}
