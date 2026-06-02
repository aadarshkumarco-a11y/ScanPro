import 'package:hive/hive.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_document.dart';

part 'pdf_document_model.g.dart';

/// Hive-compatible data model for [PDFDocument].
///
/// Provides serialization/deserialization for local storage with Hive,
/// and conversion methods between the domain entity and data model.
@HiveType(typeId: 5)
class PDFDocumentModel extends HiveObject {
  /// Unique identifier.
  @HiveField(0)
  final String id;

  /// Display title.
  @HiveField(1)
  final String title;

  /// Absolute file path to the PDF.
  @HiveField(2)
  final String filePath;

  /// File size in bytes.
  @HiveField(3)
  final int fileSize;

  /// Number of pages.
  @HiveField(4)
  final int pageCount;

  /// Creation timestamp as ISO 8601 string.
  @HiveField(5)
  final String createdAt;

  /// Last update timestamp as ISO 8601 string.
  @HiveField(6)
  final String updatedAt;

  PDFDocumentModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileSize,
    this.pageCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a model from a domain entity.
  factory PDFDocumentModel.fromEntity(PDFDocument entity) {
    return PDFDocumentModel(
      id: entity.id,
      title: entity.title,
      filePath: entity.filePath,
      fileSize: entity.fileSize,
      pageCount: entity.pageCount,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  /// Converts this model to a domain entity.
  PDFDocument toEntity() {
    return PDFDocument(
      id: id,
      title: title,
      filePath: filePath,
      fileSize: fileSize,
      pageCount: pageCount,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'fileSize': fileSize,
      'pageCount': pageCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a model from a JSON map.
  factory PDFDocumentModel.fromJson(Map<String, dynamic> json) {
    return PDFDocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      fileSize: json['fileSize'] as int,
      pageCount: json['pageCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
