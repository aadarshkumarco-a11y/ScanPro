import 'package:equatable/equatable.dart';

/// Entity representing the result of edge detection on a captured image.
///
/// Contains the four detected corner points and a confidence score
/// indicating how likely a valid document was found in the image.
class EdgeDetectionResult extends Equatable {
  /// Four corner points in order:
  /// [0] = top-left, [1] = top-right,
  /// [2] = bottom-right, [3] = bottom-left.
  ///
  /// Coordinates are normalized (0.0–1.0) relative to image dimensions.
  final List<EdgePoint> points;

  /// Confidence score of the detection (0.0–1.0).
  /// Values above 0.7 generally indicate a reliable detection.
  final double confidence;

  /// Whether a document was successfully detected in the image.
  final bool isDocumentDetected;

  const EdgeDetectionResult({
    required this.points,
    required this.confidence,
    required this.isDocumentDetected,
  });

  /// Creates an empty result when no document is detected.
  const EdgeDetectionResult.notDetected()
      : points = const [],
        confidence = 0.0,
        isDocumentDetected = false;

  /// Creates a copy with optional field overrides.
  EdgeDetectionResult copyWith({
    List<EdgePoint>? points,
    double? confidence,
    bool? isDocumentDetected,
  }) {
    return EdgeDetectionResult(
      points: points ?? this.points,
      confidence: confidence ?? this.confidence,
      isDocumentDetected: isDocumentDetected ?? this.isDocumentDetected,
    );
  }

  /// Whether exactly four edge points were detected.
  bool get hasValidPoints => points.length == 4;

  @override
  List<Object?> get props => [points, confidence, isDocumentDetected];
}

/// Represents a single point in edge detection coordinates.
class EdgePoint extends Equatable {
  /// X coordinate normalized to image width (0.0–1.0).
  final double x;

  /// Y coordinate normalized to image height (0.0–1.0).
  final double y;

  const EdgePoint({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];
}
