import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/sync_provider.dart';

class SyncStatusIndicator extends StatelessWidget {
  final SyncStatus status;
  final double size;

  const SyncStatusIndicator({
    super.key,
    required this.status,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );

    if (status == SyncStatus.syncing) {
      return dot.animate(onPlay: (c) => c.repeat()).pulse(
            duration: 1200.ms,
            begin: 1.0,
            end: 1.3,
          );
    }

    return dot.animate().fadeIn(duration: 300.ms);
  }

  Color _statusColor(BuildContext context) {
    switch (status) {
      case SyncStatus.idle:
        return Theme.of(context).colorScheme.outlineVariant;
      case SyncStatus.syncing:
        return const Color(0xFFFBBC05);
      case SyncStatus.completed:
        return const Color(0xFF34A853);
      case SyncStatus.failed:
        return Theme.of(context).colorScheme.error;
      case SyncStatus.conflict:
        return const Color(0xFFEA4335);
    }
  }
}
