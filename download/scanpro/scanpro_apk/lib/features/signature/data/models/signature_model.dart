import 'dart:convert';

import 'package:scanpro/features/signature/domain/entities/signature.dart';

/// Data model for [Signature], extending the domain entity with
/// JSON and Hive serialization support.
class SignatureModel extends Signature {
  const SignatureModel({
    required super.id,
    required super.name,
    required super.imageData,
    required super.createdAt,
    super.isDefault = false,
  });

  /// Creates a [SignatureModel] from a domain [Signature] entity.
  factory SignatureModel.fromEntity(Signature entity) {
    return SignatureModel(
      id: entity.id,
      name: entity.name,
      imageData: entity.imageData,
      createdAt: entity.createdAt,
      isDefault: entity.isDefault,
    );
  }

  /// Creates a [SignatureModel] from a JSON map.
  factory SignatureModel.fromJson(Map<String, dynamic> json) {
    return SignatureModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageData: json['imageData'] as String,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  /// Creates a [SignatureModel] from a Hive box entry.
  factory SignatureModel.fromHive(Map<dynamic, dynamic> map) {
    return SignatureModel(
      id: map['id'] as String,
      name: map['name'] as String,
      imageData: map['imageData'] as String,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : map['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
              : DateTime.now(),
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageData': imageData,
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'name': name,
      'imageData': imageData,
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  /// Converts this model back to a domain [Signature] entity.
  @override
  Signature toEntity() {
    return Signature(
      id: id,
      name: name,
      imageData: imageData,
      createdAt: createdAt,
      isDefault: isDefault,
    );
  }
}
