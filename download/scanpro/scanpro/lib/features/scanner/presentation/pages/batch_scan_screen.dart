/// Multi-page batch scanning screen.
///
/// Lists scanned pages with thumbnails, supports reorder via
/// drag & drop, delete individual pages, continue scanning,
/// and create a PDF from all pages.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/core/widgets/empty_state.dart';
import 'package:scanpro/core/widgets/loading_widget.dart';
import 'package:scanpro/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:scanpro/features/scanner/presentation/widgets/scan_page_thumbnail.dart';

/// Screen for managing a multi-page batch scanning session.
class BatchScanScreen extends ConsumerWidget {
  const BatchScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchState = ref.watch(batchScanProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(batchScanProvider.notifier).clearSession();
            context.pop();
          },
        ),
        title: Text(
          'Batch Scan (${batchState.pageCount} ${batchState.pageCount == 1 ? 'page' : 'pages'})',
        ),
        actions: [
          if (batchState.pages.isNotEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context, ref),
              child: Text(
                'Clear All',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
        ],
      ),
      body: batchState.pages.isEmpty
          ? const EmptyState(
              icon: Icons.document_scanner_outlined,
              title: 'No Pages Yet',
              subtitle: 'Scan your first page to start a batch scan session',
            )
          : Column(
              children: [
                // Page count indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingMedium,
                    vertical: Dimensions.spacing12,
                  ),
                  color: colorScheme.primaryContainer.withValues(alpha: 0.15),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: Dimensions.iconSmall,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: Dimensions.spacing8),
                      Expanded(
                        child: Text(
                          '${batchState.pageCount} page${batchState.pageCount != 1 ? 's' : ''} scanned • Drag to reorder',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Reorderable page list
                Expanded(
                  child: ReorderableListView.builder(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 80,
                    ),
                    itemCount: batchState.pages.length,
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(batchScanProvider.notifier)
                          .reorderPages(oldIndex, newIndex);
                    },
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (_, __) {
                          final t = Curves.easeInOut.transform(animation.value);
                          return Transform.scale(
                            scale: 1.0 + 0.03 * t,
                            child: Opacity(
                              opacity: 0.85,
                              child: child,
                            ),
                          );
                        },
                      );
                    },
                    itemBuilder: (context, index) {
                      final page = batchState.pages[index];
                      return ScanPageThumbnail(
                        key: ValueKey(page.id),
                        page: page,
                        index: index + 1,
                        onDelete: () => ref
                            .read(batchScanProvider.notifier)
                            .removePage(page.id),
                      );
                    },
                  ),
                ),
              ],
            ),

      // ── Bottom Action Bar ──────────────────────────────────
      bottomNavigationBar: batchState.pages.isEmpty
          ? null
          : Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              padding: EdgeInsets.only(
                left: Dimensions.paddingMedium,
                right: Dimensions.paddingMedium,
                top: Dimensions.spacing12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              child: Row(
                children: [
                  // Continue scanning
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/scanner'),
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: const Text('Add More'),
                    ),
                  ),
                  const SizedBox(width: Dimensions.spacing12),
                  // Create PDF
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: batchState.isCreatingPdf
                          ? null
                          : () async {
                              await ref
                                  .read(batchScanProvider.notifier)
                                  .createPdf();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('PDF created successfully'),
                                  ),
                                );
                                ref
                                    .read(batchScanProvider.notifier)
                                    .clearSession();
                                context.go('/documents');
                              }
                            },
                      icon: batchState.isCreatingPdf
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: Text(batchState.isCreatingPdf
                          ? 'Creating...'
                          : 'Create PDF'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.scannerAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Pages?'),
        content: const Text(
          'This will remove all scanned pages from the current session. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(batchScanProvider.notifier).clearSession();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
