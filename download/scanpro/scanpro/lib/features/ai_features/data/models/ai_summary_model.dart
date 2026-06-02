import 'package:hive/hive.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_summary.dart';

part 'ai_summary_model.g.dart';

/// Hive-compatible data model for [AISummary].
///
/// Provides serialization/deserialization for local storage with Hive,
/// and conversion methods between the domain entity and data model.
@HiveType(typeId: 8)
class AISummaryModel extends HiveObject {
  /// Unique identifier.
  @HiveField(0)
  final String id;

  /// ID of the parent document.
  @HiveField(1)
  final String documentId;

  /// Generated summary text.
  @HiveField(2)
  final String summary;

  /// Key points extracted from the document.
  @HiveField(3)
  final List<String> keyPoints;

  /// Category classification.
  @HiveField(4)
  final String category;

  /// Suggested tags.
  @HiveField(5)
  final List<String> suggestedTags;

  /// Confidence score.
  @HiveField(6)
  final double confidence;

  /// Creation timestamp as ISO 8601 string.
  @HiveField(7)
  final String createdAt;

  AISummaryModel({
    required this.id,
    required this.documentId,
    required this.summary,
    this.keyPoints = const [],
    this.category = 'uncategorized',
    this.suggestedTags = const [],
    this.confidence = 0.0,
    required this.createdAt,
  });

  /// Creates a model from a domain entity.
  factory AISummaryModel.fromEntity(AISummary entity) {
    return AISummaryModel(
      id: entity.id,
      documentId: entity.documentId,
      summary: entity.summary,
      keyPoints: entity.keyPoints,
      category: entity.category,
      suggestedTags: entity.suggestedTags,
      confidence: entity.confidence,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  /// Converts this model to a domain entity.
  AISummary toEntity() {
    return AISummary(
      id: id,
      documentId: documentId,
      summary: summary,
      keyPoints: keyPoints,
      category: category,
      suggestedTags: suggestedTags,
      confidence: confidence,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'summary': summary,
      'keyPoints': keyPoints,
      'category': category,
      'suggestedTags': suggestedTags,
      'confidence': confidence,
      'createdAt': createdAt,
    };
  }

  /// Creates a model from a JSON map.
  factory AISummaryModel.fromJson(Map<String, dynamic> json) {
    return AISummaryModel(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      summary: json['summary'] as String,
      keyPoints: (json['keyPoints'] as List<dynamic>).cast<String>(),
      category: json['category'] as String? ?? 'uncategorized',
      suggestedTags: (json['suggestedTags'] as List<dynamic>).cast<String>(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] as String,
    );
  }
}
