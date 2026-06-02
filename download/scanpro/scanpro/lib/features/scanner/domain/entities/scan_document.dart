import 'package:equatable/equatable.dart';

/// Enumeration of supported color modes for scanned documents.
enum ColorMode {
  /// Full color scan preserving original colors.
  color,

  /// Grayscale scan removing color information.
  grayscale,

  /// Black and white (binary) scan for text documents.
  blackAndWhite,
}

/// Enumeration of image enhancement types available for scanned documents.
enum EnhancementType {
  /// No enhancement applied.
  none,

  /// Auto-enhancement with brightness/contrast optimization.
  auto,

  /// Sharpening filter for blurry text.
  sharp,

  /// Magic filter combining multiple enhancements.
  magic,

  /// Shadow removal for uneven lighting.
  removeShadows,

  /// Brightness boost for dark scans.
  brighten,
}

/// Enumeration of document synchronization statuses.
enum SyncStatus {
  /// Document exists only locally.
  localOnly,

  /// Document is synchronized with cloud.
  synced,

  /// Local changes pending upload.
  pendingUpload,

  /// Cloud changes pending download.
  pendingDownload,

  /// Sync conflict detected.
  conflict,
}

/// Core entity representing a scanned document in the domain layer.
///
/// This is the primary document model used across the application,
/// containing all metadata and status information for a scanned document.
class ScanDocument extends Equatable {
  /// Unique identifier for the document.
  final String id;

  /// User-visible title of the document.
  final String title;

  /// Absolute file path to the original scanned image.
  final String filePath;

  /// Absolute file path to the thumbnail image.
  final String? thumbnailPath;

  /// Absolute file path to the exported PDF file.
  final String? pdfPath;

  /// ID of the parent folder, null for root-level documents.
  final String? folderId;

  /// List of tag IDs associated with this document.
  final List<String> tags;

  /// Whether the document is marked as favorite.
  final bool isFavorite;

  /// Whether the document is archived.
  final bool isArchived;

  /// Soft-delete flag; true when the user has deleted the document.
  final bool isDeleted;

  /// Timestamp when the document was created.
  final DateTime createdAt;

  /// Timestamp when the document was last updated.
  final DateTime updatedAt;

  /// File size in bytes.
  final int fileSize;

  /// Number of pages in the document.
  final int pageCount;

  /// Extracted OCR text content, null if OCR has not been run.
  final String? ocrText;

  /// Current synchronization status with cloud storage.
  final SyncStatus syncStatus;

  /// Color mode used when scanning the document.
  final ColorMode colorMode;

  /// Enhancement type applied to the document.
  final EnhancementType enhancementType;

  const ScanDocument({
    required this.id,
    required this.title,
    required this.filePath,
    this.thumbnailPath,
    this.pdfPath,
    this.folderId,
    this.tags = const [],
    this.isFavorite = false,
    this.isArchived = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    required this.fileSize,
    this.pageCount = 1,
    this.ocrText,
    this.syncStatus = SyncStatus.localOnly,
    this.colorMode = ColorMode.color,
    this.enhancementType = EnhancementType.none,
  });

  /// Creates a copy of this document with the given fields replaced.
  ScanDocument copyWith({
    String? id,
    String? title,
    String? filePath,
    String? thumbnailPath,
    String? pdfPath,
    String? folderId,
    List<String>? tags,
    bool? isFavorite,
    bool? isArchived,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? fileSize,
    int? pageCount,
    String? ocrText,
    SyncStatus? syncStatus,
    ColorMode? colorMode,
    EnhancementType? enhancementType,
  }) {
    return ScanDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      pdfPath: pdfPath ?? this.pdfPath,
      folderId: folderId ?? this.folderId,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fileSize: fileSize ?? this.fileSize,
      pageCount: pageCount ?? this.pageCount,
      ocrText: ocrText ?? this.ocrText,
      syncStatus: syncStatus ?? this.syncStatus,
      colorMode: colorMode ?? this.colorMode,
      enhancementType: enhancementType ?? this.enhancementType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        filePath,
        thumbnailPath,
        pdfPath,
        folderId,
        tags,
        isFavorite,
        isArchived,
        isDeleted,
        createdAt,
        updatedAt,
        fileSize,
        pageCount,
        ocrText,
        syncStatus,
        colorMode,
        enhancementType,
      ];
}
