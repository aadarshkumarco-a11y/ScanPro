import 'package:hive/hive.dart';
import 'package:scanpro/features/documents/domain/entities/tag.dart';

part 'tag_model.g.dart';

/// Hive-compatible data model for [Tag].
///
/// Provides serialization/deserialization for local storage with Hive,
/// and conversion methods between the domain entity and data model.
@HiveType(typeId: 3)
class TagModel extends HiveObject {
  /// Unique identifier.
  @HiveField(0)
  final String id;

  /// Display name.
  @HiveField(1)
  final String name;

  /// Color hex code.
  @HiveField(2)
  final String color;

  /// Number of documents using this tag.
  @HiveField(3)
  final int usageCount;

  /// Creation timestamp as ISO 8601 string.
  @HiveField(4)
  final String createdAt;

  TagModel({
    required this.id,
    required this.name,
    this.color = '#4CAF50',
    this.usageCount = 0,
    required this.createdAt,
  });

  /// Creates a model from a domain entity.
  factory TagModel.fromEntity(Tag entity) {
    return TagModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      usageCount: entity.usageCount,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  /// Converts this model to a domain entity.
  Tag toEntity() {
    return Tag(
      id: id,
      name: name,
      color: color,
      usageCount: usageCount,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Converts this model to a JSON-compatible map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'usageCount': usageCount,
      'createdAt': createdAt,
    };
  }

  /// Creates a model from a JSON map.
  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String? ?? '#4CAF50',
      usageCount: json['usageCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String,
    );
  }
}
