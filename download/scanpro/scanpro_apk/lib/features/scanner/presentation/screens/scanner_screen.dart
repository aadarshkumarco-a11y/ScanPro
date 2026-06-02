import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scanner_controls.dart';

/// Camera scanner screen with live viewfinder, capture button,
/// flash toggle, batch mode indicator, and gallery import option.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    // Reset scanner state when entering the screen.
    Future.microtask(() => ref.read(scannerProvider.notifier).reset());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scannerState = ref.watch(scannerProvider);
    final scannerNotifier = ref.read(scannerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Scan Document',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (scannerState.isBatchMode)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.collections_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${scannerState.batchPageCount}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera Preview / Viewfinder ────────────────────────────
          _buildCameraPreview(context, colorScheme, scannerState),

          // ── Scanning Overlay Frame ─────────────────────────────────
          _buildScanOverlay(context, colorScheme),

          // ── Document Detection Indicator ───────────────────────────
          if (scannerState.status == ScannerStatus.scanning ||
              scannerState.status == ScannerStatus.processing)
            _buildScanningIndicator(context, colorScheme),

          // ── Bottom Controls ────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ScannerControls(
              onCapture: _onCapture,
              onFlashToggle: () => scannerNotifier.toggleFlash(),
              onGalleryImport: _onGalleryImport,
              onBatchToggle: () => scannerNotifier.toggleBatchMode(),
              isFlashOn: scannerState.isFlashOn,
              isBatchMode: scannerState.isBatchMode,
              batchPageCount: scannerState.batchPageCount,
            ),
          ),

          // ── Error Message ──────────────────────────────────────────
          if (scannerState.status == ScannerStatus.error &&
              scannerState.errorMessage != null)
            _buildErrorBanner(context, colorScheme, scannerState.errorMessage!),
        ],
      ),
    );
  }

  /// Builds the camera preview area with prompt to capture or pick image.
  Widget _buildCameraPreview(
    BuildContext context,
    ColorScheme colorScheme,
    ScannerState scannerState,
  ) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.document_scanner_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap capture to scan with camera',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Or tap gallery to import from photos',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the viewfinder overlay rectangle.
  Widget _buildScanOverlay(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.7),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Top-left corner
            Positioned(
              top: -1,
              left: -1,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: AppTheme.primaryColor, width: 4),
                    left: BorderSide(
                        color: AppTheme.primaryColor, width: 4),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            // Top-right corner
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: AppTheme.primaryColor, width: 4),
                    right: BorderSide(
                        color: AppTheme.primaryColor, width: 4),
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
            // Bottom-left corner
            Positioned(
              bottom: -1,
              left: -1,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: AppTheme.primaryColor, width: 4),
                    left: BorderSide(
                        color: AppTheme.primaryColor, width: 4),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            // Bottom-right corner
            Positioned(
              bottom: -1,
              right: -1,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: AppTheme.primaryColor, width: 4),
                    right: BorderSide(
                        color: AppTheme.primaryColor, width: 4),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the scanning/processing indicator.
  Widget _buildScanningIndicator(BuildContext context, ColorScheme colorScheme) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.15,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Processing document\u2026',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an error banner at the top of the screen.
  Widget _buildErrorBanner(
    BuildContext context,
    ColorScheme colorScheme,
    String message,
  ) {
    return Positioned(
      top: kToolbarHeight + 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            IconButton(
              onPressed: () =>
                  ref.read(scannerProvider.notifier).reset(),
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles the capture button press - opens camera.
  Future<void> _onCapture() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final notifier = ref.read(scannerProvider.notifier);

        if (ref.read(scannerProvider).isBatchMode) {
          await notifier.batchScan(pageCount: ref.read(scannerProvider).batchPageCount);
        } else {
          await notifier.scanWithFile(image.path);
        }

        final newState = ref.read(scannerProvider);
        if (newState.status == ScannerStatus.success &&
            newState.currentDocument != null) {
          if (mounted) {
            context.go(AppRoutes.scannerResult);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: ${e.toString()}')),
        );
      }
    } finally {
      _isPicking = false;
    }
  }

  /// Handles gallery import button press - opens gallery.
  Future<void> _onGalleryImport() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final notifier = ref.read(scannerProvider.notifier);
        await notifier.scanWithFile(image.path);

        final newState = ref.read(scannerProvider);
        if (newState.status == ScannerStatus.success &&
            newState.currentDocument != null) {
          if (mounted) {
            context.go(AppRoutes.scannerResult);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery error: ${e.toString()}')),
        );
      }
    } finally {
      _isPicking = false;
    }
  }
}

/// Convenience accessor for the primary colour constant.
class AppTheme {
  static const Color primaryColor = Color(0xFF4D2DAB);
}
