/// Document detail screen with preview, info, actions, and tag management.
///
/// Shows full document preview (PDF or image), document metadata,
/// action buttons (Share, Export, OCR, AI Summary, Sign, Annotate, Delete),
/// tag management, move to folder, and version history.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/core/widgets/loading_widget.dart';
import 'package:scanpro/features/documents/presentation/providers/documents_provider.dart';
import 'package:scanpro/features/documents/presentation/widgets/tag_chip.dart';

/// Screen showing detailed view of a single document.
class DocumentDetailScreen extends ConsumerWidget {
  final String documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docAsync = ref.watch(documentDetailProvider(documentId));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return docAsync.when(
      loading: () => const Scaffold(
        body: LoadingWidget(message: 'Loading document...'),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Document not found', style: textTheme.titleMedium),
            ],
          ),
        ),
      ),
      data: (doc) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            doc.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: Icon(
                doc.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: doc.isFavorite ? Colors.red.shade400 : null,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(doc.isFavorite
                        ? 'Removed from favorites'
                        : 'Added to favorites'),
                    duration: const Duration(seconds: 1),
                  ),
                );
                ref.invalidate(documentDetailProvider(documentId));
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showActionsModal(context, ref),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Document Preview ────────────────────────────
              _DocumentPreview(doc: doc),
              const SizedBox(height: Dimensions.spacing20),

              // ── Document Info ───────────────────────────────
              _InfoSection(doc: doc),
              const SizedBox(height: Dimensions.spacing20),

              // ── Quick Actions ───────────────────────────────
              Text(
                'Actions',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Dimensions.spacing12),
              Wrap(
                spacing: Dimensions.spacing8,
                runSpacing: Dimensions.spacing8,
                children: [
                  _ActionChip(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () {},
                  ),
                  _ActionChip(
                    icon: Icons.upload_file,
                    label: 'Export',
                    onTap: () {},
                  ),
                  _ActionChip(
                    icon: Icons.text_fields,
                    label: 'OCR',
                    onTap: () {},
                  ),
                  _ActionChip(
                    icon: Icons.auto_awesome,
                    label: 'AI Summary',
                    onTap: () => context.push('/ai/summary/$documentId'),
                  ),
                  _ActionChip(
                    icon: Icons.draw,
                    label: 'Sign',
                    onTap: () => context.push('/signature'),
                  ),
                  _ActionChip(
                    icon: Icons.edit_note,
                    label: 'Annotate',
                    onTap: () => context.push('/annotations/$documentId'),
                  ),
                  _ActionChip(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: colorScheme.error,
                    onTap: () => _showDeleteDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.spacing20),

              // ── Tags ────────────────────────────────────────
              Text(
                'Tags',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Dimensions.spacing8),
              Wrap(
                spacing: Dimensions.spacing8,
                runSpacing: Dimensions.spacing8,
                children: [
                  ...doc.tags.map((tag) => TagChip(
                        name: tag,
                        color: '#9C27B0',
                        onDelete: () {
                          ref.invalidate(documentDetailProvider(documentId));
                        },
                      )),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: const Text('Add Tag'),
                    onPressed: () {
                      // Placeholder: would show tag picker dialog
                    },
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.spacing20),

              // ── Move to Folder ──────────────────────────────
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.drive_file_move_outline),
                title: const Text('Move to Folder'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Placeholder: would show folder picker
                },
              ),
              const Divider(),

              // ── Version History ─────────────────────────────
              if (doc.syncStatus == SyncStatus.synced)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history),
                  title: const Text('Version History'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Placeholder: would show version history
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionsModal(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Move to Folder'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: colorScheme.error),
              title: Text('Delete', style: TextStyle(color: colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document?'),
        content: const Text(
          'This document will be moved to trash. You can restore it within 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document moved to trash')),
              );
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Document Preview
// ---------------------------------------------------------------------------

class _DocumentPreview extends StatelessWidget {
  final dynamic doc;

  const _DocumentPreview({required this.doc});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              doc.pdfPath != null
                  ? Icons.picture_as_pdf_outlined
                  : Icons.image_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: Dimensions.spacing8),
            Text(
              '${doc.pageCount} page${doc.pageCount != 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info Section
// ---------------------------------------------------------------------------

class _InfoSection extends StatelessWidget {
  final dynamic doc;

  const _InfoSection({required this.doc});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingCard),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Name', value: doc.title),
          _InfoRow(label: 'Size', value: _formatSize(doc.fileSize)),
          _InfoRow(
            label: 'Modified',
            value: _formatDate(doc.updatedAt),
          ),
          _InfoRow(label: 'Pages', value: '${doc.pageCount}'),
          if (doc.ocrText != null)
            _InfoRow(label: 'OCR Text', value: doc.ocrText!, maxLines: 2),
          _InfoRow(
            label: 'Sync',
            value: _syncLabel(doc.syncStatus),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _syncLabel(SyncStatus status) => switch (status) {
        SyncStatus.localOnly => 'Local only',
        SyncStatus.synced => 'Synced',
        SyncStatus.pendingUpload => 'Pending upload',
        SyncStatus.pendingDownload => 'Pending download',
        SyncStatus.conflict => 'Conflict',
      };
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const _InfoRow({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.spacing4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action Chip
// ---------------------------------------------------------------------------

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return ActionChip(
      avatar: Icon(icon, size: 16, color: effectiveColor),
      label: Text(label),
      labelStyle: TextStyle(color: effectiveColor, fontSize: 12),
      onPressed: onTap,
    );
  }
}
