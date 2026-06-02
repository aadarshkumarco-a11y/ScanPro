import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/ai_features/domain/repositories/ai_repository.dart';

/// Parameters for the smart rename use case.
class SmartRenameParams extends Equatable {
  /// The document to generate a name for.
  final ScanDocument document;

  /// Maximum length of the suggested name.
  final int maxLength;

  /// Whether to include the date in the suggested name.
  final bool includeDate;

  const SmartRenameParams({
    required this.document,
    this.maxLength = 50,
    this.includeDate = true,
  });

  @override
  List<Object?> get props => [document, maxLength, includeDate];
}

/// Use case for AI-powered document renaming.
///
/// Analyzes the document content using Gemini and generates a
/// descriptive, human-readable filename based on the content.
class SmartRename implements UseCase<String, SmartRenameParams> {
  final AIRepository _repository;

  SmartRename(this._repository);

  @override
  Future<Either<Failure, String>> call(SmartRenameParams params) async {
    if (params.document.filePath.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Document file path cannot be empty'),
      );
    }
    if (params.maxLength <= 0) {
      return const Left(
        ValidationFailure(message: 'Max length must be greater than 0'),
      );
    }
    return _repository.smartRename(params.document);
  }
}
