import 'package:flutter/material.dart';

import '../../domain/entities/annotation.dart';

/// Overlay widget for highlighting text on PDF pages.
///
/// Renders a semi-transparent colored rectangle over the highlighted
/// text area, along with an optional text label. Used inside a
/// [Stack] positioned on top of the PDF page view.
class HighlightOverlay extends StatelessWidget {
  const HighlightOverlay({
    super.key,
    required this.annotations,
    required this.pageWidth,
    required this.pageHeight,
    this.onAnnotationTap,
    this.onAnnotationLongPress,
  });

  /// List of annotations to render as highlights on this page.
  ///
  /// Only annotations of type [AnnotationType.highlight] will
  /// render as highlight overlays. Other types are rendered
  /// with their respective visual representations.
  final List<Annotation> annotations;

  /// The logical width of the PDF page for coordinate scaling.
  final double pageWidth;

  /// The logical height of the PDF page for coordinate scaling.
  final double pageHeight;

  /// Callback when an annotation is tapped.
  final ValueChanged<Annotation>? onAnnotationTap;

  /// Callback when an annotation is long-pressed.
  final ValueChanged<Annotation>? onAnnotationLongPress;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: annotations.map((annotation) {
        return _buildAnnotationOverlay(context, annotation);
      }).toList(),
    );
  }

  /// Builds the visual overlay for a single annotation.
  Widget _buildAnnotationOverlay(BuildContext context, Annotation annotation) {
    switch (annotation.type) {
      case AnnotationType.highlight:
        return _buildHighlightRect(context, annotation);
      case AnnotationType.draw:
        return _buildDrawingOverlay(context, annotation);
      case AnnotationType.shape:
        return _buildShapeOverlay(context, annotation);
      case AnnotationType.note:
        return _buildNoteOverlay(context, annotation);
      case AnnotationType.text:
        return _buildTextOverlay(context, annotation);
    }
  }

  /// Builds a highlight rectangle overlay.
  Widget _buildHighlightRect(BuildContext context, Annotation annotation) {
    final rect = _parseRect(annotation.data['rect']);
    final color = _parseColor(annotation.data['color'], Colors.yellow);

    if (rect == null) return const SizedBox.shrink();

    return Positioned(
      left: rect.left * pageWidth,
      top: rect.top * pageHeight,
      width: rect.width * pageWidth,
      height: rect.height * pageHeight,
      child: GestureDetector(
        onTap: () => onAnnotationTap?.call(annotation),
        onLongPress: () => onAnnotationLongPress?.call(annotation),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// Builds a freehand drawing overlay.
  Widget _buildDrawingOverlay(BuildContext context, Annotation annotation) {
    final points = annotation.data['points'];
    final color = _parseColor(annotation.data['color'], Colors.red);
    final strokeWidth =
        (annotation.data['strokeWidth'] as num?)?.toDouble() ?? 2.0;

    if (points is! List || points.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => onAnnotationTap?.call(annotation),
        onLongPress: () => onAnnotationLongPress?.call(annotation),
        child: CustomPaint(
          painter: _FreehandPainter(
            points: points,
            color: color,
            strokeWidth: strokeWidth,
            pageWidth: pageWidth,
            pageHeight: pageHeight,
          ),
        ),
      ),
    );
  }

  /// Builds a shape overlay (rectangle, circle, arrow).
  Widget _buildShapeOverlay(BuildContext context, Annotation annotation) {
    final rect = _parseRect(annotation.data['rect']);
    final color = _parseColor(annotation.data['color'], Colors.green);
    final shapeType = annotation.data['shapeType'] as String? ?? 'rectangle';

    if (rect == null) return const SizedBox.shrink();

    return Positioned(
      left: rect.left * pageWidth,
      top: rect.top * pageHeight,
      width: rect.width * pageWidth,
      height: rect.height * pageHeight,
      child: GestureDetector(
        onTap: () => onAnnotationTap?.call(annotation),
        onLongPress: () => onAnnotationLongPress?.call(annotation),
        child: CustomPaint(
          painter: _ShapePainter(
            shapeType: shapeType,
            color: color,
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }

  /// Builds a sticky note overlay.
  Widget _buildNoteOverlay(BuildContext context, Annotation annotation) {
    final position = _parsePosition(annotation.data['position']);
    final color = _parseColor(annotation.data['color'], Colors.orange);
    final text = annotation.data['text'] as String? ?? 'Note';

    if (position == null) return const SizedBox.shrink();

    return Positioned(
      left: position.dx * pageWidth,
      top: position.dy * pageHeight,
      child: GestureDetector(
        onTap: () => onAnnotationTap?.call(annotation),
        onLongPress: () => onAnnotationLongPress?.call(annotation),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: pageWidth * 0.4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sticky_note_2_rounded,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a text annotation overlay.
  Widget _buildTextOverlay(BuildContext context, Annotation annotation) {
    final position = _parsePosition(annotation.data['position']);
    final color = _parseColor(annotation.data['color'], Colors.black);
    final text = annotation.data['text'] as String? ?? 'Text';
    final fontSize = (annotation.data['fontSize'] as num?)?.toDouble() ?? 14.0;

    if (position == null) return const SizedBox.shrink();

    return Positioned(
      left: position.dx * pageWidth,
      top: position.dy * pageHeight,
      child: GestureDetector(
        onTap: () => onAnnotationTap?.call(annotation),
        onLongPress: () => onAnnotationLongPress?.call(annotation),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ── Parsing Helpers ──────────────────────────────────────────────

  /// Parses a dynamic value to a [Rect], returning null on failure.
  ///
  /// The input can be a Map with left/top/width/height keys
  /// (values 0.0–1.0 as fractions of the page size).
  Rect? _parseRect(dynamic value) {
    if (value is Map) {
      try {
        return Rect.fromLTWH(
          (value['left'] as num).toDouble(),
          (value['top'] as num).toDouble(),
          (value['width'] as num).toDouble(),
          (value['height'] as num).toDouble(),
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Parses a dynamic value to an [Offset], returning null on failure.
  Offset? _parsePosition(dynamic value) {
    if (value is Map) {
      try {
        return Offset(
          (value['x'] as num).toDouble(),
          (value['y'] as num).toDouble(),
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Parses a dynamic color value to a [Color].
  Color _parseColor(dynamic value, Color defaultColor) {
    if (value is String) {
      try {
        final hex = value.replaceFirst('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        return defaultColor;
      }
    }
    return defaultColor;
  }
}

/// Custom painter for freehand drawing annotations.
class _FreehandPainter extends CustomPainter {
  _FreehandPainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.pageWidth,
    required this.pageHeight,
  });

  final List<dynamic> points;
  final Color color;
  final double strokeWidth;
  final double pageWidth;
  final double pageHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      if (point is! Map) continue;

      final x = (point['x'] as num?)?.toDouble() ?? 0.0;
      final y = (point['y'] as num?)?.toDouble() ?? 0.0;

      final dx = x * pageWidth;
      final dy = y * pageHeight;

      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FreehandPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Custom painter for shape annotations.
class _ShapePainter extends CustomPainter {
  _ShapePainter({
    required this.shapeType,
    required this.color,
    required this.strokeWidth,
  });

  final String shapeType;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    switch (shapeType) {
      case 'rectangle':
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          paint,
        );
        break;
      case 'circle':
        canvas.drawOval(
          Rect.fromLTWH(0, 0, size.width, size.height),
          paint,
        );
        break;
      case 'arrow':
        final path = Path();
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(size.width - 10, size.height / 2 - 8);
        path.moveTo(size.width, size.height / 2);
        path.lineTo(size.width - 10, size.height / 2 + 8);
        canvas.drawPath(path, paint);
        break;
      default:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) {
    return oldDelegate.shapeType != shapeType ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
