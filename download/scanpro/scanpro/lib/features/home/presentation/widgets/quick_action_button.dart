import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/home_provider.dart';

class QuickActionButton extends StatelessWidget {
  final QuickAction action;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    required this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: 26,
            ),
          )
              .animate(onPlay: (c) => c.forward())
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 300.ms,
              ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
