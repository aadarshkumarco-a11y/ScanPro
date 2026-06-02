import 'package:flutter/material.dart';

class DrawingCanvas extends StatelessWidget {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;
  final double strokeWidth;
  final void Function(Offset point) onStrokeStart;
  final void Function(Offset point) onStrokeUpdate;
  final VoidCallback onStrokeEnd;

  const DrawingCanvas({
    super.key,
    required this.strokes,
    required this.currentStroke,
    this.strokeColor = Colors.yellow,
    this.strokeWidth = 3.0,
    required this.onStrokeStart,
    required this.onStrokeUpdate,
    required this.onStrokeEnd,
  });

  @override
  Widget build(BuildContext context) {
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
        painter: _DrawingPainter(
          strokes: strokes,
          currentStroke: currentStroke,
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;
  final double strokeWidth;

  _DrawingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed strokes
    for (final stroke in strokes) {
      if (stroke.isNotEmpty) {
        _drawSmoothLine(canvas, stroke, strokeColor, strokeWidth);
      }
    }

    // Draw current stroke
    if (currentStroke.isNotEmpty) {
      _drawSmoothLine(canvas, currentStroke, strokeColor, strokeWidth);
    }
  }

  void _drawSmoothLine(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double width,
  ) {
    if (points.length < 2) {
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
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
