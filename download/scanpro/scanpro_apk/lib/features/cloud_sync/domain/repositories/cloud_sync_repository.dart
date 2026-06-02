import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_record.dart';

/// Abstract repository contract for cloud synchronization operations.
///
/// Defines the domain-level API for syncing documents to and from
/// the cloud, checking sync status, resolving conflicts, and
/// managing cloud storage.
abstract class CloudSyncRepository {
  /// Syncs a single document to the cloud.
  ///
  /// Uploads the document file and updates the sync metadata.
  /// Returns the updated [SyncRecord] with new version and cloud path.
  Future<Either<Failure, SyncRecord>> syncDocument(String documentId);

  /// Syncs all pending documents to the cloud.
  ///
  /// Processes documents with [SyncStatus.pending] in batch.
  /// Returns the list of updated [SyncRecord]s.
  Future<Either<Failure, List<SyncRecord>>> syncAll();

  /// Retrieves the sync status for a given [documentId].
  ///
  /// Returns the [SyncRecord] if it exists, or a failure if not found.
  Future<Either<Failure, SyncRecord>> getSyncStatus(String documentId);

  /// Resolves a sync conflict for the given [documentId].
  ///
  /// [resolution] determines how the conflict is resolved:
  /// - `'keep_local'` – local version overwrites remote.
  /// - `'keep_remote'` – remote version overwrites local.
  /// - `'keep_both'` – both versions are kept as separate documents.
  Future<Either<Failure, SyncRecord>> resolveConflict(
    String documentId,
    String resolution,
  );

  /// Deletes a document from cloud storage.
  ///
  /// Removes the file from cloud storage and updates the sync record.
  Future<Either<Failure, Unit>> deleteFromCloud(String documentId);

  /// Downloads a document from the cloud.
  ///
  /// Downloads the document file from cloud storage using the
  /// [cloudPath] stored in the sync record. Returns the local
  /// file path after download.
  Future<Either<Failure, String>> downloadDocument(String documentId);

  /// Retrieves all sync records.
  ///
  /// Returns all [SyncRecord]s for display in the sync dashboard.
  Future<Either<Failure, List<SyncRecord>>> getAllSyncRecords();

  /// Gets the total cloud storage used in bytes.
  Future<Either<Failure, int>> getStorageUsed();

  /// Gets the total cloud storage capacity in bytes.
  Future<Either<Failure, int>> getStorageCapacity();
}
