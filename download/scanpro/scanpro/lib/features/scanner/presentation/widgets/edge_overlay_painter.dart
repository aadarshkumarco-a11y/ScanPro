/// CustomPainter that renders document edge detection overlay.
///
/// Draws animated dashed lines connecting four detected edge points
/// and highlighted corner handles. Supports both detected (green)
/// and detecting (white) color states.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scanpro/features/scanner/domain/entities/edge_detection_result.dart';

/// Painter for the document edge detection overlay on the camera preview.
///
/// [edges] provides the four corner points in normalized coordinates.
/// [isDetected] switches the overlay colour from white to green.
/// [animationValue] drives the dashed-line marching-ants animation (0.0–1.0).
class EdgeOverlayPainter extends CustomPainter {
  final EdgeDetectionResult? edges;
  final bool isDetected;
  final double animationValue;

  EdgeOverlayPainter({
    required this.edges,
    required this.isDetected,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (edges == null || !edges!.hasValidPoints) return;

    final points = edges!.points
        .map((p) => Offset(p.x * size.width, p.y * size.height))
        .toList();

    final lineColor =
        isDetected ? const Color(0xFF4CAF50) : const Color(0xFFFFFFFF);

    // Dim overlay outside detected area
    _drawDimOverlay(canvas, size, points);

    // Dashed border lines
    _drawDashedPolygon(canvas, points, lineColor);

    // Corner handles
    for (final point in points) {
      _drawCornerHandle(canvas, point, lineColor);
    }
  }

  void _drawDimOverlay(Canvas canvas, Size size, List<Offset> points) {
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()
      ..addPolygon(points, true);

    final overlay = Path.combine(PathOperation.difference, fullPath, cutout);
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    canvas.drawPath(overlay, paint);
  }

  void _drawDashedPolygon(Canvas canvas, List<Offset> points, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const dashLength = 12.0;
    const gapLength = 8.0;
    final totalCycle = dashLength + gapLength;
    final offset = (animationValue * totalCycle) % totalCycle;

    for (int i = 0; i < points.length; i++) {
      final start = points[i];
      final end = points[(i + 1) % points.length];
      _drawDashedLine(canvas, start, end, paint, dashLength, gapLength, offset);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashLength,
    double gapLength,
    double offset,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final totalLength = sqrt(dx * dx + dy * dy);
    if (totalLength == 0) return;

    final unitX = dx / totalLength;
    final unitY = dy / totalLength;
    final totalCycle = dashLength + gapLength;

    double pos = -offset;
    while (pos < totalLength) {
      final from = pos.clamp(0.0, totalLength);
      final to = (pos + dashLength).clamp(0.0, totalLength);
      if (from < to) {
        canvas.drawLine(
          Offset(start.dx + unitX * from, start.dy + unitY * from),
          Offset(start.dx + unitX * to, start.dy + unitY * to),
          paint,
        );
      }
      pos += totalCycle;
    }
  }

  void _drawCornerHandle(Canvas canvas, Offset center, Color color) {
    // White outer circle
    canvas.drawCircle(
      center,
      12,
      Paint()..color = Colors.white,
    );
    // Colored inner circle
    canvas.drawCircle(
      center,
      8,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(EdgeOverlayPainter oldDelegate) {
    return oldDelegate.edges != edges ||
        oldDelegate.isDetected != isDetected ||
        oldDelegate.animationValue != animationValue;
  }
}
