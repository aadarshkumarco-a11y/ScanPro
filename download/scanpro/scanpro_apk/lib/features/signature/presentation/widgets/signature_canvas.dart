import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// CustomPainter-based signature drawing canvas.
///
/// Captures touch/stylus input and renders the drawn path
/// in real time. Supports undo, clear, and PNG export.
class SignatureCanvas extends StatefulWidget {
  const SignatureCanvas({
    super.key,
    this.penColor = Colors.black,
    this.penWidth = 3.0,
  });

  /// The color of the pen stroke.
  final Color penColor;

  /// The width of the pen stroke.
  final double penWidth;

  @override
  State<SignatureCanvas> createState() => SignatureCanvasState();
}

class SignatureCanvasState extends State<SignatureCanvas> {
  /// The list of completed strokes (each stroke is a list of points).
  final List<List<_StrokePoint>> _strokes = [];

  /// The current stroke being drawn.
  List<_StrokePoint>? _currentStroke;

  /// Whether the canvas has any content.
  bool get isEmpty => _strokes.isEmpty && _currentStroke == null;

  /// Undoes the last stroke.
  void undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
      });
    }
  }

  /// Clears all strokes.
  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
    });
  }

  /// Exports the current canvas as PNG bytes.
  Future<ByteData?> exportPngBytes() async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final size = context.size ?? const Size(400, 200);

      // White background.
      final paint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );

      // Draw all strokes.
      for (final stroke in _strokes) {
        _drawStrokeOnCanvas(canvas, stroke, size);
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      return image.toByteData(format: ui.ImageByteFormat.png);
    } catch (e) {
      return null;
    }
  }

  /// Draws a single stroke onto a Canvas.
  void _drawStrokeOnCanvas(
    Canvas canvas,
    List<_StrokePoint> points,
    Size size,
  ) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = widget.penColor
      ..strokeWidth = widget.penWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.x * size.width, points.first.y * size.height);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(
        points[i].x * size.width,
        points[i].y * size.height,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        final pos = _toNormalized(details.localPosition);
        setState(() {
          _currentStroke = [
            _StrokePoint(pos.dx, pos.dy, DateTime.now()),
          ];
        });
      },
      onPanUpdate: (details) {
        final pos = _toNormalized(details.localPosition);
        setState(() {
          _currentStroke?.add(
            _StrokePoint(pos.dx, pos.dy, DateTime.now()),
          );
        });
      },
      onPanEnd: (details) {
        if (_currentStroke != null && _currentStroke!.isNotEmpty) {
          setState(() {
            _strokes.add(List.from(_currentStroke!));
            _currentStroke = null;
          });
        }
      },
      child: CustomPaint(
        painter: _SignaturePainter(
          strokes: _strokes,
          currentStroke: _currentStroke,
          penColor: widget.penColor,
          penWidth: widget.penWidth,
        ),
        size: Size.infinite,
      ),
    );
  }

  /// Converts a local position to normalized (0.0–1.0) coordinates.
  Offset _toNormalized(Offset localPosition) {
    final size = context.size ?? const Size(1, 1);
    return Offset(
      (localPosition.dx / size.width).clamp(0.0, 1.0),
      (localPosition.dy / size.height).clamp(0.0, 1.0),
    );
  }
}

/// A single point in a signature stroke.
class _StrokePoint {
  final double x;
  final double y;
  final DateTime timestamp;

  const _StrokePoint(this.x, this.y, this.timestamp);
}

/// CustomPainter that renders all signature strokes.
class _SignaturePainter extends CustomPainter {
  _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.penColor,
    required this.penWidth,
  });

  final List<List<_StrokePoint>> strokes;
  final List<_StrokePoint>? currentStroke;
  final Color penColor;
  final double penWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed strokes.
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, size);
    }

    // Draw the current in-progress stroke.
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!, size);
    }
  }

  void _drawStroke(Canvas canvas, List<_StrokePoint> points, Size size) {
    if (points.length < 2) {
      // Draw a dot for single-point strokes.
      if (points.length == 1) {
        final paint = Paint()
          ..color = penColor
          ..strokeWidth = penWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(
            points.first.x * size.width,
            points.first.y * size.height,
          ),
          penWidth / 2,
          paint,
        );
      }
      return;
    }

    final paint = Paint()
      ..color = penColor
      ..strokeWidth = penWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(
      points.first.x * size.width,
      points.first.y * size.height,
    );

    // Use quadratic bezier for smooth curves.
    for (int i = 1; i < points.length - 1; i++) {
      final current = Offset(
        points[i].x * size.width,
        points[i].y * size.height,
      );
      final next = Offset(
        points[i + 1].x * size.width,
        points[i + 1].y * size.height,
      );
      final midX = (current.dx + next.dx) / 2;
      final midY = (current.dy + next.dy) / 2;

      path.quadraticBezierTo(
        current.dx,
        current.dy,
        midX,
        midY,
      );
    }

    // Final segment.
    final last = points.last;
    path.lineTo(
      last.x * size.width,
      last.y * size.height,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    // Always repaint when strokes change.
    return strokes.length != oldDelegate.strokes.length ||
        currentStroke != oldDelegate.currentStroke;
  }
}
