import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_record.dart';
import 'package:scanpro/features/cloud_sync/domain/repositories/sync_repository.dart';

/// Parameters for the resolve conflict use case.
class ResolveConflictParams extends Equatable {
  /// ID of the sync record with the conflict.
  final String recordId;

  /// Whether to keep the local version (true) or the remote version (false).
  final bool useLocalVersion;

  const ResolveConflictParams({
    required this.recordId,
    required this.useLocalVersion,
  });

  @override
  List<Object?> get props => [recordId, useLocalVersion];
}

/// Use case for resolving a sync conflict between local and remote data.
///
/// Allows the user to choose which version of a document to keep
/// when a synchronization conflict is detected.
class ResolveConflict
    implements UseCase<SyncRecord, ResolveConflictParams> {
  final SyncRepository _repository;

  ResolveConflict(this._repository);

  @override
  Future<Either<Failure, SyncRecord>> call(
    ResolveConflictParams params,
  ) async {
    if (params.recordId.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Record ID cannot be empty'),
      );
    }
    return _repository.resolveConflict(
      params.recordId,
      params.useLocalVersion,
    );
  }
}
