import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/sync_provider.dart';

class ConflictResolutionCard extends StatelessWidget {
  final SyncConflict conflict;
  final VoidCallback onKeepLocal;
  final VoidCallback onKeepRemote;

  const ConflictResolutionCard({
    super.key,
    required this.conflict,
    required this.onKeepLocal,
    required this.onKeepRemote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    conflict.fileName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildVersionCard(
                  context,
                  label: 'Local',
                  modified: conflict.localModified,
                  size: conflict.localSize,
                  isLocal: true,
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildVersionCard(
                  context,
                  label: 'Remote',
                  modified: conflict.remoteModified,
                  size: conflict.remoteSize,
                  isLocal: false,
                )),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onKeepLocal,
                    icon: const Icon(Icons.phone_android, size: 18),
                    label: const Text('Keep Local'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onKeepRemote,
                    icon: const Icon(Icons.cloud, size: 18),
                    label: const Text('Keep Remote'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildVersionCard(
    BuildContext context, {
    required String label,
    required DateTime modified,
    required String size,
    required bool isLocal,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLocal ? Icons.phone_android : Icons.cloud,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(modified),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            size,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
