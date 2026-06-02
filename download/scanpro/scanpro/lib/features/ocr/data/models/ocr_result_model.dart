import 'package:hive/hive.dart';
import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';

part 'ocr_result_model.g.dart';

/// Hive-compatible data model for [SmartAction].
@HiveType(typeId: 20)
class SmartActionModel extends HiveObject {
  /// Smart action type index.
  @HiveField(0)
  final int typeIndex;

  /// Detected value string.
  @HiveField(1)
  final String value;

  /// Start index in original text.
  @HiveField(2)
  final int startIndex;

  /// End index in original text.
  @HiveField(3)
  final int endIndex;

  SmartActionModel({
    required this.typeIndex,
    required this.value,
    required this.startIndex,
    required this.endIndex,
  });

  /// Creates a model from a domain entity.
  factory SmartActionModel.fromEntity(SmartAction entity) {
    return SmartActionModel(
      typeIndex: entity.type.index,
      value: entity.value,
      startIndex: entity.startIndex,
      endIndex: entity.endIndex,
    );
  }

  /// Converts to domain entity.
  SmartAction toEntity() {
    return SmartAction(
      type: SmartActionType.values[typeIndex.clamp(
        0,
        SmartActionType.values.length - 1,
      )],
      value: value,
      startIndex: startIndex,
      endIndex: endIndex,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'typeIndex': typeIndex,
      'value': value,
      'startIndex': startIndex,
      'endIndex': endIndex,
    };
  }

  /// Creates from JSON map.
  factory SmartActionModel.fromJson(Map<String, dynamic> json) {
    return SmartActionModel(
      typeIndex: json['typeIndex'] as int,
      value: json['value'] as String,
      startIndex: json['startIndex'] as int,
      endIndex: json['endIndex'] as int,
    );
  }
}

/// Hive-compatible data model for [OCRResult].
///
/// Provides serialization/deserialization for local storage with Hive,
/// and conversion methods between the domain entity and data model.
@HiveType(typeId: 4)
class OCRResultModel extends HiveObject {
  /// Unique identifier.
  @HiveField(0)
  final String id;

  /// ID of the parent document.
  @HiveField(1)
  final String documentId;

  /// Full extracted text.
  @HiveField(2)
  final String text;

  /// Detected language code.
  @HiveField(3)
  final String language;

  /// Overall confidence score.
  @HiveField(4)
  final double confidence;

  /// List of paragraphs.
  @HiveField(5)
  final List<String> paragraphs;

  /// Smart actions as JSON-serializable list.
  @HiveField(6)
  final List<Map> smartActionsRaw;

  /// Creation timestamp as ISO 8601 string.
  @HiveField(7)
  final String createdAt;

  OCRResultModel({
    required this.id,
    required this.documentId,
    required this.text,
    this.language = 'en',
    this.confidence = 0.0,
    this.paragraphs = const [],
    this.smartActionsRaw = const [],
    required this.createdAt,
  });

  /// Creates a model from a domain entity.
  factory OCRResultModel.fromEntity(OCRResult entity) {
    return OCRResultModel(
      id: entity.id,
      documentId: entity.documentId,
      text: entity.text,
      language: entity.language,
      confidence: entity.confidence,
      paragraphs: entity.paragraphs,
      smartActionsRaw: entity.smartActions
          .map((a) => SmartActionModel.fromEntity(a).toJson())
          .toList(),
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  /// Converts this model to a domain entity.
  OCRResult toEntity() {
    final actions = smartActionsRaw.map((raw) {
      return SmartActionModel.fromJson(
        Map<String, dynamic>.from(raw as Map),
      ).toEntity();
    }).toList();

    return OCRResult(
      id: id,
      documentId: documentId,
      text: text,
      language: language,
      confidence: confidence,
      paragraphs: paragraphs,
      smartActions: actions,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'text': text,
      'language': language,
      'confidence': confidence,
      'paragraphs': paragraphs,
      'smartActionsRaw': smartActionsRaw,
      'createdAt': createdAt,
    };
  }

  /// Creates a model from a JSON map.
  factory OCRResultModel.fromJson(Map<String, dynamic> json) {
    return OCRResultModel(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      text: json['text'] as String,
      language: json['language'] as String? ?? 'en',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      paragraphs: (json['paragraphs'] as List<dynamic>).cast<String>(),
      smartActionsRaw: (json['smartActionsRaw'] as List<dynamic>)
          .cast<Map>(),
      createdAt: json['createdAt'] as String,
    );
  }
}
