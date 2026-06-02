import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';
import 'package:scanpro/features/ocr/domain/repositories/ocr_repository.dart';

/// Use case for recognizing text from an image using OCR.
///
/// Validates the input [imagePath] and delegates to [OcrRepository]
/// for the actual text recognition. Returns [OcrResult] on success
/// or a [Failure] on error.
class RecognizeTextUseCase {
  const RecognizeTextUseCase(this._repository);

  final OcrRepository _repository;

  /// Executes text recognition on the image at [imagePath].
  ///
  /// [language] optionally specifies the language for better accuracy
  /// (defaults to 'en'). Returns a [ValidationFailure] if the path is
  /// empty, or delegates to the repository for processing.
  Future<Either<Failure, OcrResult>> call({
    required String imagePath,
    String language = 'en',
  }) async {
    if (imagePath.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Image path'));
    }

    return _repository.recognizeText(
      imagePath: imagePath,
      language: language,
    );
  }
}
