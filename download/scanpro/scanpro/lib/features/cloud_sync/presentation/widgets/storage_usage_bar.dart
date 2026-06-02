import 'package:flutter/material.dart';

class StorageUsageBar extends StatelessWidget {
  final int usedBytes;
  final int totalBytes;
  final String usedLabel;
  final String totalLabel;
  final double height;
  final double borderRadius;

  const StorageUsageBar({
    super.key,
    required this.usedBytes,
    required this.totalBytes,
    required this.usedLabel,
    required this.totalLabel,
    this.height = 10,
    this.borderRadius = 5,
  });

  double get _fraction => totalBytes > 0 ? usedBytes / totalBytes : 0;

  Color _barColor(BuildContext context) {
    if (_fraction > 0.9) return Theme.of(context).colorScheme.error;
    if (_fraction > 0.7) return const Color(0xFFFBBC05);
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              usedLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'of $totalLabel',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _fraction.clamp(0.0, 1.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOutCubic,
                  height: height,
                  decoration: BoxDecoration(
                    color: _barColor(context),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(_fraction * 100).toStringAsFixed(1)}% used',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
