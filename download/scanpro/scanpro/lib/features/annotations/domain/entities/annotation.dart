import 'package:equatable/equatable.dart';

/// Enumeration of supported annotation types.
enum AnnotationType {
  /// Text highlight annotation.
  highlight,

  /// Text underline annotation.
  underline,

  /// Freehand drawing annotation.
  draw,

  /// Geometric shape annotation (rectangle, circle, arrow).
  shape,

  /// Sticky note / comment annotation.
  note,

  /// Inline text annotation.
  text,
}

/// Enumeration of supported shape types for shape annotations.
enum ShapeType {
  /// Rectangle shape.
  rectangle,

  /// Circle / ellipse shape.
  circle,

  /// Arrow pointing from start to end.
  arrow,

  /// Straight line.
  line,
}

/// Entity representing an annotation on a document page.
///
/// Annotations can be highlights, underlines, drawings, shapes,
/// notes, or text overlays, each with type-specific data.
class Annotation extends Equatable {
  /// Unique identifier for this annotation.
  final String id;

  /// ID of the document this annotation belongs to.
  final String documentId;

  /// Zero-based page index where the annotation is placed.
  final int pageIndex;

  /// Type of the annotation.
  final AnnotationType type;

  /// Type-specific data for the annotation.
  ///
  /// For [AnnotationType.draw]: list of stroke points as
  /// `[{x, y, pressure}]` maps.
  /// For [AnnotationType.shape]: `{shapeType, startX, startY, endX, endY}`.
  /// For [AnnotationType.text]: `{content, fontSize}`.
  /// For [AnnotationType.note]: `{content}`.
  /// For [AnnotationType.highlight]/[AnnotationType.underline]:
  /// `{startOffset, endOffset, text}`.
  final Map<String, dynamic> data;

  /// Color hex code for the annotation (e.g., '#FFFF00' for yellow).
  final String color;

  /// Position of the annotation on the page.
  ///
  /// Stored as `{x, y, width, height}` in normalized coordinates (0.0–1.0).
  final Map<String, double> position;

  /// Timestamp when the annotation was created.
  final DateTime createdAt;

  const Annotation({
    required this.id,
    required this.documentId,
    required this.pageIndex,
    required this.type,
    this.data = const {},
    this.color = '#FFFF00',
    this.position = const {},
    required this.createdAt,
  });

  /// X position on the page (normalized 0.0–1.0).
  double get x => position['x'] ?? 0.0;

  /// Y position on the page (normalized 0.0–1.0).
  double get y => position['y'] ?? 0.0;

  /// Width of the annotation (normalized 0.0–1.0).
  double get width => position['width'] ?? 0.0;

  /// Height of the annotation (normalized 0.0–1.0).
  double get height => position['height'] ?? 0.0;

  /// Creates a copy with optional field overrides.
  Annotation copyWith({
    String? id,
    String? documentId,
    int? pageIndex,
    AnnotationType? type,
    Map<String, dynamic>? data,
    String? color,
    Map<String, double>? position,
    DateTime? createdAt,
  }) {
    return Annotation(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      pageIndex: pageIndex ?? this.pageIndex,
      type: type ?? this.type,
      data: data ?? this.data,
      color: color ?? this.color,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        pageIndex,
        type,
        data,
        color,
        position,
        createdAt,
      ];
}
