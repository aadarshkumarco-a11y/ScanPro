import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/pdf_provider.dart';

/// Create PDF screen for selecting images and ordering pages.
///
/// Users can add images from gallery or scanner, reorder them
/// via drag-and-drop, and create a PDF document.
class CreatePdfScreen extends ConsumerStatefulWidget {
  const CreatePdfScreen({super.key});

  @override
  ConsumerState<CreatePdfScreen> createState() => _CreatePdfScreenState();
}

class _CreatePdfScreenState extends ConsumerState<CreatePdfScreen> {
  final _fileNameController = TextEditingController(text: 'ScanPro_Document');

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
    final isProcessing = pdfState.status == PdfStatus.creating;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create PDF'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          if (pdfState.selectedImagePaths.isNotEmpty)
            TextButton(
              onPressed: isProcessing ? null : _createPdf,
              child: Text(
                'Create',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── File Name Input ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              controller: _fileNameController,
              decoration: InputDecoration(
                labelText: 'File Name',
                hintText: 'Enter PDF file name',
                suffixIcon: const Icon(Icons.edit_rounded, size: 18),
                prefixIcon: const Icon(Icons.description_rounded, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Add Images Button ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isProcessing
                    ? null
                    : () => _addImages(pdfNotifier),
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 20),
                label: const Text('Add Images'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Progress Indicator ───────────────────────────────────────
          if (isProcessing) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
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
                        'Creating PDF…',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PDF Created Successfully!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.successColor,
                            ),
                          ),
                          Text(
                            pdfState.currentDocument!.fileName,
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

          // ── Image List ───────────────────────────────────────────────
          Expanded(
            child: pdfState.selectedImagePaths.isEmpty
                ? _buildEmptyState(theme, colorScheme)
                : _buildImageList(theme, pdfState, pdfNotifier),
          ),
        ],
      ),
      bottomNavigationBar: pdfState.selectedImagePaths.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _createPdf,
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
                      const Icon(Icons.picture_as_pdf_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Create PDF (${pdfState.selectedImagePaths.length} pages)',
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

  /// Builds the empty state when no images are selected.
  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'No images selected',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add images to create a PDF document',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the reorderable image list.
  Widget _buildImageList(
    ThemeData theme,
    PdfState pdfState,
    PdfNotifier pdfNotifier,
  ) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: pdfState.selectedImagePaths.length,
      onReorder: pdfNotifier.reorderImages,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(animation.value);
            return Transform.scale(
              scale: 1.0 + t * 0.05,
              child: Opacity(
                opacity: 1.0 - t * 0.2,
                child: child,
              ),
            );
          },
        );
      },
      itemBuilder: (context, index) {
        final imagePath = pdfState.selectedImagePaths[index];
        return Container(
          key: ValueKey('image_$index'),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            title: Text(
              imagePath.split('/').last,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Page ${index + 1}',
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
                  onPressed: () => pdfNotifier.removeImage(index),
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

  /// Adds images to the list (placeholder for file picker).
  void _addImages(PdfNotifier notifier) {
    // In production, use file_picker or image_picker
    // For now, add placeholder image paths
    notifier.addImage('/path/to/image_${DateTime.now().millisecondsSinceEpoch}.jpg');
  }

  /// Creates the PDF from selected images.
  Future<void> _createPdf() async {
    final notifier = ref.read(pdfProvider.notifier);
    await notifier.createPdf(fileName: _fileNameController.text);
  }
}

/// Animated builder helper for reorderable list.
class AnimatedBuilder extends StatelessWidget {
  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder_(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilder_ extends AnimatedWidget {
  const AnimatedBuilder_({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
