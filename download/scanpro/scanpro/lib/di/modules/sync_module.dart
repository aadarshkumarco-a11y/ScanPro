/// Sync feature module — provides all Riverpod providers related to
/// cloud synchronization of documents, folders, and OCR results.
///
/// Handles conflict resolution, incremental sync, offline queuing,
/// and real-time sync status monitoring via Firebase Firestore.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/sync_repository.dart';
import '../../domain/usecases/sync/sync_documents_usecase.dart';
import '../../domain/usecases/sync/resolve_conflict_usecase.dart';
import '../../domain/usecases/sync/get_sync_status_usecase.dart';
import '../../data/datasources/sync_remote_data_source.dart';
import '../../data/datasources/sync_local_data_source.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../injection.dart';

// ---------------------------------------------------------------------------
// Data Sources
// ---------------------------------------------------------------------------

/// Remote data source that communicates with Firebase Firestore and
/// Firebase Storage for cloud document synchronization.
final syncRemoteDataSourceProvider = Provider<SyncRemoteDataSource>((ref) {
  return SyncRemoteDataSource();
});

/// Local data source that tracks sync state, dirty flags, and conflict
/// metadata in Hive.
final syncLocalDataSourceProvider = Provider<SyncLocalDataSource>((ref) {
  final box = ref.watch(hiveBoxProvider);
  return SyncLocalDataSource(box: box);
});

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

/// Core sync service that orchestrates upload, download, and conflict
/// resolution between local storage and Firebase.
final syncServiceProvider = Provider<SyncService>((ref) {
  final remoteDataSource = ref.watch(syncRemoteDataSourceProvider);
  final localDataSource = ref.watch(syncLocalDataSourceProvider);
  final isOnline = ref.watch(isOnlineProvider);
  return SyncService(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    isOnline: isOnline,
  );
});

/// Stream controller that broadcasts real-time sync progress events
/// to the UI layer. Watchers receive [SyncProgress] updates during
/// active synchronization.
final syncProgressProvider =
    StreamProvider.autoDispose<SyncProgress>((ref) async* {
  final syncService = ref.watch(syncServiceProvider);
  yield* syncService.progressStream;
});

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Primary [SyncRepository] implementation backed by the sync service,
/// remote Firestore data source, and local Hive data source.
final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final remoteDataSource = ref.watch(syncRemoteDataSourceProvider);
  final localDataSource = ref.watch(syncLocalDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  return SyncRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    syncService: syncService,
  );
});

// ---------------------------------------------------------------------------
// Use Cases
// ---------------------------------------------------------------------------

/// Performs an incremental sync: uploads locally modified documents,
/// downloads remotely changed documents, and queues conflicts for
/// manual resolution.
final syncDocumentsUseCaseProvider = Provider<SyncDocumentsUseCase>((ref) {
  final repository = ref.watch(syncRepositoryProvider);
  return SyncDocumentsUseCase(repository: repository);
});

/// Resolves a sync conflict using the specified strategy: keep local,
/// keep remote, or merge both versions.
final resolveConflictUseCaseProvider = Provider<ResolveConflictUseCase>((ref) {
  final repository = ref.watch(syncRepositoryProvider);
  return ResolveConflictUseCase(repository: repository);
});

/// Returns the current sync status: last sync timestamp, pending upload
/// count, pending download count, and unresolved conflicts.
final getSyncStatusUseCaseProvider = Provider<GetSyncStatusUseCase>((ref) {
  final repository = ref.watch(syncRepositoryProvider);
  return GetSyncStatusUseCase(repository: repository);
});

// ---------------------------------------------------------------------------
// Service Class & Models (inline for DI wiring)
// ---------------------------------------------------------------------------

/// Orchestrates bidirectional document synchronization with Firebase.
class SyncService {
  SyncService({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.isOnline,
  });

  final SyncRemoteDataSource remoteDataSource;
  final SyncLocalDataSource localDataSource;
  final bool isOnline;

  final _progressController = StreamController<SyncProgress>.broadcast();

  /// Emits real-time progress updates during active synchronization.
  Stream<SyncProgress> get progressStream => _progressController.stream;

  /// Starts an incremental sync cycle. Returns the final [SyncResult]
  /// when the operation completes or fails.
  Future<SyncResult> sync() async {
    if (!isOnline) {
      return const SyncResult(
        uploaded: 0,
        downloaded: 0,
        conflicts: 0,
        status: SyncStatus.offline,
      );
    }

    // Stub — production implementation delegates to remote/local data sources.
    throw UnimplementedError('SyncService.sync must be implemented');
  }

  /// Disposes the internal stream controller.
  void dispose() {
    _progressController.close();
  }
}

/// Progress event emitted during an active sync cycle.
class SyncProgress {
  const SyncProgress({
    required this.phase,
    required this.current,
    required this.total,
    required this.itemName,
  });

  /// Current phase of the sync operation.
  final SyncPhase phase;

  /// Zero-based index of the current item being processed.
  final int current;

  /// Total number of items in this phase.
  final int total;

  /// Display name of the item currently being synced.
  final String itemName;
}

/// Phases of a sync cycle.
enum SyncPhase { uploading, downloading, resolvingConflicts }

/// Final result of a completed sync operation.
class SyncResult {
  const SyncResult({
    required this.uploaded,
    required this.downloaded,
    required this.conflicts,
    required this.status,
  });

  /// Number of documents uploaded to the cloud.
  final int uploaded;

  /// Number of documents downloaded from the cloud.
  final int downloaded;

  /// Number of unresolved conflicts remaining.
  final int conflicts;

  /// Overall status of the sync operation.
  final SyncStatus status;
}

/// Status of a sync operation.
enum SyncStatus { success, partial, offline, error }
