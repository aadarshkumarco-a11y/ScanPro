import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_extraction.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/ai_features/domain/repositories/ai_repository.dart';

/// Parameters for the extract data use case.
class ExtractDataParams extends Equatable {
  /// The document to extract data from.
  final ScanDocument document;

  /// Expected document type hint (e.g., 'invoice', 'receipt', 'id_card').
  /// If null, the AI will auto-detect the document type.
  final String? documentTypeHint;

  const ExtractDataParams({
    required this.document,
    this.documentTypeHint,
  });

  @override
  List<Object?> get props => [document, documentTypeHint];
}

/// Use case for extracting structured data from a document using AI.
///
/// Analyzes the document content and extracts type-specific fields
/// such as invoice numbers, amounts, dates, and vendor information.
class ExtractData implements UseCase<AIExtraction, ExtractDataParams> {
  final AIRepository _repository;

  ExtractData(this._repository);

  @override
  Future<Either<Failure, AIExtraction>> call(ExtractDataParams params) async {
    if (params.document.filePath.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Document file path cannot be empty'),
      );
    }
    return _repository.extractData(params.document);
  }
}
