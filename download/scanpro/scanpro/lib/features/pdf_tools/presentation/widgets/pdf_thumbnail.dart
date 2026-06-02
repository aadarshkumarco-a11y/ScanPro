import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PdfThumbnail extends StatelessWidget {
  final int pageNumber;
  final bool isSelected;
  final bool isSelectable;
  final double rotation;
  final bool showDragHandle;

  const PdfThumbnail({
    super.key,
    required this.pageNumber,
    this.isSelected = false,
    this.isSelectable = false,
    this.rotation = 0,
    this.showDragHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF4D2DAB).withOpacity(0.08)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF4D2DAB)
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: const Color(0xFF4D2DAB).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]
            : null,
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: AnimatedRotation(
                    turns: rotation / 360,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 24,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$pageNumber',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4D2DAB).withOpacity(0.1)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                child: Center(
                  child: Text(
                    'Page $pageNumber',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected ? const Color(0xFF4D2DAB) : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isSelectable)
            Positioned(
              top: 4,
              right: 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF4D2DAB) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4D2DAB) : theme.colorScheme.outline,
                    width: isSelected ? 0 : 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
          if (showDragHandle)
            Positioned(
              top: 4,
              left: 4,
              child: Icon(
                Icons.drag_indicator,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 150.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 150.ms,
        );
  }
}
