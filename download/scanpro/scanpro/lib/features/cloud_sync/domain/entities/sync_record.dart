import 'package:equatable/equatable.dart';

/// Enumeration of sync operation types.
enum SyncOperation {
  /// Document was created locally.
  create,

  /// Document was updated locally.
  update,

  /// Document was deleted locally.
  delete,
}

/// Enumeration of sync record statuses.
enum SyncRecordStatus {
  /// Operation is pending upload to the server.
  pending,

  /// Operation is currently being synced.
  inProgress,

  /// Operation was successfully synced.
  completed,

  /// Operation failed to sync.
  failed,

  /// A conflict was detected between local and remote data.
  conflict,
}

/// Entity representing a single sync operation record.
///
/// Tracks the state of each local change that needs to be
/// synchronized with the cloud, including conflict information.
class SyncRecord extends Equatable {
  /// Unique identifier for this sync record.
  final String id;

  /// ID of the document being synced.
  final String documentId;

  /// Type of operation that triggered the sync.
  final SyncOperation operation;

  /// Timestamp when the sync record was created.
  final DateTime timestamp;

  /// Current status of the sync operation.
  final SyncRecordStatus status;

  /// Serialized conflict data from the server, null if no conflict.
  final Map<String, dynamic>? conflictData;

  /// Number of retry attempts for failed syncs.
  final int retryCount;

  const SyncRecord({
    required this.id,
    required this.documentId,
    required this.operation,
    required this.timestamp,
    this.status = SyncRecordStatus.pending,
    this.conflictData,
    this.retryCount = 0,
  });

  /// Whether this record is in a conflict state.
  bool get hasConflict => status == SyncRecordStatus.conflict;

  /// Whether this record can be retried.
  bool get canRetry =>
      status == SyncRecordStatus.failed && retryCount < 3;

  /// Creates a copy with optional field overrides.
  SyncRecord copyWith({
    String? id,
    String? documentId,
    SyncOperation? operation,
    DateTime? timestamp,
    SyncRecordStatus? status,
    Map<String, dynamic>? conflictData,
    int? retryCount,
  }) {
    return SyncRecord(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      operation: operation ?? this.operation,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      conflictData: conflictData ?? this.conflictData,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        operation,
        timestamp,
        status,
        conflictData,
        retryCount,
      ];
}
