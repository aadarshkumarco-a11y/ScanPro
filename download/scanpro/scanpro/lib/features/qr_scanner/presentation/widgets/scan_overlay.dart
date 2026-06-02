import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScanOverlay extends StatefulWidget {
  final double scanAreaSize;

  const ScanOverlay({
    super.key,
    this.scanAreaSize = 250,
  });

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay> with TickerProviderStateMixin {
  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanSize = widget.scanAreaSize;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2 - 60;

    return Stack(
      children: [
        // Semi-transparent overlay with cutout
        ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black54,
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Positioned(
                left: left,
                top: top,
                child: Container(
                  width: scanSize,
                  height: scanSize,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Corner brackets
        Positioned(
          left: left,
          top: top,
          child: _CornerBrackets(size: scanSize),
        ),
        // Animated scan line
        Positioned(
          left: left + 16,
          top: top,
          width: scanSize - 32,
          height: scanSize,
          child: AnimatedBuilder(
            animation: _scanLineController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: _scanLineController.value * (scanSize - 2),
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF4D2DAB),
                            const Color(0xFF4D2DAB),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.2, 0.8, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4D2DAB).withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CornerBrackets extends StatelessWidget {
  final double size;
  final double cornerLength;
  final double strokeWidth;
  final Color color;

  const _CornerBrackets({
    required this.size,
    this.cornerLength = 30,
    this.strokeWidth = 3,
    this.color = const Color(0xFF4D2DAB),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CornerBracketPainter(
        cornerLength: cornerLength,
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final double cornerLength;
  final double strokeWidth;
  final Color color;

  _CornerBracketPainter({
    required this.cornerLength,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final radius = 12.0;
    final cl = cornerLength;

    // Top-left corner
    canvas.drawPath(
      _drawCorner(
        Offset(radius, cl + radius),
        Offset(radius, radius),
        Offset(cl + radius, radius),
        radius,
        paint,
      ),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      _drawCorner(
        Offset(size.width - cl - radius, radius),
        Offset(size.width - radius, radius),
        Offset(size.width - radius, cl + radius),
        radius,
        paint,
      ),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      _drawCorner(
        Offset(cl + radius, size.height - radius),
        Offset(radius, size.height - radius),
        Offset(radius, size.height - cl - radius),
        radius,
        paint,
      ),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      _drawCorner(
        Offset(size.width - radius, size.height - cl - radius),
        Offset(size.width - radius, size.height - radius),
        Offset(size.width - cl - radius, size.height - radius),
        radius,
        paint,
      ),
      paint,
    );
  }

  Path _drawCorner(Offset start, Offset corner, Offset end, double radius, Paint paint) {
    return Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(corner.dx, corner.dy)
      ..lineTo(end.dx, end.dy);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
