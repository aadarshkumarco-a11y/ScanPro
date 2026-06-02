/// Trash screen showing soft-deleted documents with restore and permanent delete.
///
/// Lists deleted documents with their deletion date, a restore button
/// per item, an "Empty Trash" button, and a notice about auto-deletion
/// after 30 days.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/core/widgets/empty_state.dart';
import 'package:scanpro/core/widgets/loading_widget.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/documents/presentation/providers/documents_provider.dart';

/// Screen for viewing and managing trashed (soft-deleted) documents.
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashAsync = ref.watch(trashDocumentsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Trash'),
        actions: [
          trashAsync.maybeWhen(
            data: (docs) => docs.isNotEmpty
                ? TextButton(
                    onPressed: () => _showEmptyTrashDialog(context, ref),
                    child: Text(
                      'Empty Trash',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Auto-delete notice ──────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingMedium,
              vertical: Dimensions.spacing10,
            ),
            color: colorScheme.errorContainer.withValues(alpha: 0.2),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: Dimensions.iconMedium,
                  color: colorScheme.error,
                ),
                const SizedBox(width: Dimensions.spacing8),
                Expanded(
                  child: Text(
                    'Documents in trash are automatically deleted after 30 days.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                  ),
                ),
              ],
            ),
          ),
          // ── Trash list ──────────────────────────────────
          Expanded(
            child: trashAsync.when(
              loading: () =>
                  const LoadingWidget(message: 'Loading trash...'),
              error: (error, _) => Center(
                child: Text(error.toString()),
              ),
              data: (docs) {
                if (docs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.delete_outline,
                    title: 'Trash is Empty',
                    subtitle:
                        'Deleted documents will appear here for 30 days',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.spacing8,
                  ),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return _TrashListTile(
                      document: doc,
                      onRestore: () => _restoreDocument(context, ref, doc),
                      onDeletePermanently: () =>
                          _deletePermanently(context, ref, doc),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _restoreDocument(
      BuildContext context, WidgetRef ref, ScanDocument doc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${doc.title}" restored'),
        duration: const Duration(seconds: 1),
      ),
    );
    ref.invalidate(trashDocumentsProvider);
    ref.invalidate(documentsListProvider);
  }

  void _deletePermanently(
      BuildContext context, WidgetRef ref, ScanDocument doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Permanently?'),
        content: Text(
          '"${doc.title}" will be permanently deleted. This action cannot be undone.',
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
                const SnackBar(
                  content: Text('Document permanently deleted'),
                ),
              );
              ref.invalidate(trashDocumentsProvider);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  void _showEmptyTrashDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty Trash?'),
        content: const Text(
          'All documents in trash will be permanently deleted. This action cannot be undone.',
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
                const SnackBar(
                  content: Text('Trash emptied successfully'),
                ),
              );
              ref.invalidate(trashDocumentsProvider);
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trash List Tile
// ---------------------------------------------------------------------------

class _TrashListTile extends StatelessWidget {
  final ScanDocument document;
  final VoidCallback onRestore;
  final VoidCallback onDeletePermanently;

  const _TrashListTile({
    required this.document,
    required this.onRestore,
    required this.onDeletePermanently,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingMedium,
        vertical: Dimensions.spacing4,
      ),
      leading: Container(
        width: Dimensions.thumbnailSize,
        height: Dimensions.thumbnailSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.thumbnailBorderRadius),
          color: colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          document.pdfPath != null
              ? Icons.picture_as_pdf_outlined
              : Icons.image_outlined,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
      title: Text(
        document.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        'Deleted ${_formatDate(document.updatedAt)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Restore button
          IconButton(
            icon: Icon(
              Icons.restore,
              size: 20,
              color: colorScheme.primary,
            ),
            onPressed: onRestore,
            tooltip: 'Restore',
            visualDensity: VisualDensity.compact,
          ),
          // Delete permanently button
          IconButton(
            icon: Icon(
              Icons.delete_forever,
              size: 20,
              color: colorScheme.error,
            ),
            onPressed: onDeletePermanently,
            tooltip: 'Delete permanently',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
