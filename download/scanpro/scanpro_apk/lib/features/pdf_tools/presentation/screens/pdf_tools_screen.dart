import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/pdf_operation.dart';
import '../widgets/pdf_tool_card.dart';

/// PDF Tools hub screen displaying cards for each available
/// PDF operation (Create, Merge, Split, Compress, Watermark, Protect).
class PdfToolsScreen extends ConsumerWidget {
  const PdfToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Tools'),
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
            // ── Header ────────────────────────────────────────────────
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'PDF Toolkit',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'All the tools you need for PDF management',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Tool Cards Grid ───────────────────────────────────────
            Text(
              'Tools',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                PdfToolCard(
                  icon: Icons.note_add_rounded,
                  title: PdfOperation.create.displayName,
                  description: PdfOperation.create.description,
                  color: AppTheme.primaryColor,
                  onTap: () => context.go(AppRoutes.pdfCreate),
                ),
                PdfToolCard(
                  icon: Icons.merge_type_rounded,
                  title: PdfOperation.merge.displayName,
                  description: PdfOperation.merge.description,
                  color: AppTheme.secondaryColor,
                  onTap: () => context.go(AppRoutes.pdfMerge),
                ),
                PdfToolCard(
                  icon: Icons.call_split_rounded,
                  title: PdfOperation.split.displayName,
                  description: PdfOperation.split.description,
                  color: AppTheme.infoColor,
                  onTap: () => context.go(AppRoutes.pdfSplit),
                ),
                PdfToolCard(
                  icon: Icons.compress_rounded,
                  title: PdfOperation.compress.displayName,
                  description: PdfOperation.compress.description,
                  color: AppTheme.successColor,
                  onTap: () => context.go(AppRoutes.pdfCompress),
                ),
                PdfToolCard(
                  icon: Icons.branding_watermark_rounded,
                  title: PdfOperation.watermark.displayName,
                  description: PdfOperation.watermark.description,
                  color: AppTheme.warningColor,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Watermark tool coming soon!'),
                      ),
                    );
                  },
                ),
                PdfToolCard(
                  icon: Icons.lock_rounded,
                  title: PdfOperation.password.displayName,
                  description: PdfOperation.password.description,
                  color: AppTheme.accentColor,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password protection coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Tips Section ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.08),
                    AppTheme.primaryColor.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pro Tips',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TipRow(
                    text: 'Merge multiple scans into a single PDF',
                  ),
                  const SizedBox(height: 6),
                  _TipRow(
                    text: 'Compress PDFs before sharing to save space',
                  ),
                  const SizedBox(height: 6),
                  _TipRow(
                    text: 'Split large documents for easier handling',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single tip row with a bullet point.
class _TipRow extends StatelessWidget {
  const _TipRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: AppTheme.primaryColor.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
