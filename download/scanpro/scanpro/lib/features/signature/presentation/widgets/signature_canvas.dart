import 'package:flutter/material.dart';

class SignatureCanvas extends StatelessWidget {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;
  final double strokeWidth;
  final void Function(Offset point) onStrokeStart;
  final void Function(Offset point) onStrokeUpdate;
  final VoidCallback onStrokeEnd;

  const SignatureCanvas({
    super.key,
    required this.strokes,
    required this.currentStroke,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3.0,
    required this.onStrokeStart,
    required this.onStrokeUpdate,
    required this.onStrokeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onPanStart: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        onStrokeStart(localPosition);
      },
      onPanUpdate: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        onStrokeUpdate(localPosition);
      },
      onPanEnd: (_) => onStrokeEnd(),
      child: CustomPaint(
        painter: _SignaturePainter(
          strokes: strokes,
          currentStroke: currentStroke,
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
          lineColor: theme.colorScheme.outlineVariant,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;
  final double strokeWidth;
  final Color lineColor;

  _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColor,
    required this.strokeWidth,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw baseline
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final baselineY = size.height * 0.75;
    canvas.drawLine(
      Offset(size.width * 0.1, baselineY),
      Offset(size.width * 0.9, baselineY),
      linePaint,
    );

    // Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, strokeColor, strokeWidth);
    }

    // Draw current stroke
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, strokeColor, strokeWidth);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Color color, double width) {
    if (points.length < 2) {
      // Draw a dot if only one point
      canvas.drawCircle(
        points.first,
        width / 2,
        Paint()..color = color,
      );
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length - 1; i++) {
      final midX = (points[i].dx + points[i + 1].dx) / 2;
      final midY = (points[i].dy + points[i + 1].dy) / 2;
      path.quadraticBezierTo(points[i].dx, points[i].dy, midX, midY);
    }

    if (points.length > 1) {
      path.lineTo(points.last.dx, points.last.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
