import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/sync_record.dart';
import '../models/sync_record_model.dart';

/// Stub implementation of Firestore data source for sync metadata.
///
/// Since Firebase is not available, this implementation stores sync
/// records in memory only. All data is lost when the app restarts.
/// All methods throw [SyncException] on failure so that the
/// repository implementation can convert them to [Failure]s.
class CloudFirestoreDatasource {
  CloudFirestoreDatasource();

  static const _uuid = Uuid();

  /// In-memory store for sync records.
  final Map<String, SyncRecordModel> _records = {};

  // ── Create / Update ────────────────────────────────────────────────

  /// Creates or updates a sync record.
  Future<SyncRecordModel> upsertSyncRecord(SyncRecord record) async {
    try {
      final id = record.id.isEmpty ? _uuid.v4() : record.id;
      final model = SyncRecordModel(
        id: id,
        documentId: record.documentId,
        syncStatus: record.syncStatus,
        lastSyncedAt: record.lastSyncedAt,
        version: record.version,
        cloudPath: record.cloudPath,
        errorMessage: record.errorMessage,
      );
      _records[id] = model;
      return model;
    } catch (e) {
      throw SyncException(
        message: 'Failed to upsert sync record: ${e.toString()}',
        code: 7002,
      );
    }
  }

  // ── Read ──────────────────────────────────────────────────────────

  /// Retrieves a sync record by document ID.
  ///
  /// Throws [SyncException] if not found.
  Future<SyncRecordModel> getSyncRecordByDocumentId(String documentId) async {
    try {
      for (final model in _records.values) {
        if (model.documentId == documentId) {
          return model;
        }
      }
      throw SyncException(
        message: 'Sync record for document "$documentId" not found.',
        code: 7001,
      );
    } on SyncException {
      rethrow;
    } catch (e) {
      throw SyncException(
        message: 'Failed to get sync record: ${e.toString()}',
        code: 7002,
      );
    }
  }

  /// Retrieves all sync records.
  Future<List<SyncRecordModel>> getAllSyncRecords() async {
    try {
      return _records.values.toList();
    } catch (e) {
      throw SyncException(
        message: 'Failed to get sync records: ${e.toString()}',
        code: 7002,
      );
    }
  }

  /// Retrieves all sync records with a specific status.
  Future<List<SyncRecordModel>> getSyncRecordsByStatus(
    SyncStatus status,
  ) async {
    try {
      final statusString = _statusToString(status);
      return _records.values
          .where((r) => _statusToString(r.syncStatus) == statusString)
          .toList();
    } catch (e) {
      throw SyncException(
        message: 'Failed to get sync records by status: ${e.toString()}',
        code: 7002,
      );
    }
  }

  // ── Delete ────────────────────────────────────────────────────────

  /// Deletes a sync record.
  Future<void> deleteSyncRecord(String id) async {
    try {
      _records.remove(id);
    } catch (e) {
      throw SyncException(
        message: 'Failed to delete sync record: ${e.toString()}',
        code: 7002,
      );
    }
  }

  // ── Conflict Detection ────────────────────────────────────────────

  /// Checks if a version conflict exists for a document.
  Future<bool> checkVersionConflict(
    String documentId,
    int localVersion,
  ) async {
    try {
      final record = await getSyncRecordByDocumentId(documentId);
      return record.version != localVersion;
    } on SyncException {
      return false;
    }
  }

  /// Increments the version number for a sync record.
  Future<SyncRecordModel> incrementVersion(String id) async {
    try {
      final current = _records[id];
      if (current == null) {
        throw SyncException(
          message: 'Sync record "$id" not found.',
          code: 7001,
        );
      }

      final updated = SyncRecordModel(
        id: current.id,
        documentId: current.documentId,
        syncStatus: SyncStatus.synced,
        lastSyncedAt: DateTime.now(),
        version: current.version + 1,
        cloudPath: current.cloudPath,
        errorMessage: null,
      );

      _records[id] = updated;
      return updated;
    } on SyncException {
      rethrow;
    } catch (e) {
      throw SyncException(
        message: 'Failed to increment version: ${e.toString()}',
        code: 7002,
      );
    }
  }

  // ── Storage ──────────────────────────────────────────────────────

  /// Gets the total storage used in bytes (stub: returns 0).
  Future<int> getStorageUsed() async {
    return 0;
  }

  /// Gets the total storage capacity in bytes.
  Future<int> getStorageCapacity() async {
    return AppConstants.maxCloudStorageMb * 1024 * 1024;
  }

  // ── Private Helpers ──────────────────────────────────────────────

  static String _statusToString(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.conflict:
        return 'conflict';
      case SyncStatus.error:
        return 'error';
    }
  }
}
