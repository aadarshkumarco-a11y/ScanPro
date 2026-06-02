import 'package:dartz/dartz.dart';
import 'package:scanpro/core/constants/app_constants.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_result.dart';
import 'package:scanpro/features/ai_features/domain/repositories/ai_repository.dart';

/// Use case for summarizing a document.
///
/// Validates the input text and [maxWords] before delegating
/// to [AiRepository.summarizeDocument].
class SummarizeDocumentUseCase {
  const SummarizeDocumentUseCase(this._repository);

  final AiRepository _repository;

  /// Executes the document summarization.
  ///
  /// [text] – the document text to summarize.
  /// [documentId] – optional document reference for caching.
  /// [maxWords] – maximum words in the summary (1–500).
  Future<Either<Failure, AiResult>> call({
    required String text,
    String? documentId,
    int maxWords = AppConstants.aiSummaryMaxWordsDefault,
  }) async {
    // Validate text.
    if (text.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Document text'));
    }

    // Validate maxWords.
    if (maxWords <= 0) {
      return Left(ValidationFailure.outOfRange('maxWords'));
    }
    if (maxWords > AppConstants.aiSummaryMaxWordsLimit) {
      return Left(ValidationFailure.tooLong(
        'maxWords',
        AppConstants.aiSummaryMaxWordsLimit,
      ));
    }

    return _repository.summarizeDocument(
      text: text,
      documentId: documentId,
      maxWords: maxWords,
    );
  }
}
