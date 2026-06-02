import 'package:equatable/equatable.dart';

/// Represents a single edge point in document detection.
///
/// Each point contains normalized coordinates (0.0 to 1.0)
/// relative to the image dimensions.
class EdgePoint extends Equatable {
  /// X coordinate normalized to image width (0.0–1.0).
  final double x;

  /// Y coordinate normalized to image height (0.0–1.0).
  final double y;

  const EdgePoint({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];
}

/// Entity representing the result of a single scan capture.
///
/// Contains paths to original, cropped, and enhanced images along
/// with detected edge information and confidence scores.
class ScanResult extends Equatable {
  /// Unique identifier for this scan result.
  final String id;

  /// Absolute path to the original captured image.
  final String originalPath;

  /// Absolute path to the cropped image, null if not yet cropped.
  final String? croppedPath;

  /// Absolute path to the enhanced image, null if not yet enhanced.
  final String? enhancedPath;

  /// Four detected edge points in order: top-left, top-right, bottom-right, bottom-left.
  final List<EdgePoint> edges;

  /// Confidence score of the edge detection (0.0–1.0).
  final double confidence;

  /// Timestamp when the scan was captured.
  final DateTime timestamp;

  const ScanResult({
    required this.id,
    required this.originalPath,
    this.croppedPath,
    this.enhancedPath,
    this.edges = const [],
    this.confidence = 0.0,
    required this.timestamp,
  });

  /// Creates a copy with optional field overrides.
  ScanResult copyWith({
    String? id,
    String? originalPath,
    String? croppedPath,
    String? enhancedPath,
    List<EdgePoint>? edges,
    double? confidence,
    DateTime? timestamp,
  }) {
    return ScanResult(
      id: id ?? this.id,
      originalPath: originalPath ?? this.originalPath,
      croppedPath: croppedPath ?? this.croppedPath,
      enhancedPath: enhancedPath ?? this.enhancedPath,
      edges: edges ?? this.edges,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Returns the best available image path (enhanced > cropped > original).
  String get bestImagePath => enhancedPath ?? croppedPath ?? originalPath;

  @override
  List<Object?> get props => [
        id,
        originalPath,
        croppedPath,
        enhancedPath,
        edges,
        confidence,
        timestamp,
      ];
}
