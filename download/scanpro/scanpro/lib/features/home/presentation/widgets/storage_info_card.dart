import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/home_provider.dart';

class StorageInfoCard extends StatelessWidget {
  final StorageInfoModel storageInfo;

  const StorageInfoCard({
    super.key,
    required this.storageInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Storage',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${storageInfo.usedFormatted} / ${storageInfo.totalFormatted}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: storageInfo.usageFraction,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  storageInfo.usageFraction > 0.9
                      ? theme.colorScheme.error
                      : storageInfo.usageFraction > 0.7
                          ? const Color(0xFFFBBC05)
                          : theme.colorScheme.primary,
                ),
              ),
            )
                .animate(onPlay: (c) => c.forward())
                .fadeIn(duration: 600.ms),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  theme,
                  icon: Icons.description,
                  label: 'Documents',
                  value: '${storageInfo.documentCount}',
                ),
                _buildStat(
                  theme,
                  icon: Icons.document_scanner,
                  label: 'Scans',
                  value: '${storageInfo.scanCount}',
                ),
                _buildStat(
                  theme,
                  icon: Icons.text_fields,
                  label: 'OCR',
                  value: '${storageInfo.ocrCount}',
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 400.ms);
  }

  Widget _buildStat(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
