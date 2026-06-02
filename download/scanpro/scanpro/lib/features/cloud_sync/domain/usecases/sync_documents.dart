import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_record.dart';
import 'package:scanpro/features/cloud_sync/domain/repositories/sync_repository.dart';

/// Parameters for the sync documents use case.
class SyncDocumentsParams extends Equatable {
  /// Whether to force sync even if no changes are detected.
  final bool forceSync;

  /// Maximum number of documents to sync in a single batch.
  final int batchSize;

  const SyncDocumentsParams({
    this.forceSync = false,
    this.batchSize = 50,
  });

  @override
  List<Object?> get props => [forceSync, batchSize];
}

/// Use case for synchronizing local documents with cloud storage.
///
/// Processes all pending sync records and uploads/downloads
/// document changes to keep local and remote data in sync.
class SyncDocuments
    implements UseCase<List<SyncRecord>, SyncDocumentsParams> {
  final SyncRepository _repository;

  SyncDocuments(this._repository);

  @override
  Future<Either<Failure, List<SyncRecord>>> call(
    SyncDocumentsParams params,
  ) async {
    if (params.batchSize <= 0) {
      return const Left(
        ValidationFailure(message: 'Batch size must be greater than 0'),
      );
    }
    return _repository.syncAll();
  }
}
