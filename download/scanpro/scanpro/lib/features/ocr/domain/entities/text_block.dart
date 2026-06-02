import 'package:equatable/equatable.dart';

/// Enumeration of text block types detected during OCR.
enum TextBlockType {
  /// Regular body text.
  text,

  /// Heading or title text.
  heading,

  /// List item text.
  listItem,

  /// Numbered list item.
  numberedItem,

  /// Table cell content.
  tableCell,

  /// Caption or footnote.
  caption,
}

/// Entity representing a single block of detected text within a document.
///
/// Each text block contains the recognized text, its bounding box,
/// confidence score, and classification type for structure analysis.
class TextBlock extends Equatable {
  /// The recognized text content of this block.
  final String text;

  /// Bounding box of the text block as normalized rectangle.
  /// Stored as [left, top, right, bottom] in 0.0–1.0 range.
  final List<double> boundingBox;

  /// Confidence score for this text recognition (0.0–1.0).
  final double confidence;

  /// Classification type of this text block.
  final TextBlockType type;

  const TextBlock({
    required this.text,
    required this.boundingBox,
    this.confidence = 0.0,
    this.type = TextBlockType.text,
  });

  /// Left coordinate of the bounding box.
  double get left => boundingBox.isNotEmpty ? boundingBox[0] : 0.0;

  /// Top coordinate of the bounding box.
  double get top => boundingBox.length > 1 ? boundingBox[1] : 0.0;

  /// Right coordinate of the bounding box.
  double get right => boundingBox.length > 2 ? boundingBox[2] : 1.0;

  /// Bottom coordinate of the bounding box.
  double get bottom => boundingBox.length > 3 ? boundingBox[3] : 1.0;

  /// Width of the bounding box.
  double get width => right - left;

  /// Height of the bounding box.
  double get height => bottom - top;

  /// Whether the confidence score indicates reliable recognition.
  bool get isReliable => confidence >= 0.7;

  @override
  List<Object?> get props => [text, boundingBox, confidence, type];
}
