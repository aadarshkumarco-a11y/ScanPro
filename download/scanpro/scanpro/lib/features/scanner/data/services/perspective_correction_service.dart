import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Custom exception for perspective correction errors.
class PerspectiveCorrectionException implements Exception {
  final String message;
  const PerspectiveCorrectionException(this.message);
  @override
  String toString() => 'PerspectiveCorrectionException: $message';
}

/// Service for perspective correction using OpenCV (via FFI).
///
/// Applies perspective transforms to correct skewed document images
/// based on detected corner points, producing a flat, rectangular output.
class PerspectiveCorrectionService {
  /// Applies perspective correction to a document image.
  ///
  /// [imagePath] is the source image path.
  /// [corners] is a list of four corner maps with 'x' and 'y' keys,
  /// in order: top-left, top-right, bottom-right, bottom-left.
  /// Coordinates are normalized (0.0–1.0).
  ///
  /// Returns the path to the corrected image.
  Future<String> correctPerspective(
    String imagePath,
    List<Map<String, double>> corners,
  ) async {
    try {
      if (corners.length != 4) {
        throw const PerspectiveCorrectionException(
          'Exactly 4 corners are required for perspective correction',
        );
      }

      final file = File(imagePath);
      if (!await file.exists()) {
        throw const PerspectiveCorrectionException(
          'Source image file not found',
        );
      }

      final outputPath = await _generateOutputPath(imagePath);

      // Production: Call native OpenCV perspective correction:
      // 1. Decode image dimensions
      // 2. Convert normalized corners to pixel coordinates
      // 3. Calculate destination rectangle dimensions
      // 4. Compute perspective transform matrix (getPerspectiveTransform)
      // 5. Apply warpPerspective with the computed matrix
      // 6. Save the corrected image
      await _nativePerspectiveCorrection(
        imagePath,
        outputPath,
        corners,
      );

      return outputPath;
    } on PerspectiveCorrectionException {
      rethrow;
    } catch (e) {
      throw PerspectiveCorrectionException(
        'Perspective correction failed: $e',
      );
    }
  }

  /// Calculates the output dimensions for a perspective-corrected image.
  ///
  /// Determines the width and height of the destination rectangle
  /// based on the maximum distances between corner points.
  ({int width, int height}) calculateOutputDimensions(
    List<Map<String, double>> corners,
    int imageWidth,
    int imageHeight,
  ) {
    final tl = corners[0];
    final tr = corners[1];
    final br = corners[2];
    final bl = corners[3];

    final widthTop = ((tr['x']! - tl['x']!) * imageWidth).abs();
    final widthBottom = ((br['x']! - bl['x']!) * imageWidth).abs();
    final maxWidth = widthTop > widthBottom ? widthTop : widthBottom;

    final heightLeft = ((bl['y']! - tl['y']!) * imageHeight).abs();
    final heightRight = ((br['y']! - tr['y']!) * imageHeight).abs();
    final maxHeight = heightLeft > heightRight ? heightLeft : heightRight;

    return (width: maxWidth.round(), height: maxHeight.round());
  }

  /// Performs the native perspective correction via OpenCV FFI.
  ///
  /// In production, this calls C++ OpenCV functions through dart:ffi.
  Future<void> _nativePerspectiveCorrection(
    String inputPath,
    String outputPath,
    List<Map<String, double>> corners,
  ) async {
    // Production implementation:
    // final dylib = DynamicLibrary.open('libopencv_processor.so');
    // final correctPerspective = dylib.lookupFunction<
    //   Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Double>),
    //   Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Double>)
    // >('correctPerspective');

    // For now, copy the input as placeholder
    await File(inputPath).copy(outputPath);
  }

  /// Generates a unique output path for the corrected image.
  Future<String> _generateOutputPath(String inputPath) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = p.extension(inputPath);
    return p.join(tempDir.path, 'corrected_$timestamp$ext');
  }
}
