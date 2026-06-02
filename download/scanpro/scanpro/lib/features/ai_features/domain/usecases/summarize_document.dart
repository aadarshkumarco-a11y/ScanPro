import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_summary.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/ai_features/domain/repositories/ai_repository.dart';

/// Parameters for the summarize document use case.
class SummarizeDocumentParams extends Equatable {
  /// The document to summarize.
  final ScanDocument document;

  /// Maximum length of the summary in words.
  final int maxWords;

  /// Whether to extract key points alongside the summary.
  final bool includeKeyPoints;

  const SummarizeDocumentParams({
    required this.document,
    this.maxWords = 150,
    this.includeKeyPoints = true,
  });

  @override
  List<Object?> get props => [document, maxWords, includeKeyPoints];
}

/// Use case for generating an AI-powered summary of a document.
///
/// Uses Gemini AI to analyze document content and produce a concise
/// summary with optional key point extraction.
class SummarizeDocument
    implements UseCase<AISummary, SummarizeDocumentParams> {
  final AIRepository _repository;

  SummarizeDocument(this._repository);

  @override
  Future<Either<Failure, AISummary>> call(
    SummarizeDocumentParams params,
  ) async {
    if (params.document.filePath.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Document file path cannot be empty'),
      );
    }
    if (params.maxWords <= 0) {
      return const Left(
        ValidationFailure(message: 'Max words must be greater than 0'),
      );
    }
    return _repository.summarizeDocument(params.document);
  }
}
