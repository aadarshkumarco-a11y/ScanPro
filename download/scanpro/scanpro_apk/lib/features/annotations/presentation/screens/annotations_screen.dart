import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/annotation.dart';
import '../providers/annotation_provider.dart';
import '../widgets/annotation_toolbar.dart';

/// Screen displaying the list of annotations for a specific document.
///
/// Shows annotations grouped by page with the ability to add, edit,
/// and delete annotations. Includes a bottom toolbar for selecting
/// annotation tools.
class AnnotationsScreen extends ConsumerStatefulWidget {
  const AnnotationsScreen({
    super.key,
    required this.documentId,
    this.documentName,
  });

  /// ID of the document whose annotations are displayed.
  final String documentId;

  /// Optional document name for the app bar title.
  final String? documentName;

  @override
  ConsumerState<AnnotationsScreen> createState() => _AnnotationsScreenState();
}

class _AnnotationsScreenState extends ConsumerState<AnnotationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(annotationProvider.notifier)
          .loadAnnotations(widget.documentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const primaryColor = Color(0xFF4D2DAB);
    final annotationState = ref.watch(annotationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentName ?? 'Annotations'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          if (annotationState.selectedTool != null)
            IconButton(
              onPressed: () =>
                  ref.read(annotationProvider.notifier).selectTool(null),
              icon: const Icon(Icons.filter_list_off_rounded),
              tooltip: 'Clear filter',
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Summary Header ────────────────────────────────────────
          _buildSummaryHeader(theme, colorScheme, primaryColor, annotationState),

          // ── Error Banner ──────────────────────────────────────────
          if (annotationState.errorMessage != null)
            _buildErrorBanner(theme, colorScheme, annotationState),

          // ── Annotation List ──────────────────────────────────────
          Expanded(
            child: annotationState.status == AnnotationStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : annotationState.filteredAnnotations.isEmpty
                    ? _buildEmptyState(theme, colorScheme, primaryColor)
                    : _buildAnnotationList(
                        theme,
                        colorScheme,
                        primaryColor,
                        annotationState,
                      ),
          ),

          // ── Bottom Toolbar ───────────────────────────────────────
          AnnotationToolbar(
            selectedTool: annotationState.selectedTool,
            onToolSelected: (type) {
              ref.read(annotationProvider.notifier).selectTool(type);
            },
            onAddAnnotation: () => _showAddAnnotationDialog(
              context,
              primaryColor,
              annotationState.selectedTool ?? AnnotationType.highlight,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the summary header card showing annotation counts.
  Widget _buildSummaryHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
    AnnotationState state,
  ) {
    final total = state.annotations.length;
    final highlightCount = state.countByType(AnnotationType.highlight);
    final drawCount = state.countByType(AnnotationType.draw);
    final shapeCount = state.countByType(AnnotationType.shape);
    final noteCount = state.countByType(AnnotationType.note);
    final textCount = state.countByType(AnnotationType.text);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4D2DAB), Color(0xFF6B4EC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$total Annotation${total == 1 ? '' : 's'}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      state.selectedTool != null
                          ? 'Filtered by: ${_toolDisplayName(state.selectedTool!)}'
                          : 'All annotation types',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCountChip('Highlight', highlightCount, Colors.yellow),
              const SizedBox(width: 8),
              _buildCountChip('Draw', drawCount, Colors.red),
              const SizedBox(width: 8),
              _buildCountChip('Shape', shapeCount, Colors.green),
              const SizedBox(width: 8),
              _buildCountChip('Note', noteCount, Colors.orange),
              const SizedBox(width: 8),
              _buildCountChip('Text', textCount, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a small count chip for the summary header.
  Widget _buildCountChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the error banner.
  Widget _buildErrorBanner(
    ThemeData theme,
    ColorScheme colorScheme,
    AnnotationState state,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(annotationProvider.notifier).clearError(),
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onErrorContainer,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty state when no annotations exist.
  Widget _buildEmptyState(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 48,
                color: primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Annotations Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add highlights, drawings, shapes, notes, or text '
              'annotations to this document.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddAnnotationDialog(
                context,
                primaryColor,
                AnnotationType.highlight,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Annotation'),
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of annotation cards.
  Widget _buildAnnotationList(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
    AnnotationState state,
  ) {
    final annotations = state.filteredAnnotations;

    // Group annotations by page.
    final pageGroups = <int, List<Annotation>>{};
    for (final annotation in annotations) {
      pageGroups.putIfAbsent(annotation.page, () => []).add(annotation);
    }

    final sortedPages = pageGroups.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedPages.length,
      itemBuilder: (context, index) {
        final page = sortedPages[index];
        final pageAnnotations = pageGroups[page]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page header.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Page ${page + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${pageAnnotations.length} annotation${pageAnnotations.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Annotation cards for this page.
            ...pageAnnotations.map(
              (annotation) => _buildAnnotationCard(
                theme,
                colorScheme,
                primaryColor,
                annotation,
              ),
            ),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  /// Builds a single annotation card.
  Widget _buildAnnotationCard(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
    Annotation annotation,
  ) {
    final dateFormatter = DateFormat(AppConstants.displayDateTimeFormat);

    return Dismissible(
      key: ValueKey(annotation.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(annotationProvider.notifier).deleteAnnotation(annotation.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_rounded, color: colorScheme.error),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => _showEditAnnotationDialog(context, primaryColor, annotation),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Type icon.
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _toolColor(annotation.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _toolIcon(annotation.type),
                    color: _toolColor(annotation.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Annotation details.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _toolDisplayName(annotation.type),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (annotation.data['color'] != null)
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _parseColor(annotation.data['color']),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _annotationPreview(annotation),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateFormatter.format(annotation.updatedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions.
                IconButton(
                  onPressed: () => _confirmDelete(context, annotation),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colorScheme.error.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows the add annotation dialog.
  void _showAddAnnotationDialog(
    BuildContext context,
    Color primaryColor,
    AnnotationType type,
  ) {
    final colorController = TextEditingController(text: '#FFFF00');
    final textController = TextEditingController();
    final strokeWidthController = TextEditingController(text: '2.0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${_toolDisplayName(type)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color picker.
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Color (hex)',
                  prefixIcon: Icon(Icons.palette_rounded),
                ),
              ),
              const SizedBox(height: 12),

              // Stroke width for draw.
              if (type == AnnotationType.draw) ...[
                TextField(
                  controller: strokeWidthController,
                  decoration: const InputDecoration(
                    labelText: 'Stroke Width',
                    prefixIcon: Icon(Icons.line_weight_rounded),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
              ],

              // Text content for note/text.
              if (type == AnnotationType.note || type == AnnotationType.text) ...[
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: type == AnnotationType.note ? 'Note Content' : 'Text Content',
                    prefixIcon: const Icon(Icons.text_fields_rounded),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
              ],

              // Shape type for shape annotation.
              if (type == AnnotationType.shape)
                Text(
                  'Shape: Rectangle',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _createAnnotation(type, colorController.text, textController.text, strokeWidthController.text);
            },
            style: FilledButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Shows the edit annotation dialog.
  void _showEditAnnotationDialog(
    BuildContext context,
    Color primaryColor,
    Annotation annotation,
  ) {
    final colorController = TextEditingController(
      text: annotation.data['color']?.toString() ?? '#FFFF00',
    );
    final textController = TextEditingController(
      text: annotation.data['text']?.toString() ?? '',
    );
    final strokeWidthController = TextEditingController(
      text: annotation.data['strokeWidth']?.toString() ?? '2.0',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${_toolDisplayName(annotation.type)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Color (hex)',
                  prefixIcon: Icon(Icons.palette_rounded),
                ),
              ),
              const SizedBox(height: 12),

              if (annotation.type == AnnotationType.draw) ...[
                TextField(
                  controller: strokeWidthController,
                  decoration: const InputDecoration(
                    labelText: 'Stroke Width',
                    prefixIcon: Icon(Icons.line_weight_rounded),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
              ],

              if (annotation.type == AnnotationType.note ||
                  annotation.type == AnnotationType.text) ...[
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: annotation.type == AnnotationType.note
                        ? 'Note Content'
                        : 'Text Content',
                    prefixIcon: const Icon(Icons.text_fields_rounded),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final updatedData = Map<String, dynamic>.from(annotation.data);
              updatedData['color'] = colorController.text;
              if (annotation.type == AnnotationType.draw) {
                updatedData['strokeWidth'] =
                    double.tryParse(strokeWidthController.text) ?? 2.0;
              }
              if (annotation.type == AnnotationType.note ||
                  annotation.type == AnnotationType.text) {
                updatedData['text'] = textController.text;
              }
              ref.read(annotationProvider.notifier).updateAnnotation(
                    annotation.copyWith(data: updatedData),
                  );
            },
            style: FilledButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Creates and adds a new annotation.
  void _createAnnotation(
    AnnotationType type,
    String color,
    String text,
    String strokeWidth,
  ) {
    final now = DateTime.now();
    Map<String, dynamic> data;

    switch (type) {
      case AnnotationType.highlight:
        data = {
          'color': color,
          'text': text,
          'rect': {'left': 0.0, 'top': 0.0, 'width': 100.0, 'height': 20.0},
        };
        break;
      case AnnotationType.draw:
        data = {
          'color': color,
          'strokeWidth': double.tryParse(strokeWidth) ?? 2.0,
          'points': [],
        };
        break;
      case AnnotationType.shape:
        data = {
          'color': color,
          'shapeType': 'rectangle',
          'rect': {'left': 0.0, 'top': 0.0, 'width': 100.0, 'height': 60.0},
        };
        break;
      case AnnotationType.note:
        data = {
          'color': color,
          'text': text.isNotEmpty ? text : 'New note',
          'position': {'x': 50.0, 'y': 50.0},
        };
        break;
      case AnnotationType.text:
        data = {
          'color': color,
          'text': text.isNotEmpty ? text : 'New text',
          'fontSize': 14.0,
          'position': {'x': 50.0, 'y': 50.0},
        };
        break;
    }

    final annotation = Annotation(
      id: '',
      documentId: widget.documentId,
      page: ref.read(annotationProvider).selectedPage ?? 0,
      type: type,
      data: data,
      createdAt: now,
      updatedAt: now,
    );

    ref.read(annotationProvider.notifier).addAnnotation(annotation);
  }

  /// Shows a confirmation dialog before deleting an annotation.
  void _confirmDelete(BuildContext context, Annotation annotation) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Annotation'),
        content: Text(
          'Are you sure you want to delete this ${_toolDisplayName(annotation.type)} annotation? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(annotationProvider.notifier)
                  .deleteAnnotation(annotation.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Helper Methods ──────────────────────────────────────────────

  /// Returns the display name for an annotation type.
  String _toolDisplayName(AnnotationType type) {
    switch (type) {
      case AnnotationType.highlight:
        return 'Highlight';
      case AnnotationType.draw:
        return 'Drawing';
      case AnnotationType.shape:
        return 'Shape';
      case AnnotationType.note:
        return 'Note';
      case AnnotationType.text:
        return 'Text';
    }
  }

  /// Returns the icon for an annotation type.
  IconData _toolIcon(AnnotationType type) {
    switch (type) {
      case AnnotationType.highlight:
        return Icons.highlight_rounded;
      case AnnotationType.draw:
        return Icons.draw_rounded;
      case AnnotationType.shape:
        return Icons.crop_square_rounded;
      case AnnotationType.note:
        return Icons.sticky_note_2_rounded;
      case AnnotationType.text:
        return Icons.text_fields_rounded;
    }
  }

  /// Returns the color for an annotation type.
  Color _toolColor(AnnotationType type) {
    switch (type) {
      case AnnotationType.highlight:
        return Colors.amber;
      case AnnotationType.draw:
        return Colors.red;
      case AnnotationType.shape:
        return Colors.green;
      case AnnotationType.note:
        return Colors.orange;
      case AnnotationType.text:
        return Colors.blue;
    }
  }

  /// Returns a preview string for the annotation.
  String _annotationPreview(Annotation annotation) {
    switch (annotation.type) {
      case AnnotationType.highlight:
        final text = annotation.data['text'] as String? ?? '';
        return text.isNotEmpty ? text : 'Highlighted region';
      case AnnotationType.draw:
        final points = annotation.data['points'];
        final count = points is List ? points.length : 0;
        return 'Freehand drawing ($count points)';
      case AnnotationType.shape:
        final shapeType = annotation.data['shapeType'] as String? ?? 'shape';
        return 'Shape: $shapeType';
      case AnnotationType.note:
        final text = annotation.data['text'] as String? ?? '';
        return text.isNotEmpty ? text : 'Sticky note';
      case AnnotationType.text:
        final text = annotation.data['text'] as String? ?? '';
        return text.isNotEmpty ? text : 'Text annotation';
    }
  }

  /// Parses a color string to a [Color].
  Color _parseColor(dynamic colorValue) {
    if (colorValue is String) {
      try {
        final hex = colorValue.replaceFirst('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        return Colors.yellow;
      }
    }
    return Colors.yellow;
  }
}
