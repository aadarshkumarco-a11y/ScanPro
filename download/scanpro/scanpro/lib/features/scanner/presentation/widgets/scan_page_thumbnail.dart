/// Thumbnail card for the batch scan page list.
///
/// Displays a small preview of a scanned page with a page number
/// badge and a delete button. Used inside the batch scan screen.
library;

import 'package:flutter/material.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/features/scanner/presentation/providers/scanner_provider.dart';

/// A thumbnail card representing a single page in a batch scan session.
///
/// [page] holds the page data.
/// [index] is the 1-based page number shown in the badge.
/// [onDelete] fires when the delete icon is tapped.
class ScanPageThumbnail extends StatelessWidget {
  final BatchScanPage page;
  final int index;
  final VoidCallback onDelete;

  const ScanPageThumbnail({
    super.key,
    required this.page,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(page.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Dimensions.paddingMedium),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSmall,
          vertical: Dimensions.spacing4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSmall),
          child: Row(
            children: [
              // Page thumbnail
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: page.thumbnailPath != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                            child: Image.asset(
                              page.thumbnailPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.description_outlined,
                                size: 28,
                              ),
                            ),
                          )
                        : const Icon(Icons.description_outlined, size: 28),
                  ),
                  // Page number badge
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.spacing6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.scannerAccent,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Text(
                        '$index',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: Dimensions.spacing12),
              // Page info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Page $index',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp(page.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: Dimensions.iconMedium - 4,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: onDelete,
                tooltip: 'Remove page',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
