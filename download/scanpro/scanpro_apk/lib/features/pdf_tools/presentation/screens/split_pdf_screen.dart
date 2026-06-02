import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/pdf_provider.dart';
import '../widgets/page_range_selector.dart';

/// Split PDF screen for dividing a PDF by page ranges.
///
/// Users select a PDF file, add page ranges, and split the document
/// into separate files based on those ranges.
class SplitPdfScreen extends ConsumerStatefulWidget {
  const SplitPdfScreen({super.key});

  @override
  ConsumerState<SplitPdfScreen> createState() => _SplitPdfScreenState();
}

class _SplitPdfScreenState extends ConsumerState<SplitPdfScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pdfState = ref.watch(pdfProvider);
    final pdfNotifier = ref.read(pdfProvider.notifier);
    final isProcessing = pdfState.status == PdfStatus.splitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split PDF'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Select PDF ─────────────────────────────────────────────
            Text(
              'Select PDF to Split',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            _PdfSelectionCard(
              selectedPath: pdfState.splitPdfPath,
              onTap: () => _selectPdf(pdfNotifier),
            ),
            const SizedBox(height: 24),

            // ── Page Ranges ────────────────────────────────────────────
            Text(
              'Page Ranges',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Define which pages to extract. Examples: 1-3, 5, 7-10',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            PageRangeSelector(
              pageRanges: pdfState.pageRanges,
              onAddRange: (range) => pdfNotifier.addPageRange(range),
              onRemoveRange: (index) => pdfNotifier.removePageRange(index),
            ),
            const SizedBox(height: 24),

            // ── Preview of Output ──────────────────────────────────────
            if (pdfState.pageRanges.isNotEmpty)
              _buildOutputPreview(theme, pdfState.pageRanges),
            const SizedBox(height: 24),

            // ── Progress Indicator ─────────────────────────────────────
            if (isProcessing) ...[
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
                    'Splitting PDF…',
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
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Error Message ──────────────────────────────────────────
            if (pdfState.status == PdfStatus.error &&
                pdfState.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              const SizedBox(height: 24),
            ],

            // ── Success Banner ─────────────────────────────────────────
            if (pdfState.status == PdfStatus.success) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      child: Text(
                        'PDF split into ${pdfState.pageRanges.length} files!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Split Button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isProcessing ? null : _splitPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.call_split_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isProcessing
                          ? 'Splitting…'
                          : 'Split into ${pdfState.pageRanges.length} Files',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  /// Builds a preview of the output files.
  Widget _buildOutputPreview(ThemeData theme, List<String> pageRanges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Output Preview',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.infoColor,
          ),
        ),
        const SizedBox(height: 10),
        ...pageRanges.asMap().entries.map((entry) {
          final index = entry.key;
          final range = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.infoColor.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.infoColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Split_${range.replaceAll('-', '_')}.pdf',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Pages: $range',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppTheme.infoColor.withValues(alpha: 0.4),
                  size: 20,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Selects a PDF file using file picker.
  Future<void> _selectPdf(PdfNotifier notifier) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        notifier.setSplitPdfPath(result.files.single.path!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking PDF: ${e.toString()}')),
        );
      }
    }
  }

  /// Splits the selected PDF.
  Future<void> _splitPdf() async {
    final notifier = ref.read(pdfProvider.notifier);
    await notifier.splitPdf();
  }
}

/// PDF file selection card.
class _PdfSelectionCard extends StatelessWidget {
  const _PdfSelectionCard({
    required this.selectedPath,
    required this.onTap,
  });

  final String? selectedPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFile = selectedPath != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasFile
              ? AppTheme.primaryColor.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasFile
                    ? Icons.picture_as_pdf_rounded
                    : Icons.folder_open_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? 'PDF Selected' : 'Tap to select a PDF file',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile
                        ? selectedPath!.split('/').last
                        : 'Choose a PDF from your device',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
