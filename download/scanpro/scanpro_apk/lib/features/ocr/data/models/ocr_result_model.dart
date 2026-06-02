import 'dart:convert';

import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';

/// Data model for [TextBlock], extending the domain entity with
/// JSON and Hive serialization support.
class TextBlockModel extends TextBlock {
  const TextBlockModel({
    required super.text,
    required super.boundingBox,
    super.confidence = 0.0,
    super.blockType = 'paragraph',
  });

  /// Creates a [TextBlockModel] from a domain [TextBlock] entity.
  factory TextBlockModel.fromEntity(TextBlock entity) {
    return TextBlockModel(
      text: entity.text,
      boundingBox: entity.boundingBox,
      confidence: entity.confidence,
      blockType: entity.blockType,
    );
  }

  /// Creates a [TextBlockModel] from a JSON map.
  factory TextBlockModel.fromJson(Map<String, dynamic> json) {
    return TextBlockModel(
      text: json['text'] as String? ?? '',
      boundingBox: (json['boundingBox'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      blockType: json['blockType'] as String? ?? 'paragraph',
    );
  }

  /// Creates a [TextBlockModel] from a Hive box entry.
  factory TextBlockModel.fromHive(Map<dynamic, dynamic> map) {
    return TextBlockModel(
      text: map['text'] as String? ?? '',
      boundingBox: (map['boundingBox'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      blockType: map['blockType'] as String? ?? 'paragraph',
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'boundingBox': boundingBox,
      'confidence': confidence,
      'blockType': blockType,
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'text': text,
      'boundingBox': boundingBox,
      'confidence': confidence,
      'blockType': blockType,
    };
  }

  /// Converts this model back to a domain [TextBlock] entity.
  TextBlock toEntity() {
    return TextBlock(
      text: text,
      boundingBox: boundingBox,
      confidence: confidence,
      blockType: blockType,
    );
  }
}

/// Data model for [OcrResult], extending the domain entity with
/// JSON and Hive serialization support.
class OcrResultModel extends OcrResult {
  const OcrResultModel({
    required super.id,
    required super.documentId,
    required super.text,
    super.blocks = const [],
    super.language = 'en',
    super.confidence = 0.0,
    required super.createdAt,
  });

  /// Creates an [OcrResultModel] from a domain [OcrResult] entity.
  factory OcrResultModel.fromEntity(OcrResult entity) {
    return OcrResultModel(
      id: entity.id,
      documentId: entity.documentId,
      text: entity.text,
      blocks: entity.blocks,
      language: entity.language,
      confidence: entity.confidence,
      createdAt: entity.createdAt,
    );
  }

  /// Creates an [OcrResultModel] from a JSON map.
  factory OcrResultModel.fromJson(Map<String, dynamic> json) {
    return OcrResultModel(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      text: json['text'] as String,
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((e) =>
                  TextBlockModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      language: json['language'] as String? ?? 'en',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Creates an [OcrResultModel] from a Hive box entry.
  factory OcrResultModel.fromHive(Map<dynamic, dynamic> map) {
    // Blocks may be stored as a JSON-encoded string in Hive.
    List<TextBlock> parseBlocks(dynamic blocksData) {
      if (blocksData == null) return [];
      if (blocksData is String) {
        final decoded = jsonDecode(blocksData) as List<dynamic>;
        return decoded
            .map((e) =>
                TextBlockModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (blocksData is List) {
        return blocksData
            .map((e) {
              if (e is Map<String, dynamic>) {
                return TextBlockModel.fromJson(e);
              }
              if (e is Map) {
                return TextBlockModel.fromHive(e);
              }
              return null;
            })
            .whereType<TextBlock>()
            .toList();
      }
      return [];
    }

    return OcrResultModel(
      id: map['id'] as String,
      documentId: map['documentId'] as String,
      text: map['text'] as String,
      blocks: parseBlocks(map['blocks']),
      language: map['language'] as String? ?? 'en',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'text': text,
      'blocks': blocks
          .map((b) => TextBlockModel.fromEntity(b).toJson())
          .toList(),
      'language': language,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'documentId': documentId,
      'text': text,
      'blocks': jsonEncode(
        blocks.map((b) => TextBlockModel.fromEntity(b).toJson()).toList(),
      ),
      'language': language,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Converts this model back to a domain [OcrResult] entity.
  OcrResult toEntity() {
    return OcrResult(
      id: id,
      documentId: documentId,
      text: text,
      blocks: blocks,
      language: language,
      confidence: confidence,
      createdAt: createdAt,
    );
  }
}
