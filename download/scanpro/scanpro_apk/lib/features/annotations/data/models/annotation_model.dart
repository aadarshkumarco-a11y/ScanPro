import 'dart:convert';

import 'package:scanpro/features/annotations/domain/entities/annotation.dart';

/// Data model for [Annotation], extending the domain entity with
/// JSON and Hive serialization support.
class AnnotationModel extends Annotation {
  const AnnotationModel({
    required super.id,
    required super.documentId,
    required super.page,
    required super.type,
    required super.data,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates an [AnnotationModel] from a domain [Annotation] entity.
  factory AnnotationModel.fromEntity(Annotation entity) {
    return AnnotationModel(
      id: entity.id,
      documentId: entity.documentId,
      page: entity.page,
      type: entity.type,
      data: Map<String, dynamic>.from(entity.data),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Creates an [AnnotationModel] from a JSON map.
  factory AnnotationModel.fromJson(Map<String, dynamic> json) {
    return AnnotationModel(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      page: json['page'] as int,
      type: _typeFromString(json['type'] as String),
      data: _parseDataMap(json['data']),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  /// Creates an [AnnotationModel] from a Hive box entry.
  factory AnnotationModel.fromHive(Map<dynamic, dynamic> map) {
    return AnnotationModel(
      id: map['id'] as String,
      documentId: map['documentId'] as String,
      page: map['page'] as int,
      type: _typeFromString(map['type'] as String),
      data: _parseDataMap(map['data']),
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : map['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
              : DateTime.now(),
      updatedAt: map['updatedAt'] is String
          ? DateTime.parse(map['updatedAt'] as String)
          : map['updatedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
              : DateTime.now(),
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'page': page,
      'type': _typeToString(type),
      'data': _encodeDataMap(data),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'documentId': documentId,
      'page': page,
      'type': _typeToString(type),
      'data': _encodeDataMap(data),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converts this model back to a domain [Annotation] entity.
  @override
  Annotation toEntity() {
    return Annotation(
      id: id,
      documentId: documentId,
      page: page,
      type: type,
      data: Map<String, dynamic>.from(data),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ── Private Helpers ──────────────────────────────────────────────

  /// Converts an [AnnotationType] to its string representation.
  static String _typeToString(AnnotationType type) {
    switch (type) {
      case AnnotationType.highlight:
        return 'highlight';
      case AnnotationType.draw:
        return 'draw';
      case AnnotationType.shape:
        return 'shape';
      case AnnotationType.note:
        return 'note';
      case AnnotationType.text:
        return 'text';
    }
  }

  /// Parses a string back to [AnnotationType].
  static AnnotationType _typeFromString(String value) {
    switch (value) {
      case 'highlight':
        return AnnotationType.highlight;
      case 'draw':
        return AnnotationType.draw;
      case 'shape':
        return AnnotationType.shape;
      case 'note':
        return AnnotationType.note;
      case 'text':
        return AnnotationType.text;
      default:
        return AnnotationType.note;
    }
  }

  /// Encodes the data map to a JSON-compatible format.
  ///
  /// Nested maps and lists are JSON-encoded as strings so they
  /// survive the Hive storage round-trip safely.
  static Map<String, dynamic> _encodeDataMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Map || value is List) {
        return MapEntry(key, jsonEncode(value));
      }
      return MapEntry(key, value);
    });
  }

  /// Parses a stored data map, decoding JSON strings back to
  /// their original types where applicable.
  static Map<String, dynamic> _parseDataMap(dynamic rawData) {
    if (rawData is String) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) return decoded;
        return <String, dynamic>{};
      } catch (_) {
        return <String, dynamic>{};
      }
    }

    if (rawData is Map) {
      final result = <String, dynamic>{};
      for (final entry in rawData.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is String) {
          try {
            final decoded = jsonDecode(value);
            result[key] = decoded;
          } catch (_) {
            result[key] = value;
          }
        } else {
          result[key] = value;
        }
      }
      return result;
    }

    return <String, dynamic>{};
  }
}
