import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:scanpro/di/app_module.dart';
import 'package:scanpro/features/cloud_sync/data/datasources/cloud_firestore_datasource.dart';
import 'package:scanpro/features/cloud_sync/data/datasources/cloud_storage_datasource.dart';
import 'package:scanpro/features/cloud_sync/data/repositories/cloud_sync_repository_impl.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_record.dart';
import 'package:scanpro/features/cloud_sync/domain/repositories/cloud_sync_repository.dart';
import 'package:scanpro/features/cloud_sync/domain/usecases/resolve_conflict_usecase.dart';
import 'package:scanpro/features/cloud_sync/domain/usecases/sync_document_usecase.dart';

// ═══════════════════════════════════════════════════════════════════
//  Datasource Providers
// ═══════════════════════════════════════════════════════════════════

/// Provides the [CloudFirestoreDatasource] (stub).
final cloudFirestoreDatasourceProvider = Provider<CloudFirestoreDatasource>(
  (ref) {
    return CloudFirestoreDatasource();
  },
);

/// Provides the [CloudStorageDatasource] (stub).
final cloudStorageDatasourceProvider = Provider<CloudStorageDatasource>(
  (ref) {
    return CloudStorageDatasource();
  },
);

// ═══════════════════════════════════════════════════════════════════
//  Repository Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the [CloudSyncRepository] implementation.
final cloudSyncRepositoryProvider = Provider<CloudSyncRepository>((ref) {
  final syncRecordsBox = ref.watch(syncRecordsBoxProvider);
  return CloudSyncRepositoryImpl(
    firestoreDatasource: ref.watch(cloudFirestoreDatasourceProvider),
    storageDatasource: ref.watch(cloudStorageDatasourceProvider),
    syncRecordsBox: syncRecordsBox,
  );
});

// ═══════════════════════════════════════════════════════════════════
//  Use Case Providers
// ═══════════════════════════════════════════════════════════════════

/// Provides the [SyncDocumentUseCase].
final syncDocumentUseCaseProvider = Provider<SyncDocumentUseCase>((ref) {
  return SyncDocumentUseCase(ref.watch(cloudSyncRepositoryProvider));
});

/// Provides the [ResolveConflictUseCase].
final resolveConflictUseCaseProvider = Provider<ResolveConflictUseCase>((ref) {
  return ResolveConflictUseCase(ref.watch(cloudSyncRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════
//  Cloud Sync State
// ═══════════════════════════════════════════════════════════════════

/// Possible states for cloud sync operations.
enum CloudSyncStatus {
  idle,
  loading,
  syncing,
  success,
  error,
}

/// State holder for the cloud sync feature.
class CloudSyncState {
  final CloudSyncStatus status;
  final List<SyncRecord> syncRecords;
  final String? errorMessage;
  final DateTime? lastSyncTime;
  final int storageUsedBytes;
  final int storageCapacityBytes;
  final String? syncingDocumentId;

  const CloudSyncState({
    this.status = CloudSyncStatus.idle,
    this.syncRecords = const [],
    this.errorMessage,
    this.lastSyncTime,
    this.storageUsedBytes = 0,
    this.storageCapacityBytes = 2147483648, // 2 GB
    this.syncingDocumentId,
  });

  CloudSyncState copyWith({
    CloudSyncStatus? status,
    List<SyncRecord>? syncRecords,
    String? errorMessage,
    DateTime? lastSyncTime,
    int? storageUsedBytes,
    int? storageCapacityBytes,
    String? syncingDocumentId,
    bool clearErrorMessage = false,
    bool clearSyncingDocumentId = false,
  }) {
    return CloudSyncState(
      status: status ?? this.status,
      syncRecords: syncRecords ?? this.syncRecords,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      storageUsedBytes: storageUsedBytes ?? this.storageUsedBytes,
      storageCapacityBytes: storageCapacityBytes ?? this.storageCapacityBytes,
      syncingDocumentId: clearSyncingDocumentId
          ? null
          : (syncingDocumentId ?? this.syncingDocumentId),
    );
  }

  /// Number of synced documents.
  int get syncedCount =>
      syncRecords.where((r) => r.syncStatus == SyncStatus.synced).length;

  /// Number of pending documents.
  int get pendingCount =>
      syncRecords.where((r) => r.syncStatus == SyncStatus.pending).length;

  /// Number of conflicting documents.
  int get conflictCount =>
      syncRecords.where((r) => r.syncStatus == SyncStatus.conflict).length;

  /// Number of errored documents.
  int get errorCount =>
      syncRecords.where((r) => r.syncStatus == SyncStatus.error).length;

  /// Storage used as a fraction (0.0 – 1.0).
  double get storageUsedFraction {
    if (storageCapacityBytes == 0) return 0.0;
    return storageUsedBytes / storageCapacityBytes;
  }

  /// Storage used in MB.
  double get storageUsedMb => storageUsedBytes / (1024 * 1024);

  /// Storage capacity in MB.
  double get storageCapacityMb => storageCapacityBytes / (1024 * 1024);

  /// Whether a sync is in progress.
  bool get isSyncing => status == CloudSyncStatus.syncing;
}

/// State notifier for the cloud sync feature.
class CloudSyncNotifier extends StateNotifier<CloudSyncState> {
  CloudSyncNotifier({
    required CloudSyncRepository repository,
    required SyncDocumentUseCase syncDocumentUseCase,
    required ResolveConflictUseCase resolveConflictUseCase,
  })  : _repository = repository,
        _syncDocumentUseCase = syncDocumentUseCase,
        _resolveConflictUseCase = resolveConflictUseCase,
        super(const CloudSyncState());

  final CloudSyncRepository _repository;
  final SyncDocumentUseCase _syncDocumentUseCase;
  final ResolveConflictUseCase _resolveConflictUseCase;

  /// Loads all sync records and storage info.
  Future<void> loadSyncData() async {
    state = state.copyWith(status: CloudSyncStatus.loading);

    // Load sync records.
    final recordsResult = await _repository.getAllSyncRecords();

    // Load storage info.
    final usedResult = await _repository.getStorageUsed();
    final capacityResult = await _repository.getStorageCapacity();

    recordsResult.fold(
      (failure) {
        state = state.copyWith(
          status: CloudSyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (records) {
        int usedBytes = 0;
        int capacityBytes = state.storageCapacityBytes;

        usedResult.fold(
          (failure) {},
          (used) => usedBytes = used,
        );
        capacityResult.fold(
          (failure) {},
          (capacity) => capacityBytes = capacity,
        );

        // Find the most recent sync time.
        DateTime? lastSync;
        for (final record in records) {
          if (record.lastSyncedAt != null) {
            if (lastSync == null ||
                record.lastSyncedAt!.isAfter(lastSync)) {
              lastSync = record.lastSyncedAt;
            }
          }
        }

        state = state.copyWith(
          status: CloudSyncStatus.success,
          syncRecords: records,
          lastSyncTime: lastSync,
          storageUsedBytes: usedBytes,
          storageCapacityBytes: capacityBytes,
        );
      },
    );
  }

  /// Syncs a single document.
  Future<bool> syncDocument(String documentId) async {
    state = state.copyWith(
      status: CloudSyncStatus.syncing,
      syncingDocumentId: documentId,
    );

    final result = await _syncDocumentUseCase(documentId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: CloudSyncStatus.error,
          errorMessage: failure.message,
          clearSyncingDocumentId: true,
        );
        return false;
      },
      (syncRecord) {
        final updatedRecords = state.syncRecords
            .where((r) => r.documentId != documentId)
            .toList();
        updatedRecords.add(syncRecord);

        state = state.copyWith(
          status: CloudSyncStatus.success,
          syncRecords: updatedRecords,
          lastSyncTime: DateTime.now(),
          clearSyncingDocumentId: true,
        );
        return true;
      },
    );
  }

  /// Syncs all pending documents.
  Future<void> syncAll() async {
    state = state.copyWith(status: CloudSyncStatus.syncing);

    final result = await _syncDocumentUseCase.syncAll();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: CloudSyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (records) {
        state = state.copyWith(
          status: CloudSyncStatus.success,
          syncRecords: records,
          lastSyncTime: DateTime.now(),
        );
      },
    );
  }

  /// Resolves a conflict for a document.
  Future<bool> resolveConflict(String documentId, String resolution) async {
    state = state.copyWith(status: CloudSyncStatus.loading);

    final result = await _resolveConflictUseCase(documentId, resolution);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: CloudSyncStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (syncRecord) {
        final updatedRecords = state.syncRecords
            .where((r) => r.documentId != documentId)
            .toList();
        updatedRecords.add(syncRecord);

        state = state.copyWith(
          status: CloudSyncStatus.success,
          syncRecords: updatedRecords,
        );
        return true;
      },
    );
  }

  /// Deletes a document from the cloud.
  Future<void> deleteFromCloud(String documentId) async {
    final result = await _repository.deleteFromCloud(documentId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: CloudSyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        final updatedRecords = state.syncRecords
            .where((r) => r.documentId != documentId)
            .toList();
        state = state.copyWith(syncRecords: updatedRecords);
      },
    );
  }

  /// Clears any error message.
  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }
}

/// Provider for the [CloudSyncNotifier].
final cloudSyncProvider =
    StateNotifierProvider<CloudSyncNotifier, CloudSyncState>((ref) {
  return CloudSyncNotifier(
    repository: ref.watch(cloudSyncRepositoryProvider),
    syncDocumentUseCase: ref.watch(syncDocumentUseCaseProvider),
    resolveConflictUseCase: ref.watch(resolveConflictUseCaseProvider),
  );
});
