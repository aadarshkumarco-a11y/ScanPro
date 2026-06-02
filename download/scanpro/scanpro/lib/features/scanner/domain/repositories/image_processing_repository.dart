import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';

/// Abstract repository defining the contract for image processing operations.
///
/// Provides methods for applying filters, correcting perspective,
/// removing shadows, and adjusting image properties on scanned documents.
abstract class ImageProcessingRepository {
  /// Processes an image with the specified pipeline of operations.
  ///
  /// [imagePath] is the absolute path to the source image.
  /// Returns the path to the processed image file.
  Future<Either<Failure, String>> processImage(String imagePath);

  /// Applies a named filter to the image.
  ///
  /// [imagePath] is the source image path.
  /// [filterName] identifies the filter (e.g., 'grayscale', 'sepia', 'bw').
  /// Returns the path to the filtered image file.
  Future<Either<Failure, String>> applyFilter(
    String imagePath,
    String filterName,
  );

  /// Corrects the perspective of a document image based on detected edges.
  ///
  /// [imagePath] is the source image path.
  /// [corners] are the four corner points as `[{x, y}]` maps.
  /// Returns the path to the perspective-corrected image.
  Future<Either<Failure, String>> correctPerspective(
    String imagePath,
    List<Map<String, double>> corners,
  );

  /// Removes shadows from the document image.
  ///
  /// [imagePath] is the source image path.
  /// Returns the path to the shadow-removed image.
  Future<Either<Failure, String>> removeShadows(String imagePath);

  /// Adjusts the brightness of the image.
  ///
  /// [imagePath] is the source image path.
  /// [value] is the brightness adjustment (-100 to 100).
  /// Returns the path to the adjusted image.
  Future<Either<Failure, String>> adjustBrightness(
    String imagePath,
    double value,
  );

  /// Adjusts the contrast of the image.
  ///
  /// [imagePath] is the source image path.
  /// [value] is the contrast adjustment (0.5 to 3.0, where 1.0 is original).
  /// Returns the path to the adjusted image.
  Future<Either<Failure, String>> adjustContrast(
    String imagePath,
    double value,
  );

  /// Applies a sharpening filter to the image.
  ///
  /// [imagePath] is the source image path.
  /// [intensity] is the sharpening strength (0.0 to 1.0).
  /// Returns the path to the sharpened image.
  Future<Either<Failure, String>> sharpen(
    String imagePath,
    double intensity,
  );
}
