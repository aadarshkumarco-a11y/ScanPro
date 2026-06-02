import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_record.dart';
import 'package:scanpro/features/cloud_sync/domain/repositories/cloud_sync_repository.dart';

/// Use case for synchronizing a document to the cloud.
///
/// Validates the document ID before delegating to
/// [CloudSyncRepository.syncDocument].
class SyncDocumentUseCase {
  const SyncDocumentUseCase(this._repository);

  final CloudSyncRepository _repository;

  /// Executes the sync operation for a single document.
  ///
  /// [documentId] – the ID of the document to sync.
  /// Validates that the document ID is not empty.
  Future<Either<Failure, SyncRecord>> call(String documentId) async {
    if (documentId.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Document ID'));
    }

    return _repository.syncDocument(documentId);
  }

  /// Syncs all pending documents.
  ///
  /// Returns the list of updated [SyncRecord]s.
  Future<Either<Failure, List<SyncRecord>>> syncAll() async {
    return _repository.syncAll();
  }
}
