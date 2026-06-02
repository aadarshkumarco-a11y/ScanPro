import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_result.dart';
import 'package:scanpro/features/scanner/domain/entities/edge_detection_result.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';

/// Abstract repository defining the contract for scanner operations.
///
/// This interface is implemented by the data layer and provides
/// all scanner-related functionality without exposing implementation
/// details to the domain layer.
abstract class ScannerRepository {
  /// Captures a document image using the device camera.
  ///
  /// Returns a [ScanResult] containing the captured image path and
  /// detected edges, or a [Failure] if the capture fails.
  Future<Either<Failure, ScanResult>> captureDocument();

  /// Detects document edges in the given image.
  ///
  /// [imagePath] is the absolute path to the source image.
  /// Returns an [EdgeDetectionResult] with the four detected corner
  /// points and confidence score.
  Future<Either<Failure, EdgeDetectionResult>> detectEdges(
    String imagePath,
  );

  /// Crops the image to the detected document boundaries.
  ///
  /// [imagePath] is the source image path.
  /// [edges] are the four corner points defining the crop region.
  /// Returns the absolute path to the cropped image file.
  Future<Either<Failure, String>> cropDocument(
    String imagePath,
    List<EdgePoint> edges,
  );

  /// Applies image enhancement to the document.
  ///
  /// [imagePath] is the source image path.
  /// [enhancementType] specifies the type of enhancement to apply.
  /// Returns the absolute path to the enhanced image file.
  Future<Either<Failure, String>> enhanceDocument(
    String imagePath,
    EnhancementType enhancementType,
  );

  /// Imports images from the device gallery.
  ///
  /// Returns a list of [ScanResult] objects for each imported image,
  /// or a [Failure] if the import fails.
  Future<Either<Failure, List<ScanResult>>> importFromGallery();
}
