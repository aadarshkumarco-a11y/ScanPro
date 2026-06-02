import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';

/// Abstract repository contract for scanner operations.
///
/// Defines the domain-level API for scanning, cropping, enhancing,
/// rotating, filtering, and persisting scanned documents.
/// Implementations must convert data-layer exceptions into [Failure]s.
abstract class ScannerRepository {
  /// Captures a document image from the camera.
  ///
  /// Returns the captured [ScannedDocument] on success, or a [ScannerFailure]
  /// if the camera is unavailable or permission is denied.
  Future<Either<Failure, ScannedDocument>> scanDocument();

  /// Crops the image at [filePath] to the region defined by [cropArea].
  ///
  /// [cropArea] is a list of four normalised doubles [left, top, right, bottom].
  /// Returns the updated [ScannedDocument] with the cropped file path.
  Future<Either<Failure, ScannedDocument>> cropImage({
    required String filePath,
    required List<double> cropArea,
    required ScannedDocument document,
  });

  /// Applies automatic enhancement (brightness, contrast, sharpness)
  /// to the image at [filePath].
  ///
  /// Returns the updated [ScannedDocument] with the enhanced file path.
  Future<Either<Failure, ScannedDocument>> enhanceImage({
    required String filePath,
    required ScannedDocument document,
  });

  /// Rotates the image at [filePath] by [degrees] (90, 180, 270).
  ///
  /// Returns the updated [ScannedDocument] with the rotated file path.
  Future<Either<Failure, ScannedDocument>> rotateImage({
    required String filePath,
    required int degrees,
    required ScannedDocument document,
  });

  /// Applies a named filter (e.g. 'grayscale', 'bw', 'magic_color')
  /// to the image at [filePath].
  ///
  /// Returns the updated [ScannedDocument] with the filtered file path.
  Future<Either<Failure, ScannedDocument>> applyFilter({
    required String filePath,
    required String filterName,
    required ScannedDocument document,
  });

  /// Persists a scanned document to local storage.
  ///
  /// Returns the saved [ScannedDocument] (with updated timestamps and IDs)
  /// on success, or a [CacheFailure] on error.
  Future<Either<Failure, ScannedDocument>> saveDocument(
    ScannedDocument document,
  );

  /// Deletes a scanned document by [documentId].
  ///
  /// Returns unit on success, or a [CacheFailure] if the document
  /// cannot be found or deleted.
  Future<Either<Failure, Unit>> deleteDocument(String documentId);

  /// Retrieves all scanned documents.
  ///
  /// Returns a list of [ScannedDocument]s ordered by most recent first,
  /// or a [CacheFailure] on error.
  Future<Either<Failure, List<ScannedDocument>>> getDocuments();

  /// Retrieves a single scanned document by [documentId].
  ///
  /// Returns the [ScannedDocument], or a [NotFoundFailure] if not found.
  Future<Either<Failure, ScannedDocument>> getDocumentById(String documentId);

  /// Performs a batch scan, capturing [pageCount] pages sequentially.
  ///
  /// Returns a [ScannedDocument] containing all captured pages,
  /// or a [ScannerFailure] if the camera fails mid-batch.
  Future<Either<Failure, ScannedDocument>> batchScan({
    required int pageCount,
  });
}
