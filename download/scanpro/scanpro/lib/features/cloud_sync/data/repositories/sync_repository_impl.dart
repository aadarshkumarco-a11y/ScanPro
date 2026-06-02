import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_record.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_status.dart';
import 'package:scanpro/features/cloud_sync/domain/repositories/sync_repository.dart';
import 'package:scanpro/features/cloud_sync/data/models/sync_record_model.dart';
import 'package:scanpro/features/cloud_sync/data/services/firebase_sync_service.dart';
import 'package:scanpro/features/scanner/data/models/scan_document_model.dart';

/// Implementation of [SyncRepository] using Firebase Firestore.
///
/// Manages the synchronization of local document changes with
/// Firestore, including conflict detection and resolution.
class SyncRepositoryImpl implements SyncRepository {
  final FirebaseSyncService _firebaseSyncService;
  final Box<SyncRecordModel> _syncRecordBox;
  final Box<ScanDocumentModel> _documentBox;
  final FirebaseFirestore _firestore;

  static const String _documentsCollection = 'documents';
  static const String _syncMetaCollection = 'sync_meta';

  SyncRepositoryImpl({
    required FirebaseSyncService firebaseSyncService,
    required Box<SyncRecordModel> syncRecordBox,
    required Box<ScanDocumentModel> documentBox,
    required FirebaseFirestore firestore,
  })  : _firebaseSyncService = firebaseSyncService,
        _syncRecordBox = syncRecordBox,
        _documentBox = documentBox,
        _firestore = firestore;

  @override
  Future<Either<Failure, ScanDocument>> syncDocument(
    ScanDocument document,
  ) async {
    try {
      final model = ScanDocumentModel.fromEntity(document);

      await _firebaseSyncService.uploadDocument(model.toJson());

      final syncedDoc = document.copyWith(
        syncStatus: SyncStatus.synced,
        updatedAt: DateTime.now(),
      );

      await _documentBox.put(
        document.id,
        ScanDocumentModel.fromEntity(syncedDoc),
      );

      return Right(syncedDoc);
    } on FirebaseSyncException catch (e) {
      if (e.isConflict) {
        final updatedDoc = document.copyWith(
          syncStatus: SyncStatus.conflict,
        );
        return Left(
          ConflictFailure(message: 'Sync conflict detected: ${e.message}'),
        );
      }
      return Left(SyncFailure(message: e.message));
    } catch (e) {
      return Left(SyncFailure(message: 'Failed to sync document: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SyncRecord>>> syncAll() async {
    try {
      final pendingRecords = _syncRecordBox.values
          .where((model) =>
              model.statusIndex ==
                  SyncRecordStatus.pending.index ||
              model.statusIndex ==
                  SyncRecordStatus.failed.index)
          .toList();

      final processedRecords = <SyncRecord>[];

      for (final recordModel in pendingRecords) {
        final record = recordModel.toEntity();

        if (!record.canRetry && record.status == SyncRecordStatus.failed) {
          continue;
        }

        try {
          final updatedRecord = record.copyWith(
            status: SyncRecordStatus.inProgress,
          );
          await _updateSyncRecord(updatedRecord);

          final docModel = _documentBox.get(record.documentId);
          if (docModel == null) continue;

          await _firebaseSyncService.uploadDocument(docModel.toJson());

          final completedRecord = updatedRecord.copyWith(
            status: SyncRecordStatus.completed,
          );
          await _updateSyncRecord(completedRecord);
          processedRecords.add(completedRecord);
        } on FirebaseSyncException catch (e) {
          if (e.isConflict) {
            final conflictRecord = record.copyWith(
              status: SyncRecordStatus.conflict,
              conflictData: {'remoteData': e.remoteData},
            );
            await _updateSyncRecord(conflictRecord);
            processedRecords.add(conflictRecord);
          } else {
            final failedRecord = record.copyWith(
              status: SyncRecordStatus.failed,
              retryCount: record.retryCount + 1,
            );
            await _updateSyncRecord(failedRecord);
          }
        }
      }

      await _downloadRemoteChanges();

      return Right(processedRecords);
    } catch (e) {
      return Left(SyncFailure(message: 'Failed to sync all: $e'));
    }
  }

  @override
  Future<Either<Failure, SyncStatus>> getSyncStatus() async {
    try {
      final hasPending = _syncRecordBox.values.any(
        (model) => model.statusIndex == SyncRecordStatus.pending.index,
      );
      final hasConflicts = _syncRecordBox.values.any(
        (model) => model.statusIndex == SyncRecordStatus.conflict.index,
      );
      final hasFailed = _syncRecordBox.values.any(
        (model) => model.statusIndex == SyncRecordStatus.failed.index,
      );

      if (hasConflicts) return const Right(SyncStatus.conflict);
      if (hasPending) return const Right(SyncStatus.syncing);
      if (hasFailed) return const Right(SyncStatus.failed);
      return const Right(SyncStatus.completed);
    } catch (e) {
      return Left(SyncFailure(message: 'Failed to get sync status: $e'));
    }
  }

  @override
  Future<Either<Failure, SyncRecord>> resolveConflict(
    String recordId,
    bool useLocalVersion,
  ) async {
    try {
      final model = _syncRecordBox.get(recordId);
      if (model == null) {
        return Left(
          NotFoundFailure(message: 'Sync record not found: $recordId'),
        );
      }

      final record = model.toEntity();

      if (useLocalVersion) {
        final docModel = _documentBox.get(record.documentId);
        if (docModel != null) {
          await _firebaseSyncService.uploadDocument(
            docModel.toJson(),
            forceOverwrite: true,
          );
        }
      } else {
        final remoteData = record.conflictData?['remoteData'];
        if (remoteData != null) {
          final remoteModel = ScanDocumentModel.fromJson(
            Map<String, dynamic>.from(remoteData as Map),
          );
          await _documentBox.put(record.documentId, remoteModel);
        }
      }

      final resolvedRecord = record.copyWith(
        status: SyncRecordStatus.completed,
        conflictData: null,
      );
      await _updateSyncRecord(resolvedRecord);

      return Right(resolvedRecord);
    } on FirebaseSyncException catch (e) {
      return Left(SyncFailure(message: e.message));
    } catch (e) {
      return Left(
        SyncFailure(message: 'Failed to resolve conflict: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getLastSyncTime() async {
    try {
      final doc = await _firestore
          .collection(_syncMetaCollection)
          .doc('last_sync')
          .get();

      if (!doc.exists || doc.data() == null) {
        return const Right(null);
      }

      final timestamp = doc.data()!['timestamp'] as String?;
      if (timestamp == null) return const Right(null);

      return Right(DateTime.parse(timestamp));
    } catch (e) {
      return Left(
        SyncFailure(message: 'Failed to get last sync time: $e'),
      );
    }
  }

  /// Updates a sync record in the local Hive box.
  Future<void> _updateSyncRecord(SyncRecord record) async {
    await _syncRecordBox.put(
      record.id,
      SyncRecordModel.fromEntity(record),
    );
  }

  /// Downloads and applies remote changes from Firestore.
  Future<void> _downloadRemoteChanges() async {
    final lastSync = await getLastSyncTime();
    lastSync.fold(
      (_) {},
      (lastSyncTime) async {
        final changes = await _firebaseSyncService.downloadChanges(
          since: lastSyncTime,
        );
        for (final change in changes) {
          final model = ScanDocumentModel.fromJson(change);
          await _documentBox.put(model.id, model);
        }
        await _firestore
            .collection(_syncMetaCollection)
            .doc('last_sync')
            .set({
          'timestamp': DateTime.now().toIso8601String(),
        });
      },
    );
  }
}
