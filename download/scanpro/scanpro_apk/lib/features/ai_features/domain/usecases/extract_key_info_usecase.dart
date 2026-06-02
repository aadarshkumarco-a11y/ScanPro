import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_result.dart';
import 'package:scanpro/features/ai_features/domain/repositories/ai_repository.dart';

/// Use case for extracting key information from a document.
///
/// Validates the input text before delegating to
/// [AiRepository.extractKeyInfo].
class ExtractKeyInfoUseCase {
  const ExtractKeyInfoUseCase(this._repository);

  final AiRepository _repository;

  /// Executes key information extraction.
  ///
  /// [text] – the document text to extract information from.
  /// [documentId] – optional document reference for caching.
  Future<Either<Failure, AiResult>> call({
    required String text,
    String? documentId,
  }) async {
    if (text.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Document text'));
    }

    return _repository.extractKeyInfo(
      text: text,
      documentId: documentId,
    );
  }
}
