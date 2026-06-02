import 'package:equatable/equatable.dart';

/// Represents a detected text block within an OCR result.
///
/// Each [TextBlock] contains the recognized text, its bounding box
/// coordinates, confidence score, and the type of block detected
/// (paragraph, line, word, etc.).
class TextBlock extends Equatable {
  const TextBlock({
    required this.text,
    required this.boundingBox,
    this.confidence = 0.0,
    this.blockType = 'paragraph',
  });

  /// The recognized text content of this block.
  final String text;

  /// Bounding box as [left, top, right, bottom] in normalised coordinates.
  final List<double> boundingBox;

  /// Confidence score between 0.0 and 1.0.
  final double confidence;

  /// Type of text block (e.g. 'paragraph', 'line', 'word', 'table').
  final String blockType;

  /// Creates a copy with optional field overrides.
  TextBlock copyWith({
    String? text,
    List<double>? boundingBox,
    double? confidence,
    String? blockType,
  }) {
    return TextBlock(
      text: text ?? this.text,
      boundingBox: boundingBox ?? this.boundingBox,
      confidence: confidence ?? this.confidence,
      blockType: blockType ?? this.blockType,
    );
  }

  @override
  List<Object?> get props => [text, boundingBox, confidence, blockType];
}

/// Domain entity representing the result of an OCR operation.
///
/// Contains the full recognized text, individual text blocks with
/// position information, the detected language, and an overall
/// confidence score.
class OcrResult extends Equatable {
  const OcrResult({
    required this.id,
    required this.documentId,
    required this.text,
    this.blocks = const [],
    this.language = 'en',
    this.confidence = 0.0,
    required this.createdAt,
  });

  /// Unique identifier for this OCR result.
  final String id;

  /// ID of the source document this OCR was performed on.
  final String documentId;

  /// The full recognized text concatenated from all blocks.
  final String text;

  /// Individual text blocks detected during OCR.
  final List<TextBlock> blocks;

  /// Detected or selected language code (e.g. 'en', 'es', 'fr').
  final String language;

  /// Overall confidence score between 0.0 and 1.0.
  final double confidence;

  /// Timestamp when this OCR result was created.
  final DateTime createdAt;

  /// Whether the confidence exceeds the minimum threshold.
  bool get isHighConfidence =>
      confidence >= 0.7;

  /// Word count of the recognized text.
  int get wordCount =>
      text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

  /// Character count of the recognized text.
  int get characterCount => text.length;

  /// Creates a copy with optional field overrides.
  OcrResult copyWith({
    String? id,
    String? documentId,
    String? text,
    List<TextBlock>? blocks,
    String? language,
    double? confidence,
    DateTime? createdAt,
  }) {
    return OcrResult(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      text: text ?? this.text,
      blocks: blocks ?? this.blocks,
      language: language ?? this.language,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        text,
        blocks,
        language,
        confidence,
        createdAt,
      ];
}
