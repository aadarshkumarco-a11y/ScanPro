/// Enumeration of overall synchronization statuses.
///
/// Represents the high-level state of the cloud sync system
/// as observed by the UI layer.
enum SyncStatus {
  /// No sync is currently in progress.
  idle,

  /// A sync operation is currently running.
  syncing,

  /// The last sync operation completed successfully.
  completed,

  /// The last sync operation failed.
  failed,

  /// A conflict was detected that requires user resolution.
  conflict,
}
