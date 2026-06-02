import 'package:hive/hive.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_result.dart';

part 'scan_result_model.g.dart';

/// Hive-compatible data model for [ScanResult].
///
/// Provides serialization/deserialization for local storage with Hive,
/// and conversion methods between the domain entity and data model.
@HiveType(typeId: 1)
class ScanResultModel extends HiveObject {
  /// Unique identifier.
  @HiveField(0)
  final String id;

  /// Absolute path to the original image.
  @HiveField(1)
  final String originalPath;

  /// Absolute path to the cropped image.
  @HiveField(2)
  final String? croppedPath;

  /// Absolute path to the enhanced image.
  @HiveField(3)
  final String? enhancedPath;

  /// Detected edge points as a flat list: [x0, y0, x1, y1, x2, y2, x3, y3].
  @HiveField(4)
  final List<double> edgePointsFlat;

  /// Confidence score.
  @HiveField(5)
  final double confidence;

  /// Timestamp as ISO 8601 string.
  @HiveField(6)
  final String timestamp;

  ScanResultModel({
    required this.id,
    required this.originalPath,
    this.croppedPath,
    this.enhancedPath,
    this.edgePointsFlat = const [],
    this.confidence = 0.0,
    required this.timestamp,
  });

  /// Creates a model from a domain entity.
  factory ScanResultModel.fromEntity(ScanResult entity) {
    final flatPoints = <double>[];
    for (final point in entity.edges) {
      flatPoints.add(point.x);
      flatPoints.add(point.y);
    }
    return ScanResultModel(
      id: entity.id,
      originalPath: entity.originalPath,
      croppedPath: entity.croppedPath,
      enhancedPath: entity.enhancedPath,
      edgePointsFlat: flatPoints,
      confidence: entity.confidence,
      timestamp: entity.timestamp.toIso8601String(),
    );
  }

  /// Converts this model to a domain entity.
  ScanResult toEntity() {
    final points = <EdgePoint>[];
    for (var i = 0; i < edgePointsFlat.length - 1; i += 2) {
      points.add(EdgePoint(
        x: edgePointsFlat[i],
        y: edgePointsFlat[i + 1],
      ));
    }
    return ScanResult(
      id: id,
      originalPath: originalPath,
      croppedPath: croppedPath,
      enhancedPath: enhancedPath,
      edges: points,
      confidence: confidence,
      timestamp: DateTime.parse(timestamp),
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalPath': originalPath,
      'croppedPath': croppedPath,
      'enhancedPath': enhancedPath,
      'edgePointsFlat': edgePointsFlat,
      'confidence': confidence,
      'timestamp': timestamp,
    };
  }

  /// Creates a model from a JSON map.
  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id: json['id'] as String,
      originalPath: json['originalPath'] as String,
      croppedPath: json['croppedPath'] as String?,
      enhancedPath: json['enhancedPath'] as String?,
      edgePointsFlat: (json['edgePointsFlat'] as List<dynamic>)
          .cast<double>(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] as String,
    );
  }
}
