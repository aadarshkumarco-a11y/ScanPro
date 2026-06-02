import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';

/// Use case for trash operations: move to trash, restore,
/// permanent delete, and empty trash.
class TrashUseCase {
  const TrashUseCase(this._repository);

  final DocumentRepository _repository;

  /// Moves a document to the trash by [documentId].
  ///
  /// Returns a [NotFoundFailure] if the document does not exist.
  Future<Either<Failure, Unit>> moveToTrash(String documentId) async {
    if (documentId.isEmpty) {
      return Left(ValidationFailure.emptyField('documentId'));
    }
    return _repository.moveToTrash(documentId);
  }

  /// Restores a document from the trash by [documentId].
  ///
  /// Returns a [NotFoundFailure] if the document is not in the trash.
  Future<Either<Failure, Unit>> restore(String documentId) async {
    if (documentId.isEmpty) {
      return Left(ValidationFailure.emptyField('documentId'));
    }
    return _repository.restoreFromTrash(documentId);
  }

  /// Permanently deletes a document by [documentId].
  ///
  /// This action is irreversible.
  Future<Either<Failure, Unit>> permanentDelete(String documentId) async {
    if (documentId.isEmpty) {
      return Left(ValidationFailure.emptyField('documentId'));
    }
    return _repository.permanentDelete(documentId);
  }

  /// Empties the trash, permanently deleting all trashed documents.
  ///
  /// This action is irreversible.
  Future<Either<Failure, Unit>> emptyTrash() async {
    return _repository.emptyTrash();
  }

  /// Retrieves all documents currently in the trash.
  Future<Either<Failure, List<ScannedDocument>>> getTrashedDocuments() async {
    return _repository.getTrashedDocuments();
  }
}
