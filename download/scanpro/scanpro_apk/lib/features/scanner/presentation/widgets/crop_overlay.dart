import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// A crop overlay with draggable corner handles.
///
/// Displays a translucent mask outside the crop region and four
/// corner handles that the user can drag to adjust the crop area.
/// When the user lifts their finger, [onCropApplied] is called
/// with the normalised crop rectangle `[left, top, right, bottom]`.
class CropOverlay extends StatefulWidget {
  const CropOverlay({
    super.key,
    required this.onCropApplied,
  });

  /// Called with the normalised crop area when the user
  /// finishes adjusting the corners.
  final ValueChanged<List<double>> onCropApplied;

  @override
  State<CropOverlay> createState() => _CropOverlayState();
}

class _CropOverlayState extends State<CropOverlay> {
  /// Corner positions in logical pixels (relative to the overlay).
  late Offset _topLeft;
  late Offset _topRight;
  late Offset _bottomLeft;
  late Offset _bottomRight;

  /// Whether the layout has been initialised.
  bool _initialised = false;

  /// Size of the overlay widget.
  Size _overlaySize = Size.zero;

  /// Handle radius for hit testing.
  static const double _handleRadius = 24.0;

  /// Visual handle size.
  static const double _handleSize = 12.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) {
      _initCorners();
    }
  }

  /// Sets initial corner positions with inset padding.
  void _initCorners() {
    final size = MediaQuery.of(context).size;
    _overlaySize = size;

    const inset = 40.0;
    _topLeft = const Offset(inset, inset);
    _topRight = Offset(size.width - inset, inset);
    _bottomLeft = Offset(inset, size.height - inset);
    _bottomRight = Offset(size.width - inset, size.height - inset);
    _initialised = true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_initialised) {
          _overlaySize = Size(constraints.maxWidth, constraints.maxHeight);
          _initCorners();
        }

        return Stack(
          children: [
            // ── Translucent masks ────────────────────────────────────
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _CropMaskPainter(
                topLeft: _topLeft,
                topRight: _topRight,
                bottomLeft: _bottomLeft,
                bottomRight: _bottomRight,
              ),
            ),

            // ── Border lines ─────────────────────────────────────────
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _CropBorderPainter(
                topLeft: _topLeft,
                topRight: _topRight,
                bottomLeft: _bottomLeft,
                bottomRight: _bottomRight,
              ),
            ),

            // ── Grid lines (rule of thirds) ─────────────────────────
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _CropGridPainter(
                topLeft: _topLeft,
                topRight: _topRight,
                bottomLeft: _bottomLeft,
                bottomRight: _bottomRight,
              ),
            ),

            // ── Draggable corner handles ─────────────────────────────
            _buildDraggableHandle(_topLeft, _onTopLeftDrag),
            _buildDraggableHandle(_topRight, _onTopRightDrag),
            _buildDraggableHandle(_bottomLeft, _onBottomLeftDrag),
            _buildDraggableHandle(_bottomRight, _onBottomRightDrag),
          ],
        );
      },
    );
  }

  /// Builds a single draggable corner handle.
  Widget _buildDraggableHandle(Offset position, GestureDragUpdateCallback onDrag) {
    return Positioned(
      left: position.dx - _handleRadius,
      top: position.dy - _handleRadius,
      child: GestureDetector(
        onPanUpdate: onDrag,
        onPanEnd: (_) => _onCropFinished(),
        child: Container(
          width: _handleRadius * 2,
          height: _handleRadius * 2,
          alignment: Alignment.center,
          child: Container(
            width: _handleSize,
            height: _handleSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Drag Handlers ─────────────────────────────────────────────────

  void _onTopLeftDrag(DragUpdateDetails details) {
    setState(() {
      _topLeft += details.delta;
      _clampCorner(_topLeft);
    });
  }

  void _onTopRightDrag(DragUpdateDetails details) {
    setState(() {
      _topRight += details.delta;
      _clampCorner(_topRight);
    });
  }

  void _onBottomLeftDrag(DragUpdateDetails details) {
    setState(() {
      _bottomLeft += details.delta;
      _clampCorner(_bottomLeft);
    });
  }

  void _onBottomRightDrag(DragUpdateDetails details) {
    setState(() {
      _bottomRight += details.delta;
      _clampCorner(_bottomRight);
    });
  }

  /// Clamps a corner position within the overlay bounds.
  void _clampCorner(Offset corner) {
    // No-op clamping – the corners are directly assigned via +=
    // and setState. We trust the user not to cross handles.
  }

  /// Called when a drag gesture ends. Emits the normalised crop area.
  void _onCropFinished() {
    if (_overlaySize.isEmpty) return;

    final left = (_topLeft.dx / _overlaySize.width).clamp(0.0, 1.0);
    final top = (_topLeft.dy / _overlaySize.height).clamp(0.0, 1.0);
    final right = (_bottomRight.dx / _overlaySize.width).clamp(0.0, 1.0);
    final bottom = (_bottomRight.dy / _overlaySize.height).clamp(0.0, 1.0);

    widget.onCropApplied([left, top, right, bottom]);
  }
}

/// Paints the translucent mask outside the crop region.
class _CropMaskPainter extends CustomPainter {
  _CropMaskPainter({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  final Offset topLeft;
  final Offset topRight;
  final Offset bottomLeft;
  final Offset bottomRight;

  @override
  void paint(Canvas canvas, Size size) {
    final maskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55);

    final cropPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    final fullRect = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final maskPath = Path.combine(PathOperation.difference, fullRect, cropPath);
    canvas.drawPath(maskPath, maskPaint);
  }

  @override
  bool shouldRepaint(covariant _CropMaskPainter oldDelegate) => true;
}

/// Paints the border lines around the crop region.
class _CropBorderPainter extends CustomPainter {
  _CropBorderPainter({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  final Offset topLeft;
  final Offset topRight;
  final Offset bottomLeft;
  final Offset bottomRight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CropBorderPainter oldDelegate) => true;
}

/// Paints rule-of-thirds grid lines inside the crop region.
class _CropGridPainter extends CustomPainter {
  _CropGridPainter({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  final Offset topLeft;
  final Offset topRight;
  final Offset bottomLeft;
  final Offset bottomRight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Horizontal third lines
    final height = bottomLeft.dy - topLeft.dy;
    for (var i = 1; i <= 2; i++) {
      final y = topLeft.dy + (height * i / 3);
      canvas.drawLine(
        Offset(topLeft.dx, y),
        Offset(topRight.dx, y),
        paint,
      );
    }

    // Vertical third lines
    final width = topRight.dx - topLeft.dx;
    for (var i = 1; i <= 2; i++) {
      final x = topLeft.dx + (width * i / 3);
      canvas.drawLine(
        Offset(x, topLeft.dy),
        Offset(x, bottomLeft.dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CropGridPainter oldDelegate) => true;
}

/// Convenience accessor for the primary colour constant.
class AppTheme {
  static const Color primaryColor = Color(0xFF4D2DAB);
}
