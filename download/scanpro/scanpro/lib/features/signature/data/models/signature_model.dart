import 'package:hive/hive.dart';
import 'package:scanpro/features/signature/domain/entities/signature.dart';

part 'signature_model.g.dart';

/// Hive-compatible data model for [Signature].
///
/// Provides serialization/deserialization for local storage with Hive,
/// and conversion methods between the domain entity and data model.
@HiveType(typeId: 9)
class SignatureModel extends HiveObject {
  /// Unique identifier.
  @HiveField(0)
  final String id;

  /// Display name.
  @HiveField(1)
  final String name;

  /// Base64-encoded PNG image data.
  @HiveField(2)
  final String imageData;

  /// Creation timestamp as ISO 8601 string.
  @HiveField(3)
  final String createdAt;

  /// Last update timestamp as ISO 8601 string.
  @HiveField(4)
  final String updatedAt;

  SignatureModel({
    required this.id,
    required this.name,
    required this.imageData,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a model from a domain entity.
  factory SignatureModel.fromEntity(Signature entity) {
    return SignatureModel(
      id: entity.id,
      name: entity.name,
      imageData: entity.imageData,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  /// Converts this model to a domain entity.
  Signature toEntity() {
    return Signature(
      id: id,
      name: name,
      imageData: imageData,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageData': imageData,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a model from a JSON map.
  factory SignatureModel.fromJson(Map<String, dynamic> json) {
    return SignatureModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageData: json['imageData'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
