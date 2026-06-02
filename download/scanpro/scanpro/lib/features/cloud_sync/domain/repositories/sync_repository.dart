import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_record.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_status.dart';

/// Abstract repository defining the contract for cloud synchronization.
///
/// Manages the synchronization of local documents with cloud storage,
/// including conflict resolution and status tracking.
abstract class SyncRepository {
  /// Synchronizes a single document with the cloud.
  ///
  /// [document] is the document to sync.
  /// Returns the updated [ScanDocument] with new sync status.
  Future<Either<Failure, ScanDocument>> syncDocument(
    ScanDocument document,
  );

  /// Synchronizes all pending local changes with the cloud.
  ///
  /// Returns a list of [SyncRecord] objects representing the
  /// operations that were processed.
  Future<Either<Failure, List<SyncRecord>>> syncAll();

  /// Gets the current synchronization status.
  ///
  /// Returns the overall [SyncStatus] of the sync system.
  Future<Either<Failure, SyncStatus>> getSyncStatus();

  /// Resolves a sync conflict by choosing the local or remote version.
  ///
  /// [recordId] is the ID of the conflicting [SyncRecord].
  /// [useLocalVersion] if true, keeps local data; otherwise uses remote.
  /// Returns the resolved [SyncRecord].
  Future<Either<Failure, SyncRecord>> resolveConflict(
    String recordId,
    bool useLocalVersion,
  );

  /// Gets the timestamp of the last successful sync.
  ///
  /// Returns null if no sync has ever completed successfully.
  Future<Either<Failure, DateTime?>> getLastSyncTime();
}
