/// List tile variant for documents with thumbnail, title, subtitle, and actions.
///
/// Used in the list view layout of the documents screen.
library;

import 'package:flutter/material.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';

/// A compact list tile displaying document info with trailing actions.
///
/// [document] is the source document entity.
/// [onTap] fires when the tile is tapped.
/// [onFavoriteToggle] fires when the favorite icon is pressed.
/// [onMore] fires when the overflow menu icon is pressed.
class DocumentListTile extends StatelessWidget {
  final ScanDocument document;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onMore;

  const DocumentListTile({
    super.key,
    required this.document,
    this.onTap,
    this.onFavoriteToggle,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingMedium,
        vertical: Dimensions.spacing4,
      ),
      leading: _buildThumbnail(colorScheme),
      title: Text(
        document.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: _buildSubtitle(textTheme, colorScheme),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (document.isFavorite)
            IconButton(
              icon: Icon(Icons.favorite, size: 18, color: Colors.red.shade400),
              onPressed: onFavoriteToggle,
              tooltip: 'Unfavorite',
              visualDensity: VisualDensity.compact,
            ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: onMore,
            tooltip: 'More options',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(ColorScheme colorScheme) {
    return Container(
      width: Dimensions.thumbnailSize,
      height: Dimensions.thumbnailSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.thumbnailBorderRadius),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            document.pdfPath != null
                ? Icons.picture_as_pdf_outlined
                : Icons.image_outlined,
            size: 24,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          if (document.pdfPath != null)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'PDF',
                  style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(TextTheme textTheme, ColorScheme colorScheme) {
    final parts = <String>[
      _formatDate(document.updatedAt),
      _formatFileSize(document.fileSize),
      if (document.pageCount > 1) '${document.pageCount} pages',
    ];
    return Text(
      parts.join(' • '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
