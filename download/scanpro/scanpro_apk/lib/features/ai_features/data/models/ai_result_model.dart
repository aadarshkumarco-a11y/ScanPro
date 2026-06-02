import 'dart:convert';

import 'package:scanpro/features/ai_features/domain/entities/ai_result.dart';

/// Data model for [AiResult], extending the domain entity with
/// JSON and Hive serialization support.
class AiResultModel extends AiResult {
  const AiResultModel({
    required super.id,
    required super.type,
    required super.inputText,
    required super.resultText,
    required super.createdAt,
    super.metadata = const {},
  });

  /// Creates an [AiResultModel] from a domain [AiResult] entity.
  factory AiResultModel.fromEntity(AiResult entity) {
    return AiResultModel(
      id: entity.id,
      type: entity.type,
      inputText: entity.inputText,
      resultText: entity.resultText,
      createdAt: entity.createdAt,
      metadata: entity.metadata,
    );
  }

  /// Creates an [AiResultModel] from a JSON map.
  factory AiResultModel.fromJson(Map<String, dynamic> json) {
    return AiResultModel(
      id: json['id'] as String,
      type: AiFeatureType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AiFeatureType.summary,
      ),
      inputText: json['inputText'] as String? ?? '',
      resultText: json['resultText'] as String? ?? '',
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
    );
  }

  /// Creates an [AiResultModel] from a Hive box entry.
  factory AiResultModel.fromHive(Map<dynamic, dynamic> map) {
    Map<String, dynamic> parseMetadata(dynamic data) {
      if (data == null) return {};
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {}
        return {};
      }
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    }

    return AiResultModel(
      id: map['id'] as String,
      type: AiFeatureType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AiFeatureType.summary,
      ),
      inputText: map['inputText'] as String? ?? '',
      resultText: map['resultText'] as String? ?? '',
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : map['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
              : DateTime.now(),
      metadata: parseMetadata(map['metadata']),
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'inputText': inputText,
      'resultText': resultText,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'type': type.name,
      'inputText': inputText,
      'resultText': resultText,
      'createdAt': createdAt.toIso8601String(),
      'metadata': jsonEncode(metadata),
    };
  }

  /// Converts this model back to a domain [AiResult] entity.
  @override
  AiResult toEntity() {
    return AiResult(
      id: id,
      type: type,
      inputText: inputText,
      resultText: resultText,
      createdAt: createdAt,
      metadata: metadata,
    );
  }
}
