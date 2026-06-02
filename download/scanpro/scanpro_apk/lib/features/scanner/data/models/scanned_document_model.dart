import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';

/// Data model for [ScannedPage], extending the domain entity with
/// JSON and Hive serialization support.
class ScannedPageModel extends ScannedPage {
  const ScannedPageModel({
    required super.id,
    required super.filePath,
    super.cropArea,
    super.rotation = 0,
    super.brightness = 0.0,
    super.contrast = 1.0,
    super.filters = const [],
  });

  /// Creates a [ScannedPageModel] from a domain [ScannedPage] entity.
  factory ScannedPageModel.fromEntity(ScannedPage entity) {
    return ScannedPageModel(
      id: entity.id,
      filePath: entity.filePath,
      cropArea: entity.cropArea,
      rotation: entity.rotation,
      brightness: entity.brightness,
      contrast: entity.contrast,
      filters: entity.filters,
    );
  }

  /// Creates a [ScannedPageModel] from a JSON map.
  factory ScannedPageModel.fromJson(Map<String, dynamic> json) {
    return ScannedPageModel(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      cropArea: (json['cropArea'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      rotation: json['rotation'] as int? ?? 0,
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
      contrast: (json['contrast'] as num?)?.toDouble() ?? 1.0,
      filters: (json['filters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Creates a [ScannedPageModel] from a Hive box entry.
  factory ScannedPageModel.fromHive(Map<dynamic, dynamic> map) {
    return ScannedPageModel(
      id: map['id'] as String,
      filePath: map['filePath'] as String,
      cropArea: (map['cropArea'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      rotation: map['rotation'] as int? ?? 0,
      brightness: (map['brightness'] as num?)?.toDouble() ?? 0.0,
      contrast: (map['contrast'] as num?)?.toDouble() ?? 1.0,
      filters: (map['filters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'cropArea': cropArea,
      'rotation': rotation,
      'brightness': brightness,
      'contrast': contrast,
      'filters': filters,
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'filePath': filePath,
      'cropArea': cropArea,
      'rotation': rotation,
      'brightness': brightness,
      'contrast': contrast,
      'filters': filters,
    };
  }

  /// Converts this model back to a domain [ScannedPage] entity.
  ScannedPage toEntity() {
    return ScannedPage(
      id: id,
      filePath: filePath,
      cropArea: cropArea,
      rotation: rotation,
      brightness: brightness,
      contrast: contrast,
      filters: filters,
    );
  }
}

/// Data model for [ScannedDocument], extending the domain entity with
/// JSON and Hive serialization support.
class ScannedDocumentModel extends ScannedDocument {
  const ScannedDocumentModel({
    required super.id,
    required super.filePath,
    required super.createdAt,
    required super.updatedAt,
    required super.name,
    super.thumbnailPath,
    super.pages = const [],
    super.tags = const [],
    super.isFavorite = false,
    super.folderId,
    super.fileSize = 0,
    super.ocrText,
    super.pdfPath,
    super.isSynced = false,
    super.isLocked = false,
  });

  /// Creates a [ScannedDocumentModel] from a domain [ScannedDocument] entity.
  factory ScannedDocumentModel.fromEntity(ScannedDocument entity) {
    return ScannedDocumentModel(
      id: entity.id,
      filePath: entity.filePath,
      thumbnailPath: entity.thumbnailPath,
      pages: entity.pages,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      name: entity.name,
      tags: entity.tags,
      isFavorite: entity.isFavorite,
      folderId: entity.folderId,
      fileSize: entity.fileSize,
      ocrText: entity.ocrText,
      pdfPath: entity.pdfPath,
      isSynced: entity.isSynced,
      isLocked: entity.isLocked,
    );
  }

  /// Creates a [ScannedDocumentModel] from a JSON map.
  factory ScannedDocumentModel.fromJson(Map<String, dynamic> json) {
    return ScannedDocumentModel(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      pages: (json['pages'] as List<dynamic>?)
              ?.map((e) => ScannedPageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      name: json['name'] as String,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      folderId: json['folderId'] as String?,
      fileSize: json['fileSize'] as int? ?? 0,
      ocrText: json['ocrText'] as String?,
      pdfPath: json['pdfPath'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }

  /// Creates a [ScannedDocumentModel] from a Hive box entry.
  factory ScannedDocumentModel.fromHive(Map<dynamic, dynamic> map) {
    // Pages may be stored as a JSON-encoded string in Hive.
    List<ScannedPage> parsePages(dynamic pagesData) {
      if (pagesData == null) return [];
      if (pagesData is String) {
        final decoded = jsonDecode(pagesData) as List<dynamic>;
        return decoded
            .map((e) => ScannedPageModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (pagesData is List) {
        return pagesData
            .map((e) {
              if (e is Map<String, dynamic>) {
                return ScannedPageModel.fromJson(e);
              }
              if (e is Map) {
                return ScannedPageModel.fromHive(e);
              }
              return null;
            })
            .whereType<ScannedPage>()
            .toList();
      }
      return [];
    }

    return ScannedDocumentModel(
      id: map['id'] as String,
      filePath: map['filePath'] as String,
      thumbnailPath: map['thumbnailPath'] as String?,
      pages: parsePages(map['pages']),
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] is String
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      name: map['name'] as String,
      tags: (map['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isFavorite: map['isFavorite'] as bool? ?? false,
      folderId: map['folderId'] as String?,
      fileSize: map['fileSize'] as int? ?? 0,
      ocrText: map['ocrText'] as String?,
      pdfPath: map['pdfPath'] as String?,
      isSynced: map['isSynced'] as bool? ?? false,
      isLocked: map['isLocked'] as bool? ?? false,
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'thumbnailPath': thumbnailPath,
      'pages': pages
          .map((p) => ScannedPageModel.fromEntity(p).toJson())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'name': name,
      'tags': tags,
      'isFavorite': isFavorite,
      'folderId': folderId,
      'fileSize': fileSize,
      'ocrText': ocrText,
      'pdfPath': pdfPath,
      'isSynced': isSynced,
      'isLocked': isLocked,
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'filePath': filePath,
      'thumbnailPath': thumbnailPath,
      'pages': jsonEncode(
        pages.map((p) => ScannedPageModel.fromEntity(p).toJson()).toList(),
      ),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'name': name,
      'tags': tags,
      'isFavorite': isFavorite,
      'folderId': folderId,
      'fileSize': fileSize,
      'ocrText': ocrText,
      'pdfPath': pdfPath,
      'isSynced': isSynced,
      'isLocked': isLocked,
    };
  }

  /// Converts this model back to a domain [ScannedDocument] entity.
  ScannedDocument toEntity() {
    return ScannedDocument(
      id: id,
      filePath: filePath,
      thumbnailPath: thumbnailPath,
      pages: pages,
      createdAt: createdAt,
      updatedAt: updatedAt,
      name: name,
      tags: tags,
      isFavorite: isFavorite,
      folderId: folderId,
      fileSize: fileSize,
      ocrText: ocrText,
      pdfPath: pdfPath,
      isSynced: isSynced,
      isLocked: isLocked,
    );
  }
}
