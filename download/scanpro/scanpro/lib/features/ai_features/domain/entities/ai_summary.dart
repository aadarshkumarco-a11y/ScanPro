import 'package:equatable/equatable.dart';

/// Entity representing an AI-generated document summary.
///
/// Contains the summary text, extracted key points, category
/// classification, suggested tags, and a confidence score.
class AISummary extends Equatable {
  /// Unique identifier for this summary.
  final String id;

  /// ID of the document this summary belongs to.
  final String documentId;

  /// Generated summary text.
  final String summary;

  /// Key points extracted from the document.
  final List<String> keyPoints;

  /// Category classification (e.g., 'invoice', 'receipt', 'contract').
  final String category;

  /// Tags suggested by the AI based on document content.
  final List<String> suggestedTags;

  /// Confidence score of the AI analysis (0.0–1.0).
  final double confidence;

  /// Timestamp when the summary was generated.
  final DateTime createdAt;

  const AISummary({
    required this.id,
    required this.documentId,
    required this.summary,
    this.keyPoints = const [],
    this.category = 'uncategorized',
    this.suggestedTags = const [],
    this.confidence = 0.0,
    required this.createdAt,
  });

  /// Whether the AI has high confidence in this summary.
  bool get isHighConfidence => confidence >= 0.8;

  /// Creates a copy with optional field overrides.
  AISummary copyWith({
    String? id,
    String? documentId,
    String? summary,
    List<String>? keyPoints,
    String? category,
    List<String>? suggestedTags,
    double? confidence,
    DateTime? createdAt,
  }) {
    return AISummary(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      summary: summary ?? this.summary,
      keyPoints: keyPoints ?? this.keyPoints,
      category: category ?? this.category,
      suggestedTags: suggestedTags ?? this.suggestedTags,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        summary,
        keyPoints,
        category,
        suggestedTags,
        confidence,
        createdAt,
      ];
}
