import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';

/// Parameters for the get documents use case.
class GetDocumentsParams extends Equatable {
  /// Optional folder ID to filter by.
  final String? folderId;

  /// Optional tag ID to filter by.
  final String? tagId;

  /// Whether to include archived documents.
  final bool includeArchived;

  /// Whether to include deleted documents.
  final bool includeDeleted;

  /// Sort field for the document list.
  final String sortBy;

  /// Whether to sort in ascending order.
  final bool sortAscending;

  const GetDocumentsParams({
    this.folderId,
    this.tagId,
    this.includeArchived = false,
    this.includeDeleted = false,
    this.sortBy = 'updatedAt',
    this.sortAscending = false,
  });

  @override
  List<Object?> get props => [
        folderId,
        tagId,
        includeArchived,
        includeDeleted,
        sortBy,
        sortAscending,
      ];
}

/// Use case for retrieving the list of documents with filtering.
///
/// Supports filtering by folder, tag, archive status, and deletion
/// status, along with configurable sorting options.
class GetDocuments implements UseCase<List<ScanDocument>, GetDocumentsParams> {
  final DocumentRepository _repository;

  GetDocuments(this._repository);

  @override
  Future<Either<Failure, List<ScanDocument>>> call(
    GetDocumentsParams params,
  ) async {
    if (params.folderId != null) {
      return _repository.getByFolder(params.folderId);
    }
    if (params.tagId != null) {
      return _repository.getByTag(params.tagId!);
    }

    final result = await _repository.getDocuments();
    return result.map((documents) {
      var filtered = documents.where((doc) => true).toList();

      if (!params.includeArchived) {
        filtered = filtered.where((doc) => !doc.isArchived).toList();
      }
      if (!params.includeDeleted) {
        filtered = filtered.where((doc) => !doc.isDeleted).toList();
      }

      return filtered;
    });
  }
}
