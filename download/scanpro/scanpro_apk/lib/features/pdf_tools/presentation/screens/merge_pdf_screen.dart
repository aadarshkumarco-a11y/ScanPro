import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/pdf_provider.dart';

/// Merge PDF screen for combining multiple PDFs with reordering.
///
/// Users can add PDF files, reorder them via drag-and-drop,
/// and merge them into a single output document.
class MergePdfScreen extends ConsumerStatefulWidget {
  const MergePdfScreen({super.key});

  @override
  ConsumerState<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends ConsumerState<MergePdfScreen> {
  final _fileNameController = TextEditingController(text: 'ScanPro_Merged');

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pdfState = ref.watch(pdfProvider);
    final pdfNotifier = ref.read(pdfProvider.notifier);
    final isProcessing = pdfState.status == PdfStatus.merging;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge PDFs'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Column(
        children: [
          // ── File Name Input ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              controller: _fileNameController,
              decoration: InputDecoration(
                labelText: 'Output File Name',
                hintText: 'Enter merged PDF file name',
                prefixIcon: const Icon(Icons.description_rounded, size: 18),
                suffixIcon: const Icon(Icons.edit_rounded, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Add PDF Button ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isProcessing
                    ? null
                    : () => _addPdf(pdfNotifier),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text('Add PDF File'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Info Banner ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppTheme.secondaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add at least 2 PDFs and drag to reorder. Files will be merged in the displayed order.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.secondaryColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Progress Indicator ───────────────────────────────────────
          if (isProcessing) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Merging ${pdfState.selectedPdfPaths.length} PDFs…',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pdfState.progress,
                      minHeight: 6,
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Error Message ────────────────────────────────────────────
          if (pdfState.status == PdfStatus.error &&
              pdfState.errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pdfState.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Success Banner ───────────────────────────────────────────
          if (pdfState.status == PdfStatus.success &&
              pdfState.currentDocument != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.successColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppTheme.successColor, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PDFs Merged Successfully!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.successColor,
                            ),
                          ),
                          Text(
                            '${pdfState.currentDocument!.pageCount} pages • ${pdfState.currentDocument!.fileSizeFormatted}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.successColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── PDF List ─────────────────────────────────────────────────
          Expanded(
            child: pdfState.selectedPdfPaths.isEmpty
                ? _buildEmptyState(theme, colorScheme)
                : _buildPdfList(theme, pdfState, pdfNotifier),
          ),
        ],
      ),
      bottomNavigationBar: pdfState.selectedPdfPaths.length >= 2
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _mergePdfs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.merge_type_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Merge ${pdfState.selectedPdfPaths.length} PDFs',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  /// Builds the empty state.
  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.merge_type_rounded,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'No PDFs selected',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add at least 2 PDF files to merge',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the reorderable PDF list.
  Widget _buildPdfList(
    ThemeData theme,
    PdfState pdfState,
    PdfNotifier pdfNotifier,
  ) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: pdfState.selectedPdfPaths.length,
      onReorder: pdfNotifier.reorderPdfsForMerge,
      itemBuilder: (context, index) {
        final pdfPath = pdfState.selectedPdfPaths[index];
        return Container(
          key: ValueKey('pdf_$index'),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.secondaryColor.withValues(alpha: 0.15),
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppTheme.secondaryColor,
                    size: 20,
                  ),
                  Text(
                    '#${index + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              pdfPath.split('/').last,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Position ${index + 1} in merge order',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.drag_indicator_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                IconButton(
                  onPressed: () => pdfNotifier.removePdfForMerge(index),
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.error.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Adds a PDF to the merge list (placeholder).
  void _addPdf(PdfNotifier notifier) {
    notifier.addPdfForMerge(
      '/path/to/document_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Merges the selected PDFs.
  Future<void> _mergePdfs() async {
    final notifier = ref.read(pdfProvider.notifier);
    await notifier.mergePdfs(fileName: _fileNameController.text);
  }
}
