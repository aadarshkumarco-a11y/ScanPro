import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../di/app_module.dart';
import '../../domain/entities/sync_record.dart';
import '../../domain/repositories/cloud_sync_repository.dart';
import '../datasources/cloud_firestore_datasource.dart';
import '../datasources/cloud_storage_datasource.dart';
import '../models/sync_record_model.dart';

/// Concrete implementation of [CloudSyncRepository].
///
/// Orchestrates between local Hive storage and remote Firebase
/// services (Firestore for metadata, Storage for files).
/// Implements conflict detection and resolution logic.
class CloudSyncRepositoryImpl implements CloudSyncRepository {
  CloudSyncRepositoryImpl({
    required CloudFirestoreDatasource firestoreDatasource,
    required CloudStorageDatasource storageDatasource,
    required Box<dynamic> syncRecordsBox,
  })  : _firestoreDatasource = firestoreDatasource,
        _storageDatasource = storageDatasource,
        _syncRecordsBox = syncRecordsBox;

  final CloudFirestoreDatasource _firestoreDatasource;
  final CloudStorageDatasource _storageDatasource;
  final Box<dynamic> _syncRecordsBox;
  static const _uuid = Uuid();

  // ── Sync Document ──────────────────────────────────────────────

  @override
  Future<Either<Failure, SyncRecord>> syncDocument(String documentId) async {
    try {
      // Get or create a local sync record.
      var localRecord = _getLocalSyncRecord(documentId);

      if (localRecord == null) {
        // Create a new pending record.
        localRecord = SyncRecord(
          id: _uuid.v4(),
          documentId: documentId,
          syncStatus: SyncStatus.pending,
          version: 1,
        );
        await _saveLocalSyncRecord(SyncRecordModel.fromEntity(localRecord));
      }

      // Check for conflicts with remote version.
      final hasConflict = await _firestoreDatasource.checkVersionConflict(
        documentId,
        localRecord.version,
      );

      if (hasConflict && localRecord.hasSyncedBefore) {
        // Mark as conflict and return.
        final conflictRecord = localRecord.copyWith(
          syncStatus: SyncStatus.conflict,
        );
        await _saveLocalSyncRecord(SyncRecordModel.fromEntity(conflictRecord));
        await _firestoreDatasource.upsertSyncRecord(conflictRecord);
        return Right(conflictRecord);
      }

      // Update status to indicate syncing in progress.
      final syncingRecord = localRecord.copyWith(
        syncStatus: SyncStatus.pending,
      );
      await _saveLocalSyncRecord(SyncRecordModel.fromEntity(syncingRecord));

      // Upload the file to cloud storage.
      // In a real implementation, the document's local file path
      // would be resolved from the documents repository.
      // For now, we update the sync metadata.
      final cloudPath = 'documents/$documentId/document.pdf';

      // Upsert sync metadata to Firestore.
      final syncedRecord = await _firestoreDatasource.upsertSyncRecord(
        syncingRecord.copyWith(
          syncStatus: SyncStatus.synced,
          cloudPath: cloudPath,
          lastSyncedAt: DateTime.now(),
          version: syncingRecord.version + 1,
        ),
      );

      // Update local record with synced data.
      await _saveLocalSyncRecord(syncedRecord);

      return Right(syncedRecord.toEntity());
    } on SyncException catch (e) {
      // Mark as error locally.
      await _markLocalRecordError(documentId, e.message);
      return Left(SyncFailure(message: e.message, code: e.code));
    } catch (e) {
      await _markLocalRecordError(documentId, e.toString());
      return Left(SyncFailure(
        message: 'Failed to sync document: ${e.toString()}',
        code: 7002,
      ));
    }
  }

  // ── Sync All ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<SyncRecord>>> syncAll() async {
    try {
      final pendingRecords = _getLocalSyncRecordsByStatus(SyncStatus.pending);
      final syncedRecords = <SyncRecord>[];

      for (final record in pendingRecords) {
        final result = await syncDocument(record.documentId);
        result.fold(
          (failure) {
            // Continue syncing other documents even if one fails.
            syncedRecords.add(record.copyWith(
              syncStatus: SyncStatus.error,
              errorMessage: failure.message,
            ));
          },
          (synced) {
            syncedRecords.add(synced);
          },
        );
      }

      return Right(syncedRecords);
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to sync all documents: ${e.toString()}',
        code: 7002,
      ));
    }
  }

  // ── Get Sync Status ────────────────────────────────────────────

  @override
  Future<Either<Failure, SyncRecord>> getSyncStatus(String documentId) async {
    try {
      // Try local first.
      final local = _getLocalSyncRecord(documentId);
      if (local != null) {
        return Right(local);
      }

      // Try remote.
      final remote = await _firestoreDatasource
          .getSyncRecordByDocumentId(documentId);
      await _saveLocalSyncRecord(remote);
      return Right(remote.toEntity());
    } on SyncException catch (e) {
      return Left(SyncFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to get sync status: ${e.toString()}',
        code: 7002,
      ));
    }
  }

  // ── Resolve Conflict ───────────────────────────────────────────

  @override
  Future<Either<Failure, SyncRecord>> resolveConflict(
    String documentId,
    String resolution,
  ) async {
    try {
      final local = _getLocalSyncRecord(documentId);
      if (local == null) {
        return Left(NotFoundFailure.document());
      }

      if (!local.hasConflict) {
        return Right(local);
      }

      SyncRecord resolved;

      switch (resolution) {
        case 'keep_local':
          // Upload local version, overwriting remote.
          resolved = local.copyWith(
            syncStatus: SyncStatus.synced,
            lastSyncedAt: DateTime.now(),
            version: local.version + 1,
            clearErrorMessage: true,
          );
          break;

        case 'keep_remote':
          // Download remote version, overwriting local.
          final remote = await _firestoreDatasource
              .getSyncRecordByDocumentId(documentId);
          resolved = remote.toEntity().copyWith(
            syncStatus: SyncStatus.synced,
            clearErrorMessage: true,
          );
          break;

        case 'keep_both':
          // Keep local as synced and create a new remote entry.
          resolved = local.copyWith(
            syncStatus: SyncStatus.synced,
            lastSyncedAt: DateTime.now(),
            version: local.version + 1,
            clearErrorMessage: true,
          );
          break;

        default:
          return Left(ValidationFailure.invalidFormat('Conflict resolution'));
      }

      // Update both local and remote.
      await _saveLocalSyncRecord(SyncRecordModel.fromEntity(resolved));
      await _firestoreDatasource.upsertSyncRecord(resolved);

      return Right(resolved);
    } on SyncException catch (e) {
      return Left(SyncFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to resolve conflict: ${e.toString()}',
        code: 7002,
      ));
    }
  }

  // ── Delete From Cloud ──────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> deleteFromCloud(String documentId) async {
    try {
      final local = _getLocalSyncRecord(documentId);

      // Delete files from cloud storage.
      await _storageDatasource.deleteAllFilesForDocument(documentId);

      // Delete sync metadata from Firestore.
      if (local != null) {
        await _firestoreDatasource.deleteSyncRecord(local.id);
      }

      // Update local record.
      if (local != null) {
        final updated = local.copyWith(
          syncStatus: SyncStatus.pending,
          cloudPath: '',
          clearCloudPath: true,
        );
        await _saveLocalSyncRecord(SyncRecordModel.fromEntity(updated));
      }

      return const Right(unit);
    } on SyncException catch (e) {
      return Left(SyncFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to delete from cloud: ${e.toString()}',
        code: 7002,
      ));
    }
  }

  // ── Download Document ──────────────────────────────────────────

  @override
  Future<Either<Failure, String>> downloadDocument(String documentId) async {
    try {
      final record = await _firestoreDatasource
          .getSyncRecordByDocumentId(documentId);

      if (record.cloudPath == null || record.cloudPath!.isEmpty) {
        return Left(SyncFailure(
          message: 'No cloud path found for document.',
          code: 7003,
        ));
      }

      // In a real implementation, the local path would come from
      // the app directory provider.
      final localPath = '/tmp/scanpro/downloads';

      final localFilePath = await _storageDatasource.downloadFile(
        cloudPath: record.cloudPath!,
        localPath: localPath,
      );

      // Update local sync record.
      await _saveLocalSyncRecord(record);

      return Right(localFilePath);
    } on SyncException catch (e) {
      return Left(SyncFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to download document: ${e.toString()}',
        code: 7003,
      ));
    }
  }

  // ── Get All Sync Records ───────────────────────────────────────

  @override
  Future<Either<Failure, List<SyncRecord>>> getAllSyncRecords() async {
    try {
      // Try to get from local Hive box first.
      final records = _getAllLocalSyncRecords();
      if (records.isNotEmpty) {
        return Right(records);
      }

      // If local is empty, fetch from Firestore.
      final remoteRecords = await _firestoreDatasource.getAllSyncRecords();

      // Cache locally.
      for (final model in remoteRecords) {
        await _saveLocalSyncRecord(model);
      }

      return Right(remoteRecords.map((m) => m.toEntity()).toList());
    } on SyncException catch (e) {
      return Left(SyncFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to get sync records: ${e.toString()}',
        code: 7002,
      ));
    }
  }

  // ── Storage Usage ──────────────────────────────────────────────

  @override
  Future<Either<Failure, int>> getStorageUsed() async {
    try {
      final used = await _firestoreDatasource.getStorageUsed();
      return Right(used);
    } on SyncException catch (e) {
      return Left(SyncFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to get storage usage: ${e.toString()}',
        code: 7002,
      ));
    }
  }

  @override
  Future<Either<Failure, int>> getStorageCapacity() async {
    try {
      final capacity = await _firestoreDatasource.getStorageCapacity();
      return Right(capacity);
    } on SyncException catch (e) {
      return Left(SyncFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to get storage capacity: ${e.toString()}',
        code: 7002,
      ));
    }
  }

  // ── Local Hive Helpers ─────────────────────────────────────────

  /// Saves a sync record model to the local Hive box.
  Future<void> _saveLocalSyncRecord(SyncRecordModel model) async {
    await _syncRecordsBox.put(model.documentId, model.toHive());
  }

  /// Gets a local sync record by document ID.
  SyncRecord? _getLocalSyncRecord(String documentId) {
    try {
      final value = _syncRecordsBox.get(documentId);
      if (value is Map) {
        return SyncRecordModel.fromHive(Map<dynamic, dynamic>.from(value))
            .toEntity();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Gets all local sync records.
  List<SyncRecord> _getAllLocalSyncRecords() {
    try {
      final records = <SyncRecord>[];
      for (final key in _syncRecordsBox.keys) {
        final value = _syncRecordsBox.get(key);
        if (value is Map) {
          records.add(
            SyncRecordModel.fromHive(Map<dynamic, dynamic>.from(value))
                .toEntity(),
          );
        }
      }
      return records;
    } catch (_) {
      return [];
    }
  }

  /// Gets local sync records filtered by status.
  List<SyncRecord> _getLocalSyncRecordsByStatus(SyncStatus status) {
    return _getAllLocalSyncRecords()
        .where((r) => r.syncStatus == status)
        .toList();
  }

  /// Marks a local sync record as errored.
  Future<void> _markLocalRecordError(
    String documentId,
    String errorMessage,
  ) async {
    final local = _getLocalSyncRecord(documentId);
    if (local != null) {
      final errored = local.copyWith(
        syncStatus: SyncStatus.error,
        errorMessage: errorMessage,
      );
      await _saveLocalSyncRecord(SyncRecordModel.fromEntity(errored));
    }
  }
}
