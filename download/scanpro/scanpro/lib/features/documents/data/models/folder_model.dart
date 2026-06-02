import 'package:hive/hive.dart';
import 'package:scanpro/features/documents/domain/entities/folder.dart';

part 'folder_model.g.dart';

/// Hive-compatible data model for [Folder].
///
/// Provides serialization/deserialization for local storage with Hive,
/// and conversion methods between the domain entity and data model.
@HiveType(typeId: 2)
class FolderModel extends HiveObject {
  /// Unique identifier.
  @HiveField(0)
  final String id;

  /// Display name.
  @HiveField(1)
  final String name;

  /// ID of the parent folder.
  @HiveField(2)
  final String? parentId;

  /// Color hex code.
  @HiveField(3)
  final String color;

  /// Icon identifier.
  @HiveField(4)
  final String icon;

  /// Document count.
  @HiveField(5)
  final int documentCount;

  /// Creation timestamp as ISO 8601 string.
  @HiveField(6)
  final String createdAt;

  /// Last update timestamp as ISO 8601 string.
  @HiveField(7)
  final String updatedAt;

  FolderModel({
    required this.id,
    required this.name,
    this.parentId,
    this.color = '#2196F3',
    this.icon = 'folder',
    this.documentCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a model from a domain entity.
  factory FolderModel.fromEntity(Folder entity) {
    return FolderModel(
      id: entity.id,
      name: entity.name,
      parentId: entity.parentId,
      color: entity.color,
      icon: entity.icon,
      documentCount: entity.documentCount,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  /// Converts this model to a domain entity.
  Folder toEntity() {
    return Folder(
      id: id,
      name: name,
      parentId: parentId,
      color: color,
      icon: icon,
      documentCount: documentCount,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Converts this model to a JSON-compatible map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'color': color,
      'icon': icon,
      'documentCount': documentCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a model from a JSON map.
  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      color: json['color'] as String? ?? '#2196F3',
      icon: json['icon'] as String? ?? 'folder',
      documentCount: json['documentCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
