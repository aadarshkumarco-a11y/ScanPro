import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/sync_provider.dart';
import '../widgets/sync_status_indicator.dart';
import '../widgets/conflict_resolution_card.dart';
import '../widgets/storage_usage_bar.dart';

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  @override
  void initState() {
    super.initState();
    // Load some mock conflicts for demo
    Future.microtask(() {
      ref.read(syncStatusProvider.notifier).loadMockConflicts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncStatusProvider);
    final storageInfo = ref.watch(storageInfoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Sync')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(syncStatusProvider.notifier).syncNow(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusCard(syncState, theme),
            const SizedBox(height: 16),
            _buildStorageCard(storageInfo, theme),
            const SizedBox(height: 16),
            _buildSyncNowButton(syncState, theme),
            const SizedBox(height: 8),
            _buildAutoSyncToggle(syncState, theme),
            if (syncState.conflicts.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildConflictsSection(syncState, theme),
            ],
            const SizedBox(height: 24),
            _buildHistorySection(syncState, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(SyncState syncState, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                SyncStatusIndicator(status: syncState.status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(syncState.status),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _statusSubtitle(syncState),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (syncState.status == SyncStatus.syncing) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: syncState.progress,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(syncState.progress * 100).toInt()}% — ${syncState.currentFile}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStorageCard(StorageInfo storageInfo, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cloud Storage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StorageUsageBar(
              usedBytes: storageInfo.usedBytes,
              totalBytes: storageInfo.totalBytes,
              usedLabel: storageInfo.usedFormatted,
              totalLabel: storageInfo.totalFormatted,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildSyncNowButton(SyncState syncState, ThemeData theme) {
    final isSyncing = syncState.status == SyncStatus.syncing;
    return FilledButton.icon(
      onPressed: isSyncing ? null : () => ref.read(syncStatusProvider.notifier).syncNow(),
      icon: isSyncing
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.sync),
      label: Text(isSyncing ? 'Syncing...' : 'Sync Now'),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildAutoSyncToggle(SyncState syncState, ThemeData theme) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(Icons.autorenew, color: theme.colorScheme.primary),
        title: const Text('Auto-Sync'),
        subtitle: const Text('Automatically sync when changes are detected'),
        value: syncState.autoSync,
        onChanged: (value) {
          ref.read(syncStatusProvider.notifier).toggleAutoSync(value);
        },
      ),
    );
  }

  Widget _buildConflictsSection(SyncState syncState, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sync Conflicts (${syncState.conflicts.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...syncState.conflicts.map(
          (conflict) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ConflictResolutionCard(
              conflict: conflict,
              onKeepLocal: () {
                ref.read(syncStatusProvider.notifier).resolveConflict(
                      conflict.id,
                      true,
                    );
              },
              onKeepRemote: () {
                ref.read(syncStatusProvider.notifier).resolveConflict(
                      conflict.id,
                      false,
                    );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(SyncState syncState, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sync History',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (syncState.history.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No sync history yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...syncState.history.map(
            (entry) => _buildHistoryEntry(entry, theme),
          ),
      ],
    );
  }

  Widget _buildHistoryEntry(SyncHistoryEntry entry, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          entry.status == SyncStatus.completed
              ? Icons.check_circle
              : Icons.error,
          color: entry.status == SyncStatus.completed
              ? Colors.green
              : theme.colorScheme.error,
        ),
        title: Text(
          '${entry.filesSynced} files synced',
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: Text(
          _formatDateTime(entry.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  String _statusLabel(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Ready to Sync';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.completed:
        return 'Sync Complete';
      case SyncStatus.failed:
        return 'Sync Failed';
      case SyncStatus.conflict:
        return 'Conflicts Found';
    }
  }

  String _statusSubtitle(SyncState state) {
    if (state.status == SyncStatus.completed && state.lastSyncTime != null) {
      return 'Last synced ${_formatDateTime(state.lastSyncTime!)}';
    }
    if (state.status == SyncStatus.failed) {
      return state.errorMessage.isNotEmpty
          ? state.errorMessage
          : 'An error occurred during sync';
    }
    if (state.lastSyncTime != null) {
      return 'Last synced ${_formatDateTime(state.lastSyncTime!)}';
    }
    return 'Tap "Sync Now" to start';
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
