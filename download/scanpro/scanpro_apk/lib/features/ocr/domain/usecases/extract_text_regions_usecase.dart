import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';
import 'package:scanpro/features/ocr/domain/repositories/ocr_repository.dart';

/// Use case for extracting text regions (structured blocks) from an image.
///
/// Unlike [RecognizeTextUseCase] which focuses on full-text recognition,
/// this use case emphasizes extracting individual text regions with their
/// bounding boxes and block types, useful for form and table extraction.
class ExtractTextRegionsUseCase {
  const ExtractTextRegionsUseCase(this._repository);

  final OcrRepository _repository;

  /// Executes text region extraction on the image at [imagePath].
  ///
  /// [language] optionally specifies the language for better accuracy.
  /// Returns a [ValidationFailure] if the path is empty, or delegates
  /// to the repository for processing.
  Future<Either<Failure, OcrResult>> call({
    required String imagePath,
    String language = 'en',
  }) async {
    if (imagePath.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Image path'));
    }

    return _repository.extractTextRegions(
      imagePath: imagePath,
      language: language,
    );
  }
}
