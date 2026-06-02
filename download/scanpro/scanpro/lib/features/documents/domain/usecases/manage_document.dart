import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';

/// Enumeration of document management actions.
enum DocumentAction {
  /// Create a new document.
  create,

  /// Update an existing document.
  update,

  /// Soft-delete a document.
  delete,

  /// Restore a soft-deleted document.
  restore,

  /// Toggle the favorite status.
  toggleFavorite,

  /// Move to a folder.
  moveToFolder,

  /// Archive the document.
  archive,
}

/// Parameters for the manage document use case.
class ManageDocumentParams extends Equatable {
  /// The action to perform.
  final DocumentAction action;

  /// The document entity (required for create and update).
  final ScanDocument? document;

  /// Document ID (required for delete, restore, toggleFavorite, archive).
  final String? documentId;

  /// Target folder ID for moveToFolder action.
  final String? targetFolderId;

  const ManageDocumentParams({
    required this.action,
    this.document,
    this.documentId,
    this.targetFolderId,
  });

  @override
  List<Object?> get props => [action, document, documentId, targetFolderId];
}

/// Use case for performing CRUD and management operations on documents.
///
/// Centralizes all document mutation operations through a single
/// use case, providing consistent validation and error handling.
class ManageDocument
    implements UseCase<ScanDocument, ManageDocumentParams> {
  final DocumentRepository _repository;

  ManageDocument(this._repository);

  @override
  Future<Either<Failure, ScanDocument>> call(
    ManageDocumentParams params,
  ) async {
    switch (params.action) {
      case DocumentAction.create:
        if (params.document == null) {
          return const Left(
            ValidationFailure(message: 'Document is required for create action'),
          );
        }
        return _repository.createDocument(params.document!);

      case DocumentAction.update:
        if (params.document == null) {
          return const Left(
            ValidationFailure(message: 'Document is required for update action'),
          );
        }
        return _repository.updateDocument(params.document!);

      case DocumentAction.delete:
        if (params.documentId == null) {
          return const Left(
            ValidationFailure(message: 'Document ID is required for delete action'),
          );
        }
        final result = await _repository.deleteDocument(params.documentId!);
        return result.fold(
          (failure) => Left(failure),
          (_) => _repository.getDocument(params.documentId!),
        );

      case DocumentAction.restore:
        if (params.documentId == null) {
          return const Left(
            ValidationFailure(message: 'Document ID is required for restore action'),
          );
        }
        return _repository.restoreDocument(params.documentId!);

      case DocumentAction.toggleFavorite:
        if (params.documentId == null) {
          return const Left(
            ValidationFailure(
              message: 'Document ID is required for toggleFavorite action',
            ),
          );
        }
        final docResult = await _repository.getDocument(params.documentId!);
        return docResult.fold(
          (failure) => Left(failure),
          (doc) => _repository.updateDocument(
            doc.copyWith(
              isFavorite: !doc.isFavorite,
              updatedAt: DateTime.now(),
            ),
          ),
        );

      case DocumentAction.moveToFolder:
        if (params.documentId == null) {
          return const Left(
            ValidationFailure(
              message: 'Document ID is required for moveToFolder action',
            ),
          );
        }
        final docResult = await _repository.getDocument(params.documentId!);
        return docResult.fold(
          (failure) => Left(failure),
          (doc) => _repository.updateDocument(
            doc.copyWith(
              folderId: params.targetFolderId,
              updatedAt: DateTime.now(),
            ),
          ),
        );

      case DocumentAction.archive:
        if (params.documentId == null) {
          return const Left(
            ValidationFailure(message: 'Document ID is required for archive action'),
          );
        }
        final docResult = await _repository.getDocument(params.documentId!);
        return docResult.fold(
          (failure) => Left(failure),
          (doc) => _repository.updateDocument(
            doc.copyWith(
              isArchived: !doc.isArchived,
              updatedAt: DateTime.now(),
            ),
          ),
        );
    }
  }
}
