import 'dart:convert';

import 'package:scanpro/features/documents/domain/entities/document_folder.dart';

/// Data model for [DocumentFolder], extending the domain entity with
/// JSON and Hive serialization support.
class DocumentFolderModel extends DocumentFolder {
  const DocumentFolderModel({
    required super.id,
    required super.name,
    required super.createdAt,
    super.color,
    super.icon,
    super.parentFolderId,
    super.documentCount = 0,
    super.isSynced = false,
  });

  /// Creates a [DocumentFolderModel] from a domain [DocumentFolder] entity.
  factory DocumentFolderModel.fromEntity(DocumentFolder entity) {
    return DocumentFolderModel(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
      color: entity.color,
      icon: entity.icon,
      parentFolderId: entity.parentFolderId,
      documentCount: entity.documentCount,
      isSynced: entity.isSynced,
    );
  }

  /// Creates a [DocumentFolderModel] from a JSON map.
  factory DocumentFolderModel.fromJson(Map<String, dynamic> json) {
    return DocumentFolderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      parentFolderId: json['parentFolderId'] as String?,
      documentCount: json['documentCount'] as int? ?? 0,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  /// Creates a [DocumentFolderModel] from a Hive box entry.
  factory DocumentFolderModel.fromHive(Map<dynamic, dynamic> map) {
    return DocumentFolderModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      color: map['color'] as String?,
      icon: map['icon'] as String?,
      parentFolderId: map['parentFolderId'] as String?,
      documentCount: map['documentCount'] as int? ?? 0,
      isSynced: map['isSynced'] as bool? ?? false,
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'color': color,
      'icon': icon,
      'parentFolderId': parentFolderId,
      'documentCount': documentCount,
      'isSynced': isSynced,
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'color': color,
      'icon': icon,
      'parentFolderId': parentFolderId,
      'documentCount': documentCount,
      'isSynced': isSynced,
    };
  }

  /// Converts this model back to a domain [DocumentFolder] entity.
  DocumentFolder toEntity() {
    return DocumentFolder(
      id: id,
      name: name,
      createdAt: createdAt,
      color: color,
      icon: icon,
      parentFolderId: parentFolderId,
      documentCount: documentCount,
      isSynced: isSynced,
    );
  }
}
