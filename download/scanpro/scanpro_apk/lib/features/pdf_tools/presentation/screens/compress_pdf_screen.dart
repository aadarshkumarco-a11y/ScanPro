import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/pdf_provider.dart';

/// Compress PDF screen with quality settings.
///
/// Users select a PDF, choose a compression quality level,
/// and compress the file to reduce its size.
class CompressPdfScreen extends ConsumerStatefulWidget {
  const CompressPdfScreen({super.key});

  @override
  ConsumerState<CompressPdfScreen> createState() => _CompressPdfScreenState();
}

class _CompressPdfScreenState extends ConsumerState<CompressPdfScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pdfState = ref.watch(pdfProvider);
    final pdfNotifier = ref.read(pdfProvider.notifier);
    final isProcessing = pdfState.status == PdfStatus.compressing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress PDF'),
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
            // ── Header ──────────────────────────────────────────────────
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.compress_rounded,
                  size: 42,
                  color: AppTheme.successColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Reduce PDF File Size',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Choose quality level and compress',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Select PDF ─────────────────────────────────────────────
            Text(
              'Select PDF',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            _CompressPdfSelectionCard(
              selectedPath: pdfState.compressPdfPath,
              onTap: () => _selectPdf(pdfNotifier),
            ),
            const SizedBox(height: 28),

            // ── Quality Settings ────────────────────────────────────────
            Text(
              'Compression Quality',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 14),
            _QualityOptionCards(
              selectedQuality: pdfState.compressionQuality,
              onQualitySelected: (quality) =>
                  pdfNotifier.setCompressionQuality(quality),
            ),
            const SizedBox(height: 28),

            // ── Progress Indicator ──────────────────────────────────────
            if (isProcessing) ...[
              Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Compressing PDF…',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.successColor,
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
                      AppTheme.successColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.successColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Error Message ───────────────────────────────────────────
            if (pdfState.status == PdfStatus.error &&
                pdfState.errorMessage != null) ...[
              Container(
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
              const SizedBox(height: 24),
            ],

            // ── Compression Result ──────────────────────────────────────
            if (pdfState.status == PdfStatus.success &&
                pdfState.operationResults.isNotEmpty) ...[
              _CompressionResultCard(
                result: pdfState.operationResults.last,
              ),
              const SizedBox(height: 24),
            ],

            // ── Compress Button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isProcessing ? null : _compressPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.compress_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isProcessing ? 'Compressing…' : 'Compress PDF',
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

  /// Selects a PDF file for compression (placeholder).
  void _selectPdf(PdfNotifier notifier) {
    notifier.setCompressPdfPath('/path/to/document.pdf');
  }

  /// Compresses the selected PDF.
  Future<void> _compressPdf() async {
    final notifier = ref.read(pdfProvider.notifier);
    await notifier.compressPdf();
  }
}

/// PDF selection card for compression.
class _CompressPdfSelectionCard extends StatelessWidget {
  const _CompressPdfSelectionCard({
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
              ? AppTheme.successColor.withValues(alpha: 0.06)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile
                ? AppTheme.successColor.withValues(alpha: 0.3)
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
                color: AppTheme.successColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasFile
                    ? Icons.picture_as_pdf_rounded
                    : Icons.folder_open_rounded,
                color: AppTheme.successColor,
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
                        : 'Choose a PDF to compress',
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
              color: AppTheme.successColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quality option cards for compression level selection.
class _QualityOptionCards extends StatelessWidget {
  const _QualityOptionCards({
    required this.selectedQuality,
    required this.onQualitySelected,
  });

  final double selectedQuality;
  final ValueChanged<double> onQualitySelected;

  static const _qualityLevels = [
    (
      label: 'Low Quality',
      subtitle: 'Smallest file size, reduced clarity',
      quality: AppConstants.pdfCompressionQualityLow,
      icon: Icons.speed_rounded,
      color: AppTheme.accentColor,
    ),
    (
      label: 'Medium Quality',
      subtitle: 'Balanced size and clarity',
      quality: AppConstants.pdfCompressionQualityMedium,
      icon: Icons.balance_rounded,
      color: AppTheme.warningColor,
    ),
    (
      label: 'High Quality',
      subtitle: 'Best clarity, larger file size',
      quality: AppConstants.pdfCompressionQualityHigh,
      icon: Icons.high_quality_rounded,
      color: AppTheme.successColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: _qualityLevels.map((level) {
        final isSelected = (selectedQuality - level.quality).abs() < 0.01;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => onQualitySelected(level.quality),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? level.color.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? level.color.withValues(alpha: 0.4)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: level.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(level.icon, color: level.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? level.color
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          level.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: level.color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Card showing the compression result with before/after comparison.
class _CompressionResultCard extends StatelessWidget {
  const _CompressionResultCard({required this.result});

  final dynamic result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.successColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppTheme.successColor, size: 22),
              const SizedBox(width: 10),
              Text(
                'Compression Complete!',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SizeColumn(
                  label: 'Original',
                  size: result.originalSizeFormatted,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.successColor,
                  size: 24,
                ),
              ),
              Expanded(
                child: _SizeColumn(
                  label: 'Compressed',
                  size: result.resultSizeFormatted,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_down_rounded,
                    color: AppTheme.successColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${result.compressionPercentage.toStringAsFixed(1)}% smaller',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Column showing file size information.
class _SizeColumn extends StatelessWidget {
  const _SizeColumn({
    required this.label,
    required this.size,
    required this.color,
  });

  final String label;
  final String size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          size,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
