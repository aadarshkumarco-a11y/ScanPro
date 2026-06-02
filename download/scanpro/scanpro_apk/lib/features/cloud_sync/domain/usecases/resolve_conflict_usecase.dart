import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_record.dart';
import 'package:scanpro/features/cloud_sync/domain/repositories/cloud_sync_repository.dart';

/// Valid conflict resolution strategies.
class ConflictResolution {
  /// Keep the local version (overwrite remote).
  static const String keepLocal = 'keep_local';

  /// Keep the remote version (overwrite local).
  static const String keepRemote = 'keep_remote';

  /// Keep both versions as separate documents.
  static const String keepBoth = 'keep_both';

  /// All valid resolution values.
  static const List<String> validResolutions = [
    keepLocal,
    keepRemote,
    keepBoth,
  ];

  /// Returns a human-readable label for a resolution.
  static String label(String resolution) {
    switch (resolution) {
      case keepLocal:
        return 'Keep Local';
      case keepRemote:
        return 'Keep Remote';
      case keepBoth:
        return 'Keep Both';
      default:
        return resolution;
    }
  }
}

/// Use case for resolving a cloud sync conflict.
///
/// Validates the document ID and resolution strategy before
/// delegating to [CloudSyncRepository.resolveConflict].
class ResolveConflictUseCase {
  const ResolveConflictUseCase(this._repository);

  final CloudSyncRepository _repository;

  /// Executes the conflict resolution.
  ///
  /// [documentId] – the ID of the conflicting document.
  /// [resolution] – one of [ConflictResolution.keepLocal],
  ///   [ConflictResolution.keepRemote], or [ConflictResolution.keepBoth].
  Future<Either<Failure, SyncRecord>> call(
    String documentId,
    String resolution,
  ) async {
    if (documentId.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Document ID'));
    }

    if (!ConflictResolution.validResolutions.contains(resolution)) {
      return Left(ValidationFailure.invalidFormat('Conflict resolution'));
    }

    return _repository.resolveConflict(documentId, resolution);
  }
}
