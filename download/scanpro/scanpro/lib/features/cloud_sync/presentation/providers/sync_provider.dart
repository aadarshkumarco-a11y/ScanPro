import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncStatus { idle, syncing, completed, failed, conflict }

class SyncConflict {
  final String id;
  final String fileName;
  final DateTime localModified;
  final DateTime remoteModified;
  final String localSize;
  final String remoteSize;

  const SyncConflict({
    required this.id,
    required this.fileName,
    required this.localModified,
    required this.remoteModified,
    required this.localSize,
    required this.remoteSize,
  });
}

class SyncHistoryEntry {
  final String id;
  final DateTime timestamp;
  final SyncStatus status;
  final int filesSynced;
  final String? errorMessage;

  const SyncHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.status,
    this.filesSynced = 0,
    this.errorMessage,
  });
}

class SyncState {
  final SyncStatus status;
  final double progress;
  final String currentFile;
  final DateTime? lastSyncTime;
  final List<SyncConflict> conflicts;
  final List<SyncHistoryEntry> history;
  final bool autoSync;
  final String errorMessage;

  const SyncState({
    this.status = SyncStatus.idle,
    this.progress = 0.0,
    this.currentFile = '',
    this.lastSyncTime,
    this.conflicts = const [],
    this.history = const [],
    this.autoSync = true,
    this.errorMessage = '',
  });

  SyncState copyWith({
    SyncStatus? status,
    double? progress,
    String? currentFile,
    DateTime? lastSyncTime,
    List<SyncConflict>? conflicts,
    List<SyncHistoryEntry>? history,
    bool? autoSync,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentFile: currentFile ?? this.currentFile,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      conflicts: conflicts ?? this.conflicts,
      history: history ?? this.history,
      autoSync: autoSync ?? this.autoSync,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class StorageInfo {
  final int usedBytes;
  final int totalBytes;

  const StorageInfo({required this.usedBytes, required this.totalBytes});

  double get usageFraction => totalBytes > 0 ? usedBytes / totalBytes : 0;
  String get usedFormatted => _formatBytes(usedBytes);
  String get totalFormatted => _formatBytes(totalBytes);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(const SyncState());

  Future<void> syncNow() async {
    state = state.copyWith(
      status: SyncStatus.syncing,
      progress: 0.0,
      errorMessage: '',
    );

    final fileNames = [
      'report_2024.pdf',
      'invoice_march.pdf',
      'contract_draft.pdf',
      'notes_april.pdf',
      'receipt_001.pdf',
    ];

    for (int i = 0; i < fileNames.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(
        currentFile: fileNames[i],
        progress: (i + 1) / fileNames.length,
      );
    }

    final hasConflicts = state.conflicts.isNotEmpty;
    state = state.copyWith(
      status: hasConflicts ? SyncStatus.conflict : SyncStatus.completed,
      progress: 1.0,
      currentFile: '',
      lastSyncTime: DateTime.now(),
    );

    final entry = SyncHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      status: state.status,
      filesSynced: fileNames.length,
    );
    state = state.copyWith(
      history: [entry, ...state.history],
    );
  }

  void toggleAutoSync(bool value) {
    state = state.copyWith(autoSync: value);
  }

  void resolveConflict(String conflictId, bool keepLocal) {
    final updatedConflicts =
        state.conflicts.where((c) => c.id != conflictId).toList();
    state = state.copyWith(
      conflicts: updatedConflicts,
      status: updatedConflicts.isEmpty ? SyncStatus.completed : SyncStatus.conflict,
    );
  }

  void loadMockConflicts() {
    state = state.copyWith(
      conflicts: [
        SyncConflict(
          id: '1',
          fileName: 'budget_2024.pdf',
          localModified: DateTime(2024, 3, 1, 14, 30),
          remoteModified: DateTime(2024, 3, 1, 14, 25),
          localSize: '2.4 MB',
          remoteSize: '2.1 MB',
        ),
        SyncConflict(
          id: '2',
          fileName: 'meeting_notes.pdf',
          localModified: DateTime(2024, 3, 2, 9, 0),
          remoteModified: DateTime(2024, 3, 2, 9, 15),
          localSize: '156 KB',
          remoteSize: '180 KB',
        ),
      ],
    );
  }
}

final syncStatusProvider = StateNotifierProvider<SyncNotifier, SyncState>(
  (ref) => SyncNotifier(),
);

final syncProgressProvider = Provider<(double, String)>((ref) {
  final state = ref.watch(syncStatusProvider);
  return (state.progress, state.currentFile);
});

final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  return ref.watch(syncStatusProvider).lastSyncTime;
});

final conflictListProvider = Provider<List<SyncConflict>>((ref) {
  return ref.watch(syncStatusProvider).conflicts;
});

final storageInfoProvider = Provider<StorageInfo>((ref) {
  return const StorageInfo(usedBytes: 3221225472, totalBytes: 5368709120);
});
