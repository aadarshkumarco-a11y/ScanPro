import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class KeyPointCard extends StatelessWidget {
  final String text;
  final int index;

  const KeyPointCard({
    super.key,
    required this.text,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIndexBadge(theme),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms, delay: (index * 60).ms).slideX(
          begin: 0.08,
          end: 0,
          duration: 250.ms,
        );
  }

  Widget _buildIndexBadge(ThemeData theme) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF4D2DAB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFF4D2DAB),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
