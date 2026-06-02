import 'package:equatable/equatable.dart';

/// Enum representing the synchronization status of a document.
enum SyncStatus {
  /// The document has local changes that have not been synced.
  pending,

  /// The document is fully synchronized with the cloud.
  synced,

  /// A conflict was detected between local and remote versions.
  conflict,

  /// An error occurred during the last sync attempt.
  error,
}

/// Domain entity representing the sync state of a document.
///
/// Tracks the synchronization status, last sync timestamp,
/// version number, and cloud storage path for each document
/// that participates in cloud sync.
class SyncRecord extends Equatable {
  const SyncRecord({
    required this.id,
    required this.documentId,
    required this.syncStatus,
    this.lastSyncedAt,
    required this.version,
    this.cloudPath,
    this.errorMessage,
  });

  /// Unique identifier for this sync record.
  final String id;

  /// ID of the document this record tracks.
  final String documentId;

  /// Current sync status.
  final SyncStatus syncStatus;

  /// Timestamp of the last successful sync.
  /// Null if the document has never been synced.
  final DateTime? lastSyncedAt;

  /// Version number incremented on each successful sync.
  /// Used for conflict detection (optimistic concurrency).
  final int version;

  /// Cloud storage path where the document is stored.
  /// Null if the document has not yet been uploaded.
  final String? cloudPath;

  /// Error message if [syncStatus] is [SyncStatus.error].
  final String? errorMessage;

  /// Creates a copy with optional field overrides.
  SyncRecord copyWith({
    String? id,
    String? documentId,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    int? version,
    String? cloudPath,
    String? errorMessage,
    bool clearLastSyncedAt = false,
    bool clearCloudPath = false,
    bool clearErrorMessage = false,
  }) {
    return SyncRecord(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: clearLastSyncedAt ? null : (lastSyncedAt ?? this.lastSyncedAt),
      version: version ?? this.version,
      cloudPath: clearCloudPath ? null : (cloudPath ?? this.cloudPath),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Whether this record has pending changes to sync.
  bool get isPending => syncStatus == SyncStatus.pending;

  /// Whether this record is fully synchronized.
  bool get isSynced => syncStatus == SyncStatus.synced;

  /// Whether there is a sync conflict.
  bool get hasConflict => syncStatus == SyncStatus.conflict;

  /// Whether the last sync attempt failed.
  bool get hasError => syncStatus == SyncStatus.error;

  /// Whether this document has ever been synced.
  bool get hasSyncedBefore => lastSyncedAt != null;

  @override
  List<Object?> get props => [
        id,
        documentId,
        syncStatus,
        lastSyncedAt,
        version,
        cloudPath,
        errorMessage,
      ];
}
