/// Document card for grid view with thumbnail, title, date, tags, and favorite icon.
///
/// Used in the responsive grid layout of the documents screen.
library;

import 'package:flutter/material.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/documents/presentation/widgets/tag_chip.dart';

/// A card displaying document summary info in a grid layout.
///
/// [document] is the source document entity.
/// [onTap] fires when the card is tapped.
/// [onFavoriteToggle] fires when the favorite icon is pressed.
class DocumentCard extends StatelessWidget {
  final ScanDocument document;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Thumbnail area ──────────────────────────────
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        document.pdfPath != null
                            ? Icons.picture_as_pdf_outlined
                            : Icons.image_outlined,
                        size: 40,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  // PDF badge
                  if (document.pdfPath != null)
                    Positioned(
                      top: Dimensions.spacing4,
                      left: Dimensions.spacing4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.spacing6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: const Text(
                          'PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  // Favorite button
                  Positioned(
                    top: Dimensions.spacing4,
                    right: Dimensions.spacing4,
                    child: InkWell(
                      onTap: onFavoriteToggle,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.spacing4),
                        child: Icon(
                          document.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: document.isFavorite
                              ? Colors.red.shade400
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  // Sync indicator
                  if (document.syncStatus == SyncStatus.synced)
                    Positioned(
                      bottom: Dimensions.spacing4,
                      right: Dimensions.spacing4,
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.spacing2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_done,
                          size: 14,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ── Info area ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.spacing10,
                Dimensions.spacing8,
                Dimensions.spacing10,
                Dimensions.spacing10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(document.updatedAt),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (document.tags.isNotEmpty) ...[
                    const SizedBox(height: Dimensions.spacing4),
                    Wrap(
                      spacing: Dimensions.spacing4,
                      runSpacing: 2,
                      children: document.tags
                          .take(2)
                          .map((t) => TagChip(name: t, color: '#9C27B0'))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
