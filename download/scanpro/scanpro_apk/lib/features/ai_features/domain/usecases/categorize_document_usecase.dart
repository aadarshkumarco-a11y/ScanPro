import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_result.dart';
import 'package:scanpro/features/ai_features/domain/repositories/ai_repository.dart';

/// Use case for auto-categorizing a document.
///
/// Validates the input text before delegating to
/// [AiRepository.categorizeDocument].
class CategorizeDocumentUseCase {
  const CategorizeDocumentUseCase(this._repository);

  final AiRepository _repository;

  /// Executes document categorization.
  ///
  /// [text] – the document text to categorize.
  /// [documentId] – optional document reference for caching.
  Future<Either<Failure, AiResult>> call({
    required String text,
    String? documentId,
  }) async {
    if (text.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Document text'));
    }

    return _repository.categorizeDocument(
      text: text,
      documentId: documentId,
    );
  }
}
