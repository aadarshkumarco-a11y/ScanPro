import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/sync_record.dart';
import '../../domain/usecases/resolve_conflict_usecase.dart';
import '../providers/cloud_sync_provider.dart';

/// Cloud sync dashboard screen.
///
/// Displays sync status overview, last sync time, storage usage,
/// a "Sync Now" button, and a list of synced/pending/conflicting
/// documents with actions for each.
class CloudSyncScreen extends ConsumerStatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  ConsumerState<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends ConsumerState<CloudSyncScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(cloudSyncProvider.notifier).loadSyncData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const primaryColor = Color(0xFF4D2DAB);
    final syncState = ref.watch(cloudSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(cloudSyncProvider.notifier).loadSyncData(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () =>
            ref.read(cloudSyncProvider.notifier).loadSyncData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sync Status Header ─────────────────────────────
              _buildSyncStatusHeader(theme, colorScheme, primaryColor, syncState),

              const SizedBox(height: 16),

              // ── Storage Usage Card ─────────────────────────────
              _buildStorageCard(theme, colorScheme, primaryColor, syncState),

              const SizedBox(height: 16),

              // ── Quick Stats Row ────────────────────────────────
              _buildQuickStatsRow(theme, colorScheme, primaryColor, syncState),

              const SizedBox(height: 16),

              // ── Error Banner ──────────────────────────────────
              if (syncState.errorMessage != null)
                _buildErrorBanner(theme, colorScheme, syncState),

              // ── Sync Now Button ───────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: syncState.isSyncing
                      ? null
                      : () =>
                          ref.read(cloudSyncProvider.notifier).syncAll(),
                  icon: syncState.isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_sync_rounded, size: 22),
                  label: Text(
                    syncState.isSyncing ? 'Syncing...' : 'Sync Now',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Documents Section Header ───────────────────────
              Row(
                children: [
                  Text(
                    'Synced Documents',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${syncState.syncRecords.length} total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Documents List ─────────────────────────────────
              if (syncState.syncRecords.isEmpty)
                _buildEmptyState(theme, colorScheme, primaryColor)
              else
                ...syncState.syncRecords.map(
                  (record) => _buildSyncRecordCard(
                    theme,
                    colorScheme,
                    primaryColor,
                    record,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the sync status header card with gradient background.
  Widget _buildSyncStatusHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
    CloudSyncState state,
  ) {
    final isAllSynced = state.pendingCount == 0 &&
        state.conflictCount == 0 &&
        state.errorCount == 0 &&
        state.syncRecords.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAllSynced
              ? [const Color(0xFF4D2DAB), const Color(0xFF6B4EC0)]
              : [const Color(0xFF4D2DAB), const Color(0xFF7B5FC7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isAllSynced
                      ? Icons.cloud_done_rounded
                      : state.isSyncing
                          ? Icons.cloud_sync_rounded
                          : state.conflictCount > 0
                              ? Icons.cloud_off_rounded
                              : Icons.cloud_queue_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAllSynced
                          ? 'All Synced'
                          : state.isSyncing
                              ? 'Syncing...'
                              : state.conflictCount > 0
                                  ? 'Conflicts Detected'
                                  : 'Ready to Sync',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.lastSyncTime != null
                          ? 'Last sync: ${DateFormat(AppConstants.displayDateTimeFormat).format(state.lastSyncTime!)}'
                          : 'Never synced',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ),
        ],
      ),
    );
  }

  /// Builds the storage usage card.
  Widget _buildStorageCard(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
    CloudSyncState state,
  ) {
    final usedFraction = state.storageUsedFraction.clamp(0.0, 1.0);
    final isNearLimit = usedFraction > 0.85;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage_rounded,
                  color: isNearLimit ? colorScheme.error : primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cloud Storage',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${state.storageUsedMb.toStringAsFixed(1)} / ${state.storageCapacityMb.toStringAsFixed(0)} MB',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isNearLimit ? colorScheme.error : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: usedFraction,
                minHeight: 8,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isNearLimit ? colorScheme.error : primaryColor,
                ),
              ),
            ),
            if (isNearLimit) ...[
              const SizedBox(height: 8),
              Text(
                'Storage almost full! Consider upgrading or removing files.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the quick stats row with stat cards.
  Widget _buildQuickStatsRow(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
    CloudSyncState state,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            colorScheme,
            Icons.cloud_done_rounded,
            'Synced',
            state.syncedCount,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            theme,
            colorScheme,
            Icons.cloud_upload_rounded,
            'Pending',
            state.pendingCount,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            theme,
            colorScheme,
            Icons.warning_amber_rounded,
            'Conflicts',
            state.conflictCount,
            Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            theme,
            colorScheme,
            Icons.error_outline_rounded,
            'Errors',
            state.errorCount,
            colorScheme.error,
          ),
        ),
      ],
    );
  }

  /// Builds a single stat card.
  Widget _buildStatCard(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String label,
    int count,
    Color accentColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: accentColor, size: 22),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the error banner.
  Widget _buildErrorBanner(
    ThemeData theme,
    ColorScheme colorScheme,
    CloudSyncState state,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(cloudSyncProvider.notifier).clearError(),
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onErrorContainer,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty state when no sync records exist.
  Widget _buildEmptyState(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Synced Documents',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Documents you sync to the cloud will appear here. '
              'Tap "Sync Now" to get started.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single sync record card.
  Widget _buildSyncRecordCard(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
    SyncRecord record,
  ) {
    final statusColor = _statusColor(record.syncStatus);
    final statusIcon = _statusIcon(record.syncStatus);
    final statusLabel = _statusLabel(record.syncStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: record.hasConflict
            ? () => _showConflictDialog(context, primaryColor, record)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status icon.
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),

              // Document details.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Document ${record.documentId.substring(0, 8)}...',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'v${record.version}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (record.lastSyncedAt != null)
                          Text(
                            DateFormat(AppConstants.displayDateTimeFormat)
                                .format(record.lastSyncedAt!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    ),
                    if (record.errorMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        record.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Actions.
              if (record.hasConflict)
                IconButton(
                  onPressed: () =>
                      _showConflictDialog(context, primaryColor, record),
                  icon: Icon(
                    Icons.warning_amber_rounded,
                    color: statusColor,
                    size: 22,
                  ),
                ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) => _handleMenuAction(value, record),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'sync',
                    child: Row(
                      children: [
                        Icon(Icons.cloud_sync_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Sync Now'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.cloud_download_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Download'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 18, color: Color(0xFFD32F2F)),
                        SizedBox(width: 8),
                        Text('Remove from Cloud', style: TextStyle(color: Color(0xFFD32F2F))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a conflict resolution dialog.
  void _showConflictDialog(
    BuildContext context,
    Color primaryColor,
    SyncRecord record,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Sync Conflict'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A conflict was detected for document '
              '${record.documentId.substring(0, 8)}... '
              '(local v${record.version} vs remote).',
            ),
            const SizedBox(height: 16),
            Text(
              'How would you like to resolve this conflict?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(cloudSyncProvider.notifier).resolveConflict(
                    record.documentId,
                    ConflictResolution.keepRemote,
                  );
            },
            child: const Text('Keep Remote'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(cloudSyncProvider.notifier).resolveConflict(
                    record.documentId,
                    ConflictResolution.keepLocal,
                  );
            },
            style: FilledButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Keep Local'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(cloudSyncProvider.notifier).resolveConflict(
                    record.documentId,
                    ConflictResolution.keepBoth,
                  );
            },
            child: const Text('Keep Both'),
          ),
        ],
      ),
    );
  }

  /// Handles menu actions for a sync record.
  void _handleMenuAction(String action, SyncRecord record) {
    switch (action) {
      case 'sync':
        ref.read(cloudSyncProvider.notifier).syncDocument(record.documentId);
        break;
      case 'download':
        // Download would be implemented with the repository.
        break;
      case 'delete':
        _confirmDeleteFromCloud(record);
        break;
    }
  }

  /// Shows a confirmation dialog before removing a document from cloud.
  void _confirmDeleteFromCloud(SyncRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Cloud'),
        content: Text(
          'Are you sure you want to remove document '
          '${record.documentId.substring(0, 8)}... from cloud storage? '
          'The local copy will remain on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(cloudSyncProvider.notifier)
                  .deleteFromCloud(record.documentId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  // ── Helper Methods ──────────────────────────────────────────────

  /// Returns the color for a sync status.
  Color _statusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.conflict:
        return Colors.red;
      case SyncStatus.error:
        return const Color(0xFFD32F2F);
    }
  }

  /// Returns the icon for a sync status.
  IconData _statusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Icons.cloud_done_rounded;
      case SyncStatus.pending:
        return Icons.cloud_upload_rounded;
      case SyncStatus.conflict:
        return Icons.warning_amber_rounded;
      case SyncStatus.error:
        return Icons.error_outline_rounded;
    }
  }

  /// Returns the display label for a sync status.
  String _statusLabel(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.conflict:
        return 'Conflict';
      case SyncStatus.error:
        return 'Error';
    }
  }
}
