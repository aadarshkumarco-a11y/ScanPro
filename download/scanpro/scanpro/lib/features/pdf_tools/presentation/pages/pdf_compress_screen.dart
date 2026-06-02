import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/pdf_tools/presentation/providers/pdf_provider.dart';
import 'package:scanpro/features/pdf_tools/presentation/widgets/quality_option_card.dart';

class PdfCompressScreen extends ConsumerStatefulWidget {
  const PdfCompressScreen({super.key});

  @override
  ConsumerState<PdfCompressScreen> createState() => _PdfCompressScreenState();
}

class _PdfCompressScreenState extends ConsumerState<PdfCompressScreen> {
  @override
  Widget build(BuildContext context) {
    final compressState = ref.watch(pdfCompressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress PDF'),
        centerTitle: true,
      ),
      body: compressState.document == null
          ? _buildDocumentPicker(theme)
          : _buildCompressContent(theme, compressState),
      bottomNavigationBar: compressState.document != null ? _buildCompressButton(theme, compressState) : null,
    );
  }

  Widget _buildDocumentPicker(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compress, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('Select a PDF to compress', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Reduce file size while maintaining quality', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadSampleDocument,
            icon: const Icon(Icons.folder_open),
            label: const Text('Select PDF'),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildCompressContent(ThemeData theme, PdfCompressState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentInfo(theme, state.document!),
          const SizedBox(height: 24),
          _buildQualitySelector(theme, state),
          const SizedBox(height: 24),
          _buildEstimatedSizePreview(theme, state),
          if (state.result != null) ...[
            const SizedBox(height: 24),
            _buildResultComparison(theme, state.result!),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentInfo(ThemeData theme, PdfDocument doc) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.name, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _infoChip(theme, '${doc.pageCount} pages'),
                      const SizedBox(width: 8),
                      _infoChip(theme, doc.fileSize),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => ref.read(pdfCompressProvider.notifier).state = const PdfCompressState(),
              icon: Icon(Icons.close, size: 20, color: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _infoChip(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: theme.textTheme.labelSmall),
    );
  }

  Widget _buildQualitySelector(ThemeData theme, PdfCompressState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compression Quality', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Higher quality = larger file size', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QualityOptionCard(
                quality: CompressionQuality.low,
                label: 'Low',
                description: '72 DPI',
                detail: 'Max compression',
                reductionEstimate: '70%',
                isSelected: state.quality == CompressionQuality.low,
                onTap: () => ref.read(pdfCompressProvider.notifier).setQuality(CompressionQuality.low),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: QualityOptionCard(
                quality: CompressionQuality.medium,
                label: 'Medium',
                description: '150 DPI',
                detail: 'Balanced',
                reductionEstimate: '55%',
                isSelected: state.quality == CompressionQuality.medium,
                onTap: () => ref.read(pdfCompressProvider.notifier).setQuality(CompressionQuality.medium),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: QualityOptionCard(
                quality: CompressionQuality.high,
                label: 'High',
                description: '300 DPI',
                detail: 'Best quality',
                reductionEstimate: '25%',
                isSelected: state.quality == CompressionQuality.high,
                onTap: () => ref.read(pdfCompressProvider.notifier).setQuality(CompressionQuality.high),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstimatedSizePreview(ThemeData theme, PdfCompressState state) {
    if (state.document == null) return const SizedBox.shrink();
    final reductionFactors = {CompressionQuality.low: 0.70, CompressionQuality.medium: 0.55, CompressionQuality.high: 0.25};
    final factor = reductionFactors[state.quality]!;
    final originalSize = state.document!.fileSizeBytes;
    final estimatedSize = (originalSize * (1 - factor)).round();

    String formatSize(int bytes) {
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estimated Result', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSizeIndicator(theme, 'Before', formatSize(originalSize), theme.colorScheme.error, 1.0),
                Column(
                  children: [
                    Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${(factor * 100).toInt()}%',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                _buildSizeIndicator(theme, 'After', formatSize(estimatedSize), Colors.green, 1 - factor),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSizeIndicator(ThemeData theme, String label, String size, Color color, double fraction) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(size, style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultComparison(ThemeData theme, CompressionResult result) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade300),
      ),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text('Compression Complete!', style: theme.textTheme.titleSmall?.copyWith(color: Colors.green.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Original', style: theme.textTheme.labelSmall?.copyWith(color: Colors.green.shade700)),
                    Text(result.originalSizeFormatted, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.arrow_forward, color: Colors.green.shade700),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Compressed', style: theme.textTheme.labelSmall?.copyWith(color: Colors.green.shade700)),
                    Text(result.compressedSizeFormatted, style: theme.textTheme.titleMedium?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Saved ${result.reductionPercent.toStringAsFixed(0)}%',
                style: theme.textTheme.labelLarge?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildCompressButton(ThemeData theme, PdfCompressState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.isCompressing) ...[
              Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)),
                  const SizedBox(width: 12),
                  Text('Compressing...', style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  Text('${(state.progress * 100).toInt()}%', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: state.progress, backgroundColor: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: !state.isCompressing && state.result == null ? _compress : null,
              icon: state.isCompressing
                  ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                  : const Icon(Icons.compress, size: 18),
              label: Text(state.isCompressing ? 'Compressing...' : state.result != null ? 'Compressed!' : 'Compress PDF'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
                backgroundColor: state.result != null ? Colors.green : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadSampleDocument() {
    final doc = PdfDocument(
      id: 'compress-sample',
      name: 'Large_Report_2025.pdf',
      path: '/storage/documents/large_report.pdf',
      pageCount: 24,
      fileSizeBytes: 8500000,
      lastModified: DateTime.now(),
    );
    ref.read(pdfCompressProvider.notifier).setDocument(doc);
  }

  Future<void> _compress() async {
    final result = await ref.read(pdfCompressProvider.notifier).compress();
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compressed! Saved ${result.reductionPercent.toStringAsFixed(0)}%'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'Open', onPressed: () {}),
        ),
      );
    }
  }
}
