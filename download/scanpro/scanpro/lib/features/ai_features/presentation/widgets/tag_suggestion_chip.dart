import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/ai_features/presentation/providers/ai_provider.dart';

class TagSuggestionChip extends StatelessWidget {
  final AiTagSuggestion suggestion;
  final VoidCallback onApply;
  final VoidCallback onIgnore;

  const TagSuggestionChip({
    super.key,
    required this.suggestion,
    required this.onApply,
    required this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApplied = suggestion.isApplied;
    final relevancePercent = (suggestion.relevance * 100).toInt();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isApplied
            ? const Color(0xFF4D2DAB).withOpacity(0.12)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isApplied
              ? const Color(0xFF4D2DAB)
              : theme.colorScheme.outlineVariant,
          width: isApplied ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isApplied)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.check_circle, size: 14, color: Color(0xFF4D2DAB)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.label_outline,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          Text(
            '#${suggestion.tag}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isApplied ? const Color(0xFF4D2DAB) : theme.colorScheme.onSurface,
              fontWeight: isApplied ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (!isApplied) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '$relevancePercent%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _buildMicroButton(
              context,
              icon: Icons.check,
              color: Colors.green,
              onTap: onApply,
              tooltip: 'Apply tag',
            ),
            _buildMicroButton(
              context,
              icon: Icons.close,
              color: theme.colorScheme.error,
              onTap: onIgnore,
              tooltip: 'Ignore tag',
            ),
          ],
        ],
      ),
    )
        .animate(target: isApplied ? 1.0 : 0.0)
        .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 150.ms);
  }

  Widget _buildMicroButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(icon, size: 12, color: color),
        ),
      ),
    );
  }
}
