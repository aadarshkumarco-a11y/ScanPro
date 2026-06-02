/// Firebase constants for Firestore collections and Storage paths.
///
/// Provides a single source of truth for all Firebase resource paths
/// to avoid duplicated string literals across data layers.
class FirebaseConstants {
  FirebaseConstants._();

  // ── Firestore Collection Paths ────────────────────────────────
  static const String usersCollection = 'users';
  static const String documentsCollection = 'documents';
  static const String foldersCollection = 'folders';
  static const String sharedDocumentsCollection = 'shared_documents';
  static const String analyticsCollection = 'analytics';
  static const String feedbackCollection = 'feedback';

  // ── User Sub-collections ──────────────────────────────────────
  /// Returns the path to a user's documents sub-collection.
  static String userDocumentsPath(String userId) =>
      '$usersCollection/$userId/$documentsCollection';

  /// Returns the path to a user's folders sub-collection.
  static String userFoldersPath(String userId) =>
      '$usersCollection/$userId/$foldersCollection';

  /// Returns the path to a user's shared documents sub-collection.
  static String userSharedDocumentsPath(String userId) =>
      '$usersCollection/$userId/$sharedDocumentsCollection';

  /// Returns the path to a user's analytics sub-collection.
  static String userAnalyticsPath(String userId) =>
      '$usersCollection/$userId/$analyticsCollection';

  // ── Firestore Document Paths ──────────────────────────────────
  /// Returns the path to a specific user document.
  static String userPath(String userId) =>
      '$usersCollection/$userId';

  /// Returns the path to a specific document within a user's collection.
  static String documentPath(String userId, String documentId) =>
      '${userDocumentsPath(userId)}/$documentId';

  /// Returns the path to a specific folder within a user's collection.
  static String folderPath(String userId, String folderId) =>
      '${userFoldersPath(userId)}/$folderId';

  // ── Cloud Storage Paths ───────────────────────────────────────
  static const String storageBucket = 'gs://scanpro-app.appspot.com';

  /// Returns the storage path for a user's original document files.
  static String userDocumentsStoragePath(String userId) =>
      'users/$userId/documents';

  /// Returns the storage path for a user's document thumbnails.
  static String userThumbnailsStoragePath(String userId) =>
      'users/$userId/thumbnails';

  /// Returns the storage path for a user's OCR result files.
  static String userOcrResultsStoragePath(String userId) =>
      'users/$userId/ocr';

  /// Returns the storage path for a specific document file.
  static String documentStoragePath(String userId, String documentId) =>
      '${userDocumentsStoragePath(userId)}/$documentId';

  /// Returns the storage path for a specific thumbnail.
  static String thumbnailStoragePath(String userId, String documentId) =>
      '${userThumbnailsStoragePath(userId)}/$documentId';

  /// Returns the storage path for a specific OCR result.
  static String ocrResultStoragePath(String userId, String documentId) =>
      '${userOcrResultsStoragePath(userId)}/$documentId';

  // ── Storage Upload Metadata ───────────────────────────────────
  static const String metadataOriginalName = 'original_name';
  static const String metadataContentType = 'content_type';
  static const String metadataUploadedAt = 'uploaded_at';
  static const String metadataDocumentId = 'document_id';
  static const String metadataPageSize = 'page_size';

  // ── Security Rules Version ────────────────────────────────────
  static const int rulesVersion = 2;

  // ── Firestore Indexes ─────────────────────────────────────────
  /// Field names used in compound queries for index configuration.
  static const String fieldCreatedAt = 'created_at';
  static const String fieldUpdatedAt = 'updated_at';
  static const String fieldFolderId = 'folder_id';
  static const String fieldIsTrashed = 'is_trashed';
  static const String fieldIsFavorite = 'is_favorite';
  static const String fieldIsSynced = 'is_synced';
  static const String fieldTags = 'tags';
}
