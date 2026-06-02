import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';

/// Parameters for the search documents use case.
class SearchDocumentsParams extends Equatable {
  /// Search query string.
  final String query;

  /// Whether to search in OCR text as well as titles.
  final bool includeOcrText;

  /// Maximum number of results to return.
  final int limit;

  const SearchDocumentsParams({
    required this.query,
    this.includeOcrText = true,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [query, includeOcrText, limit];
}

/// Use case for full-text search across documents.
///
/// Searches document titles and optionally OCR-extracted text
/// content, returning matching documents ranked by relevance.
class SearchDocuments
    implements UseCase<List<ScanDocument>, SearchDocumentsParams> {
  final DocumentRepository _repository;

  SearchDocuments(this._repository);

  @override
  Future<Either<Failure, List<ScanDocument>>> call(
    SearchDocumentsParams params,
  ) async {
    if (params.query.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Search query cannot be empty'),
      );
    }
    if (params.limit <= 0) {
      return const Left(
        ValidationFailure(message: 'Limit must be greater than 0'),
      );
    }

    final result = await _repository.searchDocuments(params.query.trim());

    return result.map((documents) {
      if (!params.includeOcrText) {
        return documents
            .where((doc) =>
                doc.title.toLowerCase().contains(params.query.toLowerCase()))
            .take(params.limit)
            .toList();
      }
      return documents.take(params.limit).toList();
    });
  }
}
