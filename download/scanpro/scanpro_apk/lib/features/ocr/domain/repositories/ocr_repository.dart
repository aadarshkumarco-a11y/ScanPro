import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';

/// Abstract repository contract for OCR operations.
///
/// Defines the domain-level API for text recognition, result storage,
/// and text region extraction. Implementations must convert data-layer
/// exceptions into [Failure]s.
abstract class OcrRepository {
  /// Recognizes text from an image at the given [imagePath].
  ///
  /// Optionally specify the [language] for more accurate recognition.
  /// Returns the [OcrResult] on success, or an [OcrFailure] on error.
  Future<Either<Failure, OcrResult>> recognizeText({
    required String imagePath,
    String language = 'en',
  });

  /// Recognizes text from an image file at [filePath] (alias for
  /// documents already on disk, e.g. scanned pages).
  ///
  /// Returns the [OcrResult] on success, or an [OcrFailure] on error.
  Future<Either<Failure, OcrResult>> recognizeTextFromPath({
    required String filePath,
    String language = 'en',
  });

  /// Retrieves all OCR results stored locally.
  ///
  /// Returns a list of [OcrResult]s ordered by most recent first,
  /// or a [CacheFailure] on error.
  Future<Either<Failure, List<OcrResult>>> getOcrResults();

  /// Retrieves the OCR result associated with a specific [documentId].
  ///
  /// Returns the [OcrResult], or a [NotFoundFailure] if no result exists.
  Future<Either<Failure, OcrResult>> getOcrResultByDocumentId(
    String documentId,
  );

  /// Deletes an OCR result by [ocrResultId].
  ///
  /// Returns unit on success, or a [CacheFailure] on error.
  Future<Either<Failure, Unit>> deleteOcrResult(String ocrResultId);

  /// Extracts individual text regions (blocks) from an image at [imagePath].
  ///
  /// Useful for structured data extraction where specific regions of
  /// text need to be identified separately (e.g. tables, forms).
  /// Returns the [OcrResult] with populated blocks, or an [OcrFailure].
  Future<Either<Failure, OcrResult>> extractTextRegions({
    required String imagePath,
    String language = 'en',
  });
}
