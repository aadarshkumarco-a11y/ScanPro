/// Document crop and perspective adjustment screen.
///
/// Displays the captured image with four draggable corner handles
/// for manual edge adjustment, perspective correction preview,
/// and navigation to the enhancement step.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/features/scanner/domain/entities/edge_detection_result.dart';
import 'package:scanpro/features/scanner/presentation/providers/scanner_provider.dart';

/// Screen for adjusting the detected document edges before cropping.
///
/// The user can drag the four corner points to fine-tune the crop area.
/// A "Next" button proceeds to the enhancement screen with the
/// perspective-corrected image.
class CropScreen extends ConsumerStatefulWidget {
  const CropScreen({super.key});

  @override
  ConsumerState<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends ConsumerState<CropScreen> {
  late List<Offset> _corners;
  bool _isCropApplied = false;

  @override
  void initState() {
    super.initState();
    _corners = const [
      Offset(0.1, 0.1), // top-left
      Offset(0.9, 0.1), // top-right
      Offset(0.9, 0.9), // bottom-right
      Offset(0.1, 0.9), // bottom-left
    ];
  }

  void _onCornerDrag(int index, Offset localPosition, Size imageSize) {
    setState(() {
      _corners[index] = Offset(
        (localPosition.dx / imageSize.width).clamp(0.0, 1.0),
        (localPosition.dy / imageSize.height).clamp(0.0, 1.0),
      );
    });
  }

  void _resetCorners() {
    setState(() {
      _corners = const [
        Offset(0.1, 0.1),
        Offset(0.9, 0.1),
        Offset(0.9, 0.9),
        Offset(0.1, 0.9),
      ];
      _isCropApplied = false;
    });
  }

  void _rotateCorners() {
    setState(() {
      final last = _corners.removeLast();
      _corners.insert(0, last);
    });
  }

  Future<void> _applyCrop() async {
    setState(() => _isCropApplied = true);
    // Update the capture state with the adjusted edges
    final edgePoints = _corners
        .map((c) => EdgePoint(x: c.dx, y: c.dy))
        .toList();
    final result = EdgeDetectionResult(
      points: edgePoints,
      confidence: 1.0,
      isDocumentDetected: true,
    );
    ref.read(captureProvider.notifier).updateWithEdges(result);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final captureState = ref.watch(captureProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Adjust Crop'),
        actions: [
          TextButton(
            onPressed: _resetCorners,
            child: Text(
              'Reset',
              style: TextStyle(color: colorScheme.primaryContainer),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Image with corner handles ───────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSmall),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final imageSize = Size(constraints.maxWidth, constraints.maxHeight);
                  return Stack(
                    children: [
                      // Image placeholder
                      Container(
                        width: imageSize.width,
                        height: imageSize.height,
                        color: const Color(0xFF2A2A2A),
                        child: const Center(
                          child: Icon(
                            Icons.description_outlined,
                            size: 80,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                      // Crop polygon overlay
                      if (!_isCropApplied) ...[
                        CustomPaint(
                          size: imageSize,
                          painter: _CropOverlayPainter(
                            corners: _corners,
                            screenSize: imageSize,
                          ),
                        ),
                        // Draggable corner handles
                        for (int i = 0; i < 4; i++)
                          _DraggableCorner(
                            index: i,
                            position: Offset(
                              _corners[i].dx * imageSize.width,
                              _corners[i].dy * imageSize.height,
                            ),
                            imageSize: imageSize,
                            onDrag: (pos) => _onCornerDrag(i, pos, imageSize),
                          ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),

          // ── Perspective preview when crop applied ───────────
          if (_isCropApplied)
            Center(
              child: Container(
                margin: const EdgeInsets.all(Dimensions.paddingLarge),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.crop_free, size: 64, color: Colors.white54),
                      SizedBox(height: 12),
                      Text(
                        'Perspective Corrected',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        ],
      ),
      // ── Bottom action bar ────────────────────────────────────
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: EdgeInsets.only(
          left: Dimensions.paddingMedium,
          right: Dimensions.paddingMedium,
          bottom: MediaQuery.of(context).padding.bottom + 12,
          top: Dimensions.spacing12,
        ),
        child: Row(
          children: [
            // Rotate
            IconButton(
              icon: const Icon(Icons.rotate_right, color: Colors.white70),
              onPressed: _rotateCorners,
              tooltip: 'Rotate 90°',
            ),
            const Spacer(),
            // Crop / Next button
            FilledButton(
              onPressed: () {
                if (!_isCropApplied) {
                  _applyCrop();
                } else {
                  context.push('/scanner/enhance');
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.scannerAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingLarge,
                  vertical: Dimensions.spacing12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.buttonCornerRadius),
                ),
              ),
              child: Text(
                _isCropApplied ? 'Next' : 'Apply Crop',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Crop Overlay Painter
// ---------------------------------------------------------------------------

class _CropOverlayPainter extends CustomPainter {
  final List<Offset> corners;
  final Size screenSize;

  _CropOverlayPainter({required this.corners, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    final points =
        corners.map((c) => Offset(c.dx * size.width, c.dy * size.height)).toList();

    // Dim overlay outside crop area
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()..addPolygon(points, true);
    final overlay =
        Path.combine(PathOperation.difference, fullPath, cutout);
    canvas.drawPath(overlay, Paint()..color = Colors.black.withValues(alpha: 0.55));

    // Border lines
    final linePaint = Paint()
      ..color = AppColors.scannerAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, linePaint);

    // Grid lines (3×3)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;
    for (int i = 1; i <= 2; i++) {
      final t = i / 3.0;
      final left = Offset(
        points[0].dx + (points[3].dx - points[0].dx) * t,
        points[0].dy + (points[3].dy - points[0].dy) * t,
      );
      final right = Offset(
        points[1].dx + (points[2].dx - points[1].dx) * t,
        points[1].dy + (points[2].dy - points[1].dy) * t,
      );
      canvas.drawLine(left, right, gridPaint);

      final top = Offset(
        points[0].dx + (points[1].dx - points[0].dx) * t,
        points[0].dy + (points[1].dy - points[0].dy) * t,
      );
      final bottom = Offset(
        points[3].dx + (points[2].dx - points[3].dx) * t,
        points[3].dy + (points[2].dy - points[3].dy) * t,
      );
      canvas.drawLine(top, bottom, gridPaint);
    }
  }

  @override
  bool shouldRepaint(_CropOverlayPainter oldDelegate) =>
      corners != oldDelegate.corners;
}

// ---------------------------------------------------------------------------
// Draggable Corner Handle
// ---------------------------------------------------------------------------

class _DraggableCorner extends StatelessWidget {
  final int index;
  final Offset position;
  final Size imageSize;
  final ValueChanged<Offset> onDrag;

  const _DraggableCorner({
    required this.index,
    required this.position,
    required this.imageSize,
    required this.onDrag,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 20,
      top: position.dy - 20,
      child: GestureDetector(
        onPanUpdate: (details) {
          final localPos = details.globalPosition;
          final box = context.findRenderObject() as RenderBox;
          final parentBox = box.parent as RenderBox;
          final parentLocal = parentBox.globalToLocal(localPos);
          onDrag(parentLocal + const Offset(20, 20));
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.scannerAccent,
              width: 2.5,
            ),
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.scannerAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
