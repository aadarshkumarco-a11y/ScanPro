import 'package:hive/hive.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';

part 'scan_document_model.g.dart';

/// Hive-compatible data model for [ScanDocument].
///
/// Provides serialization/deserialization for local storage with Hive,
/// and conversion methods between the domain entity and data model.
@HiveType(typeId: 0)
class ScanDocumentModel extends HiveObject {
  /// Unique identifier.
  @HiveField(0)
  final String id;

  /// Display title.
  @HiveField(1)
  final String title;

  /// Absolute file path to the original image.
  @HiveField(2)
  final String filePath;

  /// Absolute file path to the thumbnail.
  @HiveField(3)
  final String? thumbnailPath;

  /// Absolute file path to the PDF.
  @HiveField(4)
  final String? pdfPath;

  /// ID of the parent folder.
  @HiveField(5)
  final String? folderId;

  /// List of tag IDs.
  @HiveField(6)
  final List<String> tags;

  /// Whether the document is a favorite.
  @HiveField(7)
  final bool isFavorite;

  /// Whether the document is archived.
  @HiveField(8)
  final bool isArchived;

  /// Whether the document is soft-deleted.
  @HiveField(9)
  final bool isDeleted;

  /// Creation timestamp as ISO 8601 string.
  @HiveField(10)
  final String createdAt;

  /// Last update timestamp as ISO 8601 string.
  @HiveField(11)
  final String updatedAt;

  /// File size in bytes.
  @HiveField(12)
  final int fileSize;

  /// Number of pages.
  @HiveField(13)
  final int pageCount;

  /// Extracted OCR text.
  @HiveField(14)
  final String? ocrText;

  /// Sync status index.
  @HiveField(15)
  final int syncStatusIndex;

  /// Color mode index.
  @HiveField(16)
  final int colorModeIndex;

  /// Enhancement type index.
  @HiveField(17)
  final int enhancementTypeIndex;

  ScanDocumentModel({
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
    this.syncStatusIndex = 0,
    this.colorModeIndex = 0,
    this.enhancementTypeIndex = 0,
  });

  /// Creates a model from a domain entity.
  factory ScanDocumentModel.fromEntity(ScanDocument entity) {
    return ScanDocumentModel(
      id: entity.id,
      title: entity.title,
      filePath: entity.filePath,
      thumbnailPath: entity.thumbnailPath,
      pdfPath: entity.pdfPath,
      folderId: entity.folderId,
      tags: entity.tags,
      isFavorite: entity.isFavorite,
      isArchived: entity.isArchived,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      fileSize: entity.fileSize,
      pageCount: entity.pageCount,
      ocrText: entity.ocrText,
      syncStatusIndex: entity.syncStatus.index,
      colorModeIndex: entity.colorMode.index,
      enhancementTypeIndex: entity.enhancementType.index,
    );
  }

  /// Converts this model to a domain entity.
  ScanDocument toEntity() {
    return ScanDocument(
      id: id,
      title: title,
      filePath: filePath,
      thumbnailPath: thumbnailPath,
      pdfPath: pdfPath,
      folderId: folderId,
      tags: tags,
      isFavorite: isFavorite,
      isArchived: isArchived,
      isDeleted: isDeleted,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      fileSize: fileSize,
      pageCount: pageCount,
      ocrText: ocrText,
      syncStatus: SyncStatus.values[syncStatusIndex.clamp(
        0,
        SyncStatus.values.length - 1,
      )],
      colorMode: ColorMode.values[colorModeIndex.clamp(
        0,
        ColorMode.values.length - 1,
      )],
      enhancementType: EnhancementType.values[enhancementTypeIndex.clamp(
        0,
        EnhancementType.values.length - 1,
      )],
    );
  }

  /// Converts this model to a JSON-compatible map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'thumbnailPath': thumbnailPath,
      'pdfPath': pdfPath,
      'folderId': folderId,
      'tags': tags,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'fileSize': fileSize,
      'pageCount': pageCount,
      'ocrText': ocrText,
      'syncStatusIndex': syncStatusIndex,
      'colorModeIndex': colorModeIndex,
      'enhancementTypeIndex': enhancementTypeIndex,
    };
  }

  /// Creates a model from a JSON map (e.g., from Firestore).
  factory ScanDocumentModel.fromJson(Map<String, dynamic> json) {
    return ScanDocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      pdfPath: json['pdfPath'] as String?,
      folderId: json['folderId'] as String?,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      fileSize: json['fileSize'] as int,
      pageCount: json['pageCount'] as int? ?? 1,
      ocrText: json['ocrText'] as String?,
      syncStatusIndex: json['syncStatusIndex'] as int? ?? 0,
      colorModeIndex: json['colorModeIndex'] as int? ?? 0,
      enhancementTypeIndex: json['enhancementTypeIndex'] as int? ?? 0,
    );
  }
}
