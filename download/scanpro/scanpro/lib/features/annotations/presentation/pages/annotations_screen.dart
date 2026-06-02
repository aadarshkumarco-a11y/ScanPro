import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/annotation_provider.dart';
import '../widgets/annotation_toolbar.dart';
import '../widgets/drawing_canvas.dart';

class AnnotationsScreen extends ConsumerStatefulWidget {
  const AnnotationsScreen({super.key});

  @override
  ConsumerState<AnnotationsScreen> createState() => _AnnotationsScreenState();
}

class _AnnotationsScreenState extends ConsumerState<AnnotationsScreen> {
  final List<List<Offset>> _drawStrokes = [];
  List<Offset> _currentStroke = [];

  void _onStrokeStart(Offset point) {
    setState(() {
      _currentStroke = [point];
    });
  }

  void _onStrokeUpdate(Offset point) {
    setState(() {
      _currentStroke = [..._currentStroke, point];
    });
  }

  void _onStrokeEnd() {
    if (_currentStroke.isEmpty) return;
    final annotation = AnnotationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AnnotationType.draw,
      pageIndex: 0,
      points: List.from(_currentStroke),
      color: ref.read(annotationProvider).activeColor,
      createdAt: DateTime.now(),
    );
    ref.read(annotationProvider.notifier).addAnnotation(annotation);
    setState(() {
      _drawStrokes.add(List.from(_currentStroke));
      _currentStroke = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final annotationState = ref.watch(annotationProvider);
    final theme = Theme.of(context);
    final isDrawing = annotationState.activeTool == AnnotationType.draw;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Annotate'),
        actions: [
          IconButton(
            onPressed: annotationState.undoStack.isNotEmpty
                ? () => ref.read(annotationProvider.notifier).undo()
                : null,
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
          ),
          IconButton(
            onPressed: annotationState.redoStack.isNotEmpty
                ? () => ref.read(annotationProvider.notifier).redo()
                : null,
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
          ),
          IconButton(
            onPressed: () {
              _showSaveConfirmation(context);
            },
            icon: const Icon(Icons.check),
            tooltip: 'Save',
          ),
        ],
      ),
      body: Stack(
        children: [
          // PDF placeholder view
          Container(
            color: theme.colorScheme.surfaceContainerLow,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 64,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PDF Document View',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Annotation overlay
          if (isDrawing)
            Positioned.fill(
              child: DrawingCanvas(
                strokes: _drawStrokes,
                currentStroke: _currentStroke,
                strokeColor: _parseColor(annotationState.activeColor),
                strokeWidth: 3.0,
                onStrokeStart: _onStrokeStart,
                onStrokeUpdate: _onStrokeUpdate,
                onStrokeEnd: _onStrokeEnd,
              ),
            ),
          // Highlight/underline overlay indicators
          if (annotationState.activeTool == AnnotationType.highlight ||
              annotationState.activeTool == AnnotationType.underline)
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (_) {
                  // In production, detect text bounds and create annotation
                  final annotation = AnnotationModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: annotationState.activeTool!,
                    pageIndex: 0,
                    color: annotationState.activeColor,
                    createdAt: DateTime.now(),
                  );
                  ref.read(annotationProvider.notifier).addAnnotation(annotation);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Text(
                      'Tap and drag to ${annotationState.activeTool!.name}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Note/text overlay indicators
          if (annotationState.activeTool == AnnotationType.note ||
              annotationState.activeTool == AnnotationType.text)
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) {
                  _showAddNoteDialog(context, annotationState.activeTool!);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Text(
                      'Tap to add ${annotationState.activeTool!.name}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Annotation count badge
          if (annotationState.annotations.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${annotationState.annotations.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 200.ms),
        ],
      ),
      bottomNavigationBar: AnnotationToolbar(
        activeTool: annotationState.activeTool,
        activeColor: annotationState.activeColor,
        onToolSelected: (type) {
          ref.read(annotationProvider.notifier).setActiveTool(type);
        },
        onColorSelected: (color) {
          ref.read(annotationProvider.notifier).setActiveColor(color);
        },
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _showAddNoteDialog(BuildContext context, AnnotationType type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == AnnotationType.note ? 'Add Note' : 'Add Text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: type == AnnotationType.note ? 3 : 1,
          decoration: InputDecoration(
            hintText: type == AnnotationType.note
                ? 'Enter your note...'
                : 'Enter text...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final annotation = AnnotationModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: type,
                  pageIndex: 0,
                  text: controller.text,
                  color: ref.read(annotationProvider).activeColor,
                  createdAt: DateTime.now(),
                );
                ref.read(annotationProvider.notifier).addAnnotation(annotation);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSaveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Annotations'),
        content: const Text(
          'All annotations will be saved to the document. '
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
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
