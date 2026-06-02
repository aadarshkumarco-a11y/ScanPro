import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart' as core_theme;
import '../../domain/entities/scanned_document.dart';
import '../providers/scanner_provider.dart';
import '../widgets/crop_overlay.dart' hide AppTheme;
import '../widgets/filter_selector.dart' hide AppTheme;

/// Scan result screen showing the captured image with crop handles,
/// rotate/flip buttons, filter options, and save/discard buttons.
class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({super.key});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  /// Available filter options displayed in the selector.
  static const _filterOptions = [
    FilterOption(name: 'original', label: 'Original', icon: Icons.image_rounded),
    FilterOption(name: 'grayscale', label: 'Grayscale', icon: Icons.filter_b_and_w_rounded),
    FilterOption(name: 'bw', label: 'B&W', icon: Icons.contrast_rounded),
    FilterOption(name: 'magic_color', label: 'Magic Color', icon: Icons.auto_fix_high_rounded),
    FilterOption(name: 'brightened', label: 'Brightened', icon: Icons.brightness_6_rounded),
  ];

  bool _isCropMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scannerState = ref.watch(scannerProvider);
    final scannerNotifier = ref.read(scannerProvider.notifier);
    final document = scannerState.currentDocument;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isCropMode ? 'Adjust Crop' : 'Scan Result',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          if (!_isCropMode)
            IconButton(
              onPressed: () {
                setState(() => _isCropMode = true);
              },
              icon: const Icon(Icons.crop_rounded),
              tooltip: 'Crop',
            ),
          if (_isCropMode)
            TextButton(
              onPressed: () {
                setState(() => _isCropMode = false);
              },
              child: Text(
                'Done',
                style: TextStyle(color: core_theme.AppTheme.primaryColor),
              ),
            ),
        ],
      ),
      body: document == null
          ? _buildNoDocumentState(context, colorScheme)
          : Column(
              children: [
                // ── Image Preview ────────────────────────────────────
                Expanded(
                  flex: 3,
                  child: _buildImagePreview(document, colorScheme),
                ),

                // ── Editing Tools ────────────────────────────────────
                if (!_isCropMode) ...[
                  // Rotate / Flip controls
                  _buildEditTools(context, colorScheme, scannerNotifier, document),

                  // Filter selector
                  FilterSelector(
                    options: _filterOptions,
                    selectedFilter: scannerState.selectedFilter,
                    onFilterSelected: (filterName) {
                      scannerNotifier.applyFilter(
                        filePath: document.filePath,
                        filterName: filterName,
                      );
                    },
                  ),
                ] else ...[
                  // Crop instructions
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Drag corners to adjust crop area',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],

                // ── Action Buttons ───────────────────────────────────
                _buildActionButtons(context, colorScheme, scannerNotifier),

                const SizedBox(height: 16),
              ],
            ),
    );
  }

  /// Builds the placeholder when no document is available.
  Widget _buildNoDocumentState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No scan captured',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.scanner),
            icon: const Icon(Icons.document_scanner_rounded, size: 20),
            label: const Text('Scan Now'),
          ),
        ],
      ),
    );
  }

  /// Builds the image preview area with optional crop overlay.
  Widget _buildImagePreview(ScannedDocument document, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image display
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: document.filePath.isNotEmpty
                ? Image.file(
                    File(document.filePath),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(colorScheme),
                  )
                : _buildImagePlaceholder(colorScheme),
          ),

          // Crop overlay
          if (_isCropMode)
            CropOverlay(
              onCropApplied: (cropArea) {
                ref.read(scannerProvider.notifier).cropImage(
                      filePath: document.filePath,
                      cropArea: cropArea,
                    );
              },
            ),
        ],
      ),
    );
  }

  /// Builds a placeholder for when the image cannot be loaded.
  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 8),
          Text(
            'Scanned Image',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the edit tools row (rotate, flip).
  Widget _buildEditTools(
    BuildContext context,
    ColorScheme colorScheme,
    ScannerNotifier scannerNotifier,
    ScannedDocument document,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToolButton(
            icon: Icons.rotate_left_rounded,
            label: 'Rotate Left',
            onTap: () => scannerNotifier.rotateImage(
              filePath: document.filePath,
              degrees: 270,
            ),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 16),
          _buildToolButton(
            icon: Icons.rotate_right_rounded,
            label: 'Rotate Right',
            onTap: () => scannerNotifier.rotateImage(
              filePath: document.filePath,
              degrees: 90,
            ),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 16),
          _buildToolButton(
            icon: Icons.flip_rounded,
            label: 'Flip',
            onTap: () => scannerNotifier.rotateImage(
              filePath: document.filePath,
              degrees: 180,
            ),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 16),
          _buildToolButton(
            icon: Icons.auto_fix_high_rounded,
            label: 'Enhance',
            onTap: () => scannerNotifier.enhanceImage(
              filePath: document.filePath,
            ),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  /// Builds a single tool button.
  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: core_theme.AppTheme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: core_theme.AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: core_theme.AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Save / Discard action buttons.
  Widget _buildActionButtons(
    BuildContext context,
    ColorScheme colorScheme,
    ScannerNotifier scannerNotifier,
  ) {
    final isProcessing =
        ref.watch(scannerProvider).status == ScannerStatus.processing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Discard button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isProcessing
                  ? null
                  : () {
                      scannerNotifier.discardScan();
                      context.go(AppRoutes.scanner);
                    },
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              label: const Text('Discard'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Save button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isProcessing
                  ? null
                  : () async {
                      await scannerNotifier.saveDocument();
                      if (mounted) {
                        context.go(AppRoutes.documents);
                      }
                    },
              icon: isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 20),
              label: Text(isProcessing ? 'Saving…' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}
