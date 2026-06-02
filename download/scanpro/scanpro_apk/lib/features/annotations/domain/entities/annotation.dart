import 'package:equatable/equatable.dart';

/// Enum representing the different types of annotations.
enum AnnotationType {
  /// Text highlight annotation.
  highlight,

  /// Freehand drawing annotation.
  draw,

  /// Geometric shape annotation (rectangle, circle, arrow).
  shape,

  /// Sticky note annotation.
  note,

  /// Inline text annotation.
  text,
}

/// Domain entity representing an annotation on a document page.
///
/// Annotations can be highlights, drawings, shapes, notes, or text
/// placed on specific pages of a document. Each annotation carries
/// type-specific [data] including color, stroke points, bounding
/// rectangles, and text content.
class Annotation extends Equatable {
  const Annotation({
    required this.id,
    required this.documentId,
    required this.page,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for this annotation.
  final String id;

  /// ID of the document this annotation belongs to.
  final String documentId;

  /// Zero-based page index where the annotation is placed.
  final int page;

  /// The type of annotation.
  final AnnotationType type;

  /// Type-specific data for the annotation.
  ///
  /// - **highlight**: `{'color': '#FFFF00', 'rect': {...}, 'text': '...'}`
  /// - **draw**: `{'color': '#FF0000', 'strokeWidth': 2.0, 'points': [...]}`
  /// - **shape**: `{'color': '#00FF00', 'shapeType': 'rectangle', 'rect': {...}}`
  /// - **note**: `{'color': '#4D2DAB', 'text': 'Note content', 'position': {...}}`
  /// - **text**: `{'color': '#000000', 'text': 'Text content', 'fontSize': 14.0, 'position': {...}}`
  final Map<String, dynamic> data;

  /// When this annotation was created.
  final DateTime createdAt;

  /// When this annotation was last updated.
  final DateTime updatedAt;

  /// Creates a copy with optional field overrides.
  Annotation copyWith({
    String? id,
    String? documentId,
    int? page,
    AnnotationType? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Annotation(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      page: page ?? this.page,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        page,
        type,
        data,
        createdAt,
        updatedAt,
      ];
}
