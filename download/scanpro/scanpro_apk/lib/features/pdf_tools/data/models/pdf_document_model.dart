import 'dart:convert';

import 'package:scanpro/features/pdf_tools/domain/entities/pdf_document.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_operation.dart';

/// Data model for [PdfDocumentMetadata], extending the domain entity
/// with JSON and Hive serialization support.
class PdfDocumentMetadataModel extends PdfDocumentMetadata {
  const PdfDocumentMetadataModel({
    super.title,
    super.author,
    super.subject,
    super.keywords,
    super.creator,
    super.producer,
    super.creationDate,
    super.modificationDate,
  });

  /// Creates from a domain [PdfDocumentMetadata] entity.
  factory PdfDocumentMetadataModel.fromEntity(PdfDocumentMetadata entity) {
    return PdfDocumentMetadataModel(
      title: entity.title,
      author: entity.author,
      subject: entity.subject,
      keywords: entity.keywords,
      creator: entity.creator,
      producer: entity.producer,
      creationDate: entity.creationDate,
      modificationDate: entity.modificationDate,
    );
  }

  /// Creates from a JSON map.
  factory PdfDocumentMetadataModel.fromJson(Map<String, dynamic> json) {
    return PdfDocumentMetadataModel(
      title: json['title'] as String?,
      author: json['author'] as String?,
      subject: json['subject'] as String?,
      keywords: json['keywords'] as String?,
      creator: json['creator'] as String?,
      producer: json['producer'] as String?,
      creationDate: json['creationDate'] != null
          ? DateTime.parse(json['creationDate'] as String)
          : null,
      modificationDate: json['modificationDate'] != null
          ? DateTime.parse(json['modificationDate'] as String)
          : null,
    );
  }

  /// Creates from a Hive box entry.
  factory PdfDocumentMetadataModel.fromHive(Map<dynamic, dynamic> map) {
    return PdfDocumentMetadataModel(
      title: map['title'] as String?,
      author: map['author'] as String?,
      subject: map['subject'] as String?,
      keywords: map['keywords'] as String?,
      creator: map['creator'] as String?,
      producer: map['producer'] as String?,
      creationDate: map['creationDate'] != null
          ? (map['creationDate'] is String
              ? DateTime.parse(map['creationDate'] as String)
              : DateTime.fromMillisecondsSinceEpoch(map['creationDate'] as int))
          : null,
      modificationDate: map['modificationDate'] != null
          ? (map['modificationDate'] is String
              ? DateTime.parse(map['modificationDate'] as String)
              : DateTime.fromMillisecondsSinceEpoch(
                  map['modificationDate'] as int))
          : null,
    );
  }

  /// Converts to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'subject': subject,
      'keywords': keywords,
      'creator': creator,
      'producer': producer,
      'creationDate': creationDate?.toIso8601String(),
      'modificationDate': modificationDate?.toIso8601String(),
    };
  }

  /// Converts to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'title': title,
      'author': author,
      'subject': subject,
      'keywords': keywords,
      'creator': creator,
      'producer': producer,
      'creationDate': creationDate?.toIso8601String(),
      'modificationDate': modificationDate?.toIso8601String(),
    };
  }

  /// Converts back to a domain [PdfDocumentMetadata] entity.
  PdfDocumentMetadata toEntity() {
    return PdfDocumentMetadata(
      title: title,
      author: author,
      subject: subject,
      keywords: keywords,
      creator: creator,
      producer: producer,
      creationDate: creationDate,
      modificationDate: modificationDate,
    );
  }
}

/// Data model for [PdfDocument], extending the domain entity with
/// JSON and Hive serialization support.
class PdfDocumentModel extends PdfDocument {
  const PdfDocumentModel({
    required super.id,
    required super.filePath,
    required super.fileName,
    required super.pageCount,
    required super.fileSize,
    required super.createdAt,
    super.isEncrypted = false,
    super.metadata = const PdfDocumentMetadata(),
  });

  /// Creates from a domain [PdfDocument] entity.
  factory PdfDocumentModel.fromEntity(PdfDocument entity) {
    return PdfDocumentModel(
      id: entity.id,
      filePath: entity.filePath,
      fileName: entity.fileName,
      pageCount: entity.pageCount,
      fileSize: entity.fileSize,
      createdAt: entity.createdAt,
      isEncrypted: entity.isEncrypted,
      metadata: entity.metadata,
    );
  }

  /// Creates from a JSON map.
  factory PdfDocumentModel.fromJson(Map<String, dynamic> json) {
    return PdfDocumentModel(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
      pageCount: json['pageCount'] as int? ?? 0,
      fileSize: json['fileSize'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isEncrypted: json['isEncrypted'] as bool? ?? false,
      metadata: json['metadata'] != null
          ? PdfDocumentMetadataModel.fromJson(
              json['metadata'] as Map<String, dynamic>)
          : const PdfDocumentMetadata(),
    );
  }

  /// Creates from a Hive box entry.
  factory PdfDocumentModel.fromHive(Map<dynamic, dynamic> map) {
    PdfDocumentMetadata parseMetadata(dynamic data) {
      if (data == null) return const PdfDocumentMetadata();
      if (data is String) {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        return PdfDocumentMetadataModel.fromJson(decoded).toEntity();
      }
      if (data is Map) {
        return PdfDocumentMetadataModel.fromHive(
          Map<dynamic, dynamic>.from(data),
        ).toEntity();
      }
      return const PdfDocumentMetadata();
    }

    return PdfDocumentModel(
      id: map['id'] as String,
      filePath: map['filePath'] as String,
      fileName: map['fileName'] as String,
      pageCount: map['pageCount'] as int? ?? 0,
      fileSize: map['fileSize'] as int? ?? 0,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isEncrypted: map['isEncrypted'] as bool? ?? false,
      metadata: parseMetadata(map['metadata']),
    );
  }

  /// Converts to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'pageCount': pageCount,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'isEncrypted': isEncrypted,
      'metadata':
          PdfDocumentMetadataModel.fromEntity(metadata).toJson(),
    };
  }

  /// Converts to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'pageCount': pageCount,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'isEncrypted': isEncrypted,
      'metadata': jsonEncode(
        PdfDocumentMetadataModel.fromEntity(metadata).toJson(),
      ),
    };
  }

  /// Converts back to a domain [PdfDocument] entity.
  PdfDocument toEntity() {
    return PdfDocument(
      id: id,
      filePath: filePath,
      fileName: fileName,
      pageCount: pageCount,
      fileSize: fileSize,
      createdAt: createdAt,
      isEncrypted: isEncrypted,
      metadata: metadata,
    );
  }
}

/// Data model for [PdfOperationResult] with serialization support.
class PdfOperationResultModel extends PdfOperationResult {
  const PdfOperationResultModel({
    required super.id,
    required super.operation,
    required super.outputPath,
    required super.success,
    super.originalSize = 0,
    super.resultSize = 0,
    super.pageCount = 0,
    super.errorMessage,
    super.completedAt,
  });

  /// Creates from a domain [PdfOperationResult] entity.
  factory PdfOperationResultModel.fromEntity(PdfOperationResult entity) {
    return PdfOperationResultModel(
      id: entity.id,
      operation: entity.operation,
      outputPath: entity.outputPath,
      success: entity.success,
      originalSize: entity.originalSize,
      resultSize: entity.resultSize,
      pageCount: entity.pageCount,
      errorMessage: entity.errorMessage,
      completedAt: entity.completedAt,
    );
  }

  /// Creates from a JSON map.
  factory PdfOperationResultModel.fromJson(Map<String, dynamic> json) {
    return PdfOperationResultModel(
      id: json['id'] as String,
      operation: PdfOperation.values.firstWhere(
        (e) => e.name == json['operation'],
        orElse: () => PdfOperation.create,
      ),
      outputPath: json['outputPath'] as String,
      success: json['success'] as bool? ?? false,
      originalSize: json['originalSize'] as int? ?? 0,
      resultSize: json['resultSize'] as int? ?? 0,
      pageCount: json['pageCount'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  /// Creates from a Hive box entry.
  factory PdfOperationResultModel.fromHive(Map<dynamic, dynamic> map) {
    return PdfOperationResultModel(
      id: map['id'] as String,
      operation: PdfOperation.values.firstWhere(
        (e) => e.name == map['operation'],
        orElse: () => PdfOperation.create,
      ),
      outputPath: map['outputPath'] as String,
      success: map['success'] as bool? ?? false,
      originalSize: map['originalSize'] as int? ?? 0,
      resultSize: map['resultSize'] as int? ?? 0,
      pageCount: map['pageCount'] as int? ?? 0,
      errorMessage: map['errorMessage'] as String?,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] is String
              ? DateTime.parse(map['completedAt'] as String)
              : DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int))
          : null,
    );
  }

  /// Converts to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operation': operation.name,
      'outputPath': outputPath,
      'success': success,
      'originalSize': originalSize,
      'resultSize': resultSize,
      'pageCount': pageCount,
      'errorMessage': errorMessage,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Converts to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'operation': operation.name,
      'outputPath': outputPath,
      'success': success,
      'originalSize': originalSize,
      'resultSize': resultSize,
      'pageCount': pageCount,
      'errorMessage': errorMessage,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Converts back to a domain [PdfOperationResult] entity.
  PdfOperationResult toEntity() {
    return PdfOperationResult(
      id: id,
      operation: operation,
      outputPath: outputPath,
      success: success,
      originalSize: originalSize,
      resultSize: resultSize,
      pageCount: pageCount,
      errorMessage: errorMessage,
      completedAt: completedAt,
    );
  }
}
