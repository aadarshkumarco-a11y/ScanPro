/// Tag chip with color dot and name.
///
/// Compact chip used to display tag information on document cards
/// and in the document detail screen.
library;

import 'package:flutter/material.dart';
import 'package:scanpro/core/theme/dimensions.dart';

/// A compact tag chip with a colored dot indicator and tag name.
///
/// [name] is the tag display text.
/// [color] is the hex color string (e.g. '#4CAF50').
/// [onTap] fires when the chip is tapped (optional).
/// [onDelete] fires when the delete icon is pressed (optional).
class TagChip extends StatelessWidget {
  final String name;
  final String color;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TagChip({
    super.key,
    required this.name,
    this.color = '#9C27B0',
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tagColor = _parseColor(color);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.chipBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.spacing8,
          vertical: Dimensions.spacing4,
        ),
        decoration: BoxDecoration(
          color: tagColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.chipBorderRadius),
          border: Border.all(
            color: tagColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: tagColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: Dimensions.spacing4),
            // Tag name
            Text(
              name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: tagColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: Dimensions.spacing2),
              InkWell(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: tagColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final code = hex.replaceFirst('#', '');
      return Color(int.parse('FF$code', radix: 16));
    } catch (_) {
      return const Color(0xFF9C27B0);
    }
  }
}
