import 'package:hive/hive.dart';
import 'package:scanpro/features/annotations/domain/entities/annotation.dart';

part 'annotation_model.g.dart';

/// Hive-compatible data model for [Annotation].
///
/// Provides serialization/deserialization for local storage with Hive,
/// and conversion methods between the domain entity and data model.
@HiveType(typeId: 10)
class AnnotationModel extends HiveObject {
  /// Unique identifier.
  @HiveField(0)
  final String id;

  /// ID of the parent document.
  @HiveField(1)
  final String documentId;

  /// Zero-based page index.
  @HiveField(2)
  final int pageIndex;

  /// Annotation type index.
  @HiveField(3)
  final int typeIndex;

  /// Type-specific annotation data.
  @HiveField(4)
  final Map data;

  /// Color hex code.
  @HiveField(5)
  final String color;

  /// Position coordinates.
  @HiveField(6)
  final Map position;

  /// Creation timestamp as ISO 8601 string.
  @HiveField(7)
  final String createdAt;

  AnnotationModel({
    required this.id,
    required this.documentId,
    required this.pageIndex,
    required this.typeIndex,
    this.data = const {},
    this.color = '#FFFF00',
    this.position = const {},
    required this.createdAt,
  });

  /// Creates a model from a domain entity.
  factory AnnotationModel.fromEntity(Annotation entity) {
    return AnnotationModel(
      id: entity.id,
      documentId: entity.documentId,
      pageIndex: entity.pageIndex,
      typeIndex: entity.type.index,
      data: Map.from(entity.data),
      color: entity.color,
      position: Map.from(entity.position),
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  /// Converts this model to a domain entity.
  Annotation toEntity() {
    return Annotation(
      id: id,
      documentId: documentId,
      pageIndex: pageIndex,
      type: AnnotationType.values[typeIndex.clamp(
        0,
        AnnotationType.values.length - 1,
      )],
      data: Map<String, dynamic>.from(data),
      color: color,
      position: Map<String, double>.from(position),
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'pageIndex': pageIndex,
      'typeIndex': typeIndex,
      'data': data,
      'color': color,
      'position': position,
      'createdAt': createdAt,
    };
  }

  /// Creates a model from a JSON map.
  factory AnnotationModel.fromJson(Map<String, dynamic> json) {
    return AnnotationModel(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      pageIndex: json['pageIndex'] as int,
      typeIndex: json['typeIndex'] as int,
      data: json['data'] as Map? ?? {},
      color: json['color'] as String? ?? '#FFFF00',
      position: json['position'] as Map? ?? {},
      createdAt: json['createdAt'] as String,
    );
  }
}
