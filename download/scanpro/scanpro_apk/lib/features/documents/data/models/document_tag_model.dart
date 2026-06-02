import 'package:scanpro/features/documents/domain/entities/document_tag.dart';

/// Data model for [DocumentTag], extending the domain entity with
/// JSON and Hive serialization support.
class DocumentTagModel extends DocumentTag {
  const DocumentTagModel({
    required super.id,
    required super.name,
    super.color,
    super.usageCount = 0,
    super.createdAt,
  });

  /// Creates a [DocumentTagModel] from a domain [DocumentTag] entity.
  factory DocumentTagModel.fromEntity(DocumentTag entity) {
    return DocumentTagModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      usageCount: entity.usageCount,
      createdAt: entity.createdAt,
    );
  }

  /// Creates a [DocumentTagModel] from a JSON map.
  factory DocumentTagModel.fromJson(Map<String, dynamic> json) {
    return DocumentTagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      usageCount: json['usageCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int))
          : null,
    );
  }

  /// Creates a [DocumentTagModel] from a Hive box entry.
  factory DocumentTagModel.fromHive(Map<dynamic, dynamic> map) {
    return DocumentTagModel(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as String?,
      usageCount: map['usageCount'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
              ? DateTime.parse(map['createdAt'] as String)
              : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int))
          : null,
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'usageCount': usageCount,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'usageCount': usageCount,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Converts this model back to a domain [DocumentTag] entity.
  DocumentTag toEntity() {
    return DocumentTag(
      id: id,
      name: name,
      color: color,
      usageCount: usageCount,
      createdAt: createdAt,
    );
  }
}
