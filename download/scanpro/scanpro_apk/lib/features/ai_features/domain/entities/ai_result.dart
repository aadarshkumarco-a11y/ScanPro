import 'package:equatable/equatable.dart';

/// Enum representing the different AI feature types available in ScanPro.
enum AiFeatureType {
  summary,
  categorize,
  rename,
  extract,
  qa;

  /// Human-readable label for each feature type.
  String get label {
    switch (this) {
      case AiFeatureType.summary:
        return 'Summarize';
      case AiFeatureType.categorize:
        return 'Categorize';
      case AiFeatureType.rename:
        return 'Smart Rename';
      case AiFeatureType.extract:
        return 'Extract Key Info';
      case AiFeatureType.qa:
        return 'Ask Questions';
    }
  }

  /// Short description for each feature type.
  String get description {
    switch (this) {
      case AiFeatureType.summary:
        return 'Generate a concise summary of your document';
      case AiFeatureType.categorize:
        return 'Automatically categorize your document';
      case AiFeatureType.rename:
        return 'Get smart filename suggestions';
      case AiFeatureType.extract:
        return 'Extract key information and data points';
      case AiFeatureType.qa:
        return 'Ask questions about your document';
    }
  }

  /// Icon name for each feature type.
  String get iconName {
    switch (this) {
      case AiFeatureType.summary:
        return 'summarize';
      case AiFeatureType.categorize:
        return 'category';
      case AiFeatureType.rename:
        return 'drive_file_rename_outline';
      case AiFeatureType.extract:
        return 'data_object';
      case AiFeatureType.qa:
        return 'question_answer';
    }
  }
}

/// Domain entity representing the result of an AI operation.
///
/// Holds the input text, output text, feature type, creation
/// timestamp, and any additional metadata as a key-value map.
class AiResult extends Equatable {
  const AiResult({
    required this.id,
    required this.type,
    required this.inputText,
    required this.resultText,
    required this.createdAt,
    this.metadata = const {},
  });

  /// Unique identifier for this AI result.
  final String id;

  /// The type of AI feature that generated this result.
  final AiFeatureType type;

  /// The original text (or document reference) that was submitted.
  final String inputText;

  /// The AI-generated output text.
  final String resultText;

  /// When this result was created.
  final DateTime createdAt;

  /// Additional metadata key-value pairs (e.g. confidence, categories, tags).
  final Map<String, dynamic> metadata;

  /// Convenience getter for a confidence score stored in metadata.
  double? get confidence => metadata['confidence'] as double?;

  /// Whether this result has a high confidence score.
  bool get isHighConfidence => (confidence ?? 0.0) >= 0.7;

  /// Creates a copy with optional field overrides.
  AiResult copyWith({
    String? id,
    AiFeatureType? type,
    String? inputText,
    String? resultText,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return AiResult(
      id: id ?? this.id,
      type: type ?? this.type,
      inputText: inputText ?? this.inputText,
      resultText: resultText ?? this.resultText,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        inputText,
        resultText,
        createdAt,
        metadata,
      ];
}
