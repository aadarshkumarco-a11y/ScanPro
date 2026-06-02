import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Camera controls overlay widget displayed at the bottom of the
/// scanner screen. Provides capture, flash toggle, gallery import,
/// and batch mode controls.
class ScannerControls extends StatelessWidget {
  const ScannerControls({
    super.key,
    required this.onCapture,
    required this.onFlashToggle,
    required this.onGalleryImport,
    required this.onBatchToggle,
    required this.isFlashOn,
    required this.isBatchMode,
    required this.batchPageCount,
  });

  /// Callback when the capture button is pressed.
  final VoidCallback onCapture;

  /// Callback when the flash toggle button is pressed.
  final VoidCallback onFlashToggle;

  /// Callback when the gallery import button is pressed.
  final VoidCallback onGalleryImport;

  /// Callback when the batch mode toggle button is pressed.
  final VoidCallback onBatchToggle;

  /// Whether the flash is currently on.
  final bool isFlashOn;

  /// Whether batch mode is currently active.
  final bool isBatchMode;

  /// Number of pages scanned in the current batch.
  final int batchPageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top hint text ──────────────────────────────────────────
          Text(
            isBatchMode
                ? 'Batch mode · $batchPageCount page(s) captured'
                : 'Tap capture to scan',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),

          // ── Controls row ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gallery import
              _ControlButton(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: onGalleryImport,
              ),

              // Capture button (larger, prominent)
              _CaptureButton(
                onTap: onCapture,
                isBatchMode: isBatchMode,
              ),

              // Flash toggle
              _ControlButton(
                icon: isFlashOn
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                label: 'Flash',
                onTap: onFlashToggle,
                isActive: isFlashOn,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Batch mode toggle ──────────────────────────────────────
          GestureDetector(
            onTap: onBatchToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isBatchMode
                    ? AppTheme.primaryColor
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.collections_rounded,
                    size: 18,
                    color: isBatchMode ? Colors.white : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isBatchMode ? 'Batch ON' : 'Batch Mode',
                    style: TextStyle(
                      color: isBatchMode ? Colors.white : Colors.white70,
                      fontSize: 13,
                      fontWeight: isBatchMode
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A secondary control button (gallery, flash, etc.).
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryColor.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white70,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// The primary capture button with a distinctive ring design.
class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.onTap,
    required this.isBatchMode,
  });

  final VoidCallback onTap;
  final bool isBatchMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isBatchMode
                ? AppTheme.secondaryColor
                : AppTheme.primaryColor,
          ),
          child: isBatchMode
              ? const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                )
              : const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 28,
                ),
        ),
      ),
    );
  }
}

/// Convenience accessor for the secondary colour constant.
class AppTheme {
  static const Color primaryColor = Color(0xFF4D2DAB);
  static const Color secondaryColor = Color(0xFF00BFA6);
}
