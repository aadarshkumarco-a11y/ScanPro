/// Full camera scanner screen with live preview and edge detection overlay.
///
/// Provides auto-capture mode, flash toggle, gallery import, and
/// real-time document edge detection overlay with animated dashed lines.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:scanpro/features/scanner/presentation/widgets/capture_button.dart';
import 'package:scanpro/features/scanner/presentation/widgets/edge_overlay_painter.dart';

/// Main camera scanner screen.
///
/// Uses [ScannerNotifier] for camera state, [CaptureNotifier] for
/// the capture workflow, and [EdgeOverlayPainter] for the live overlay.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with TickerProviderStateMixin {
  late final AnimationController _edgeAnimController;

  @override
  void initState() {
    super.initState();
    _edgeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    // Simulate camera ready after a short delay
    Future.microtask(() {
      ref.read(scannerStateProvider.notifier).setCameraReady(true);
    });
  }

  @override
  void dispose() {
    _edgeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerStateProvider);
    final captureState = ref.watch(captureProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera Preview Area ──────────────────────────────
          _buildCameraPreview(scannerState),

          // ── Top Bar ──────────────────────────────────────────
          SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSmall,
                vertical: Dimensions.spacing8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  // Flash toggle
                  _FlashToggle(
                    flashMode: scannerState.flashMode,
                    onToggle: () =>
                        ref.read(scannerStateProvider.notifier).toggleFlash(),
                  ),
                  const SizedBox(width: Dimensions.spacing8),
                  // Gallery import
                  IconButton(
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                    ),
                    onPressed: _onGalleryImport,
                    tooltip: 'Import from gallery',
                  ),
                ],
              ),
            ),
          ),

          // ── Document Detected Banner ────────────────────────
          if (scannerState.documentDetected)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingMedium,
                    vertical: Dimensions.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(Dimensions.radiusXxLarge),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 18),
                      const SizedBox(width: Dimensions.spacing8),
                      Text(
                        scannerState.autoCaptureEnabled
                            ? 'Auto-capturing in ${scannerState.autoCaptureCountdown}s'
                            : 'Document detected',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 250.ms)
                .slideY(begin: -0.2, end: 0),

          // ── Bottom Controls ─────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              padding: EdgeInsets.only(
                left: Dimensions.paddingMedium,
                right: Dimensions.paddingMedium,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toolbar row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ToolbarButton(
                        icon: Icons.layers_outlined,
                        label: 'Batch',
                        isActive: ref.watch(batchScanProvider).pageCount > 0,
                        onTap: () => context.push('/scanner/batch'),
                      ),
                      const SizedBox(width: 48), // space for capture
                      _ToolbarButton(
                        icon: scannerState.autoCaptureEnabled
                            ? Icons.center_focus_strong
                            : Icons.center_focus_weak_outlined,
                        label: 'Auto',
                        isActive: scannerState.autoCaptureEnabled,
                        onTap: () => ref
                            .read(scannerStateProvider.notifier)
                            .toggleAutoCapture(),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.spacing20),
                  // Capture button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CaptureButton(
                        onTap: _onCapture,
                        isProcessing: captureState.isCapturing,
                        autoCaptureCountdown:
                            scannerState.autoCaptureCountdown,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Processing overlay ──────────────────────────────
          if (captureState.isCapturing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(ScannerState scannerState) {
    if (!scannerState.isCameraReady) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder camera preview area
            Container(
              color: const Color(0xFF1A1A1A),
              child: const Center(
                child: Icon(
                  Icons.document_scanner,
                  size: 64,
                  color: Colors.white24,
                ),
              ),
            ),
            // Edge overlay
            AnimatedBuilder(
              animation: _edgeAnimController,
              builder: (context, _) {
                return CustomPaint(
                  painter: EdgeOverlayPainter(
                    edges: scannerState.detectedEdges,
                    isDetected: scannerState.documentDetected,
                    animationValue: _edgeAnimController.value,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _onCapture() {
    ref.read(captureProvider.notifier).captureImage(
          'captured_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
    // Navigate to crop screen after capture
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) context.push('/scanner/crop');
    });
  }

  void _onGalleryImport() {
    // Placeholder: would invoke image_picker via ImportFromGallery use case
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery import coming soon')),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper Widgets
// ---------------------------------------------------------------------------

class _FlashToggle extends StatelessWidget {
  final FlashMode flashMode;
  final VoidCallback onToggle;

  const _FlashToggle({required this.flashMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final icon = switch (flashMode) {
      FlashMode.off => Icons.flash_off,
      FlashMode.on => Icons.flash_on,
      FlashMode.auto => Icons.flash_auto,
    };
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onToggle,
      tooltip: 'Flash: ${flashMode.name}',
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.spacing12,
          vertical: Dimensions.spacing8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.scannerAccent : Colors.white70, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.scannerAccent : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
