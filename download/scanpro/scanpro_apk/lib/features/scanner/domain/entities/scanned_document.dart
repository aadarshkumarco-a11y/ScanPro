import 'package:equatable/equatable.dart';

/// Domain entity representing a single scanned page within a document.
///
/// Each page stores its own file path, crop region, rotation,
/// brightness/contrast adjustments, and applied filter.
class ScannedPage extends Equatable {
  const ScannedPage({
    required this.id,
    required this.filePath,
    this.cropArea,
    this.rotation = 0,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.filters = const [],
  });

  /// Unique identifier for this page.
  final String id;

  /// Absolute file path to the scanned image.
  final String filePath;

  /// Optional crop rectangle defined by four corner offsets.
  /// Stored as [left, top, right, bottom] normalised values (0.0–1.0).
  final List<double>? cropArea;

  /// Rotation angle in degrees (0, 90, 180, 270).
  final int rotation;

  /// Brightness adjustment (-1.0 to 1.0).
  final double brightness;

  /// Contrast multiplier (0.0 to 2.0, 1.0 = normal).
  final double contrast;

  /// List of applied filter names (e.g. 'grayscale', 'bw', 'magic_color').
  final List<String> filters;

  /// Creates a copy with optional field overrides.
  ScannedPage copyWith({
    String? id,
    String? filePath,
    List<double>? cropArea,
    int? rotation,
    double? brightness,
    double? contrast,
    List<String>? filters,
  }) {
    return ScannedPage(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      cropArea: cropArea ?? this.cropArea,
      rotation: rotation ?? this.rotation,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [
        id,
        filePath,
        cropArea,
        rotation,
        brightness,
        contrast,
        filters,
      ];
}

/// Domain entity representing a complete scanned document.
///
/// A document can contain multiple [ScannedPage]s and carries
/// metadata such as name, tags, folder assignment, OCR text,
/// and sync/lock status.
class ScannedDocument extends Equatable {
  const ScannedDocument({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    this.thumbnailPath,
    this.pages = const [],
    this.tags = const [],
    this.isFavorite = false,
    this.folderId,
    this.fileSize = 0,
    this.ocrText,
    this.pdfPath,
    this.isSynced = false,
    this.isLocked = false,
  });

  /// Unique identifier for this document.
  final String id;

  /// Absolute file path to the primary document image or PDF.
  final String filePath;

  /// Absolute file path to the thumbnail image.
  final String? thumbnailPath;

  /// Ordered list of pages in this document.
  final List<ScannedPage> pages;

  /// Timestamp when the document was first created.
  final DateTime createdAt;

  /// Timestamp when the document was last modified.
  final DateTime updatedAt;

  /// Human-readable document name.
  final String name;

  /// User-assigned tags for categorisation.
  final List<String> tags;

  /// Whether this document is marked as a favourite.
  final bool isFavorite;

  /// ID of the folder this document belongs to, or null for root.
  final String? folderId;

  /// Total file size in bytes.
  final int fileSize;

  /// OCR-extracted text content, if available.
  final String? ocrText;

  /// Absolute file path to the exported PDF, if generated.
  final String? pdfPath;

  /// Whether this document has been synced to the cloud.
  final bool isSynced;

  /// Whether this document is locked (requires authentication to view).
  final bool isLocked;

  /// Creates a copy with optional field overrides.
  ScannedDocument copyWith({
    String? id,
    String? filePath,
    String? thumbnailPath,
    List<ScannedPage>? pages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    List<String>? tags,
    bool? isFavorite,
    String? folderId,
    int? fileSize,
    String? ocrText,
    String? pdfPath,
    bool? isSynced,
    bool? isLocked,
  }) {
    return ScannedDocument(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      pages: pages ?? this.pages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      folderId: folderId ?? this.folderId,
      fileSize: fileSize ?? this.fileSize,
      ocrText: ocrText ?? this.ocrText,
      pdfPath: pdfPath ?? this.pdfPath,
      isSynced: isSynced ?? this.isSynced,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        filePath,
        thumbnailPath,
        pages,
        createdAt,
        updatedAt,
        name,
        tags,
        isFavorite,
        folderId,
        fileSize,
        ocrText,
        pdfPath,
        isSynced,
        isLocked,
      ];
}
