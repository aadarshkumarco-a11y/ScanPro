import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';

/// Use case for retrieving scanned documents.
///
/// Supports filtering by folder and tag, and optionally includes
/// soft-deleted (trashed) documents.
class GetDocumentsUseCase {
  const GetDocumentsUseCase(this._repository);

  final DocumentRepository _repository;

  /// Retrieves documents with optional filters.
  ///
  /// [folderId] – filter by folder (null for root / all).
  /// [tag] – filter by tag name.
  /// [includeDeleted] – whether to include trashed documents.
  Future<Either<Failure, List<ScannedDocument>>> call({
    String? folderId,
    String? tag,
    bool includeDeleted = false,
  }) async {
    return _repository.getDocuments(
      folderId: folderId,
      tag: tag,
      includeDeleted: includeDeleted,
    );
  }
}
