import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_result.dart';
import 'package:scanpro/features/ai_features/domain/repositories/ai_repository.dart';

/// Use case for generating smart rename suggestions.
///
/// Validates the input text and current name before delegating
/// to [AiRepository.smartRename].
class SmartRenameUseCase {
  const SmartRenameUseCase(this._repository);

  final AiRepository _repository;

  /// Executes the smart rename operation.
  ///
  /// [text] – the document text to analyze for naming context.
  /// [currentName] – the current file name to improve upon.
  /// [documentId] – optional document reference for caching.
  Future<Either<Failure, AiResult>> call({
    required String text,
    required String currentName,
    String? documentId,
  }) async {
    if (text.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Document text'));
    }

    if (currentName.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Current name'));
    }

    return _repository.smartRename(
      text: text,
      currentName: currentName,
      documentId: documentId,
    );
  }
}
