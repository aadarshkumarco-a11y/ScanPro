import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../scanner/domain/entities/scanned_document.dart';

/// A document card widget for grid and list layouts.
///
/// Displays a thumbnail, document name, date, file size,
/// and optional favourite indicator. Supports tap, favourite
/// toggle, and delete actions.
class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.document,
    required this.isGridView,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  /// The scanned document to display.
  final ScannedDocument document;

  /// Whether this card is in a grid layout (vs list).
  final bool isGridView;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  /// Callback when the favourite button is toggled.
  final VoidCallback onFavoriteToggle;

  /// Callback when the delete action is triggered.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return isGridView ? _buildGridCard(context) : _buildListCard(context);
  }

  /// Builds the grid card layout.
  Widget _buildGridCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Thumbnail ────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildThumbnail(colorScheme),
                  // Favourite badge
                  if (document.isFavorite)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 14,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                  // Page count badge
                  if (document.pages.length > 1)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${document.pages.length} pages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info section ─────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(document.updatedAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          FileUtils.fileSizeShort(document.fileSize),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        _buildPopupMenu(colorScheme),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list card layout.
  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // ── Thumbnail ──────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: _buildThumbnail(colorScheme),
                ),
              ),
              const SizedBox(width: 12),

              // ── Info ───────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            document.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (document.isFavorite)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.favorite_rounded,
                              size: 14,
                              color: AppTheme.accentColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatDate(document.updatedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          FileUtils.fileSizeShort(document.fileSize),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        if (document.pages.length > 1) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${document.pages.length} pages',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Actions ────────────────────────────────────────────
              _buildPopupMenu(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the thumbnail widget.
  Widget _buildThumbnail(ColorScheme colorScheme) {
    final filePath = document.thumbnailPath ?? document.filePath;

    if (filePath.isNotEmpty && File(filePath).existsSync()) {
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
      );
    }

    return _buildPlaceholder(colorScheme);
  }

  /// Builds a placeholder for missing thumbnails.
  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: 0.06),
      child: Center(
        child: Icon(
          FileUtils.isPdf(document.filePath)
              ? Icons.picture_as_pdf_rounded
              : Icons.description_rounded,
          size: 32,
          color: AppTheme.primaryColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  /// Builds the popup menu for card actions.
  Widget _buildPopupMenu(ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      onSelected: (action) {
        switch (action) {
          case 'favorite':
            onFavoriteToggle();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'favorite',
          child: Row(
            children: [
              Icon(
                document.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 18,
                color: AppTheme.accentColor,
              ),
              const SizedBox(width: 8),
              Text(document.isFavorite ? 'Unfavourite' : 'Favourite'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: colorScheme.error),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
      ],
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  /// Formats a [DateTime] for display in the card.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}

/// Convenience accessors for theme colours.
class AppTheme {
  static const Color primaryColor = Color(0xFF4D2DAB);
  static const Color accentColor = Color(0xFFFF6B6B);
}
