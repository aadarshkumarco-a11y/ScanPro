/// Document enhancement screen with filter selection and adjustments.
///
/// Shows the enhanced image preview, filter cards (Original, Auto, B&W,
/// Magic Color, Grayscale), brightness/contrast/sharpness sliders,
/// before/after comparison toggle, and save actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:scanpro/features/scanner/presentation/widgets/enhancement_slider.dart';
import 'package:scanpro/features/scanner/presentation/widgets/filter_option_card.dart';

/// Screen for applying enhancement filters and adjustments to the scanned image.
class EnhanceScreen extends ConsumerWidget {
  const EnhanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enhanceState = ref.watch(enhancementProvider);
    final batchState = ref.watch(batchScanProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Enhance'),
        actions: [
          TextButton(
            onPressed: () => ref.read(enhancementProvider.notifier).reset(),
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Image Preview ──────────────────────────────────
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _EnhancePreview(
                  showComparison: enhanceState.showComparison,
                  filterType: enhanceState.selectedFilter,
                ),
                // Before/After toggle
                Positioned(
                  top: Dimensions.spacing12,
                  right: Dimensions.spacing12,
                  child: _ComparisonToggle(
                    isOn: enhanceState.showComparison,
                    onToggle: () => ref
                        .read(enhancementProvider.notifier)
                        .toggleComparison(),
                  ),
                ),
                // Loading overlay
                if (enhanceState.isEnhancing)
                  Container(
                    color: Colors.black38,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: Dimensions.spacing12),
                          Text(
                            'Applying enhancement...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Filter Selector ────────────────────────────────
          Container(
            color: colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.spacing12,
            ),
            child: SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingMedium,
                ),
                itemCount: FilterType.values.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: Dimensions.spacing12),
                itemBuilder: (context, index) {
                  final filter = FilterType.values[index];
                  return FilterOptionCard(
                    filter: filter,
                    isSelected: enhanceState.selectedFilter == filter,
                    onTap: () {
                      ref.read(enhancementProvider.notifier).selectFilter(filter);
                      ref.read(enhancementProvider.notifier).applyEnhancement(
                            'enhanced_${DateTime.now().millisecondsSinceEpoch}.jpg',
                          );
                    },
                  );
                },
              ),
            ),
          ),

          // ── Adjustment Sliders ─────────────────────────────
          Container(
            color: colorScheme.surfaceContainerLow,
            child: Column(
              children: [
                EnhancementSlider(
                  label: 'Brightness',
                  icon: Icons.brightness_6_outlined,
                  value: enhanceState.brightness,
                  onChanged: (v) =>
                      ref.read(enhancementProvider.notifier).setBrightness(v),
                ),
                EnhancementSlider(
                  label: 'Contrast',
                  icon: Icons.contrast,
                  value: enhanceState.contrast,
                  onChanged: (v) =>
                      ref.read(enhancementProvider.notifier).setContrast(v),
                ),
                EnhancementSlider(
                  label: 'Sharpness',
                  icon: Icons.deblur,
                  value: enhanceState.sharpness,
                  onChanged: (v) =>
                      ref.read(enhancementProvider.notifier).setSharpness(v),
                ),
              ],
            ),
          ),

          // ── Action Buttons ─────────────────────────────────
          Container(
            color: colorScheme.surface,
            padding: EdgeInsets.only(
              left: Dimensions.paddingMedium,
              right: Dimensions.paddingMedium,
              top: Dimensions.spacing12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Row(
              children: [
                // Add more pages
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(batchScanProvider.notifier).addPage(
                          enhanceState.enhancedImagePath ?? 'page.jpg',
                        );
                    context.go('/scanner');
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Page'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.spacing12,
                      vertical: Dimensions.spacing8,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.spacing12),
                // Save / Create PDF
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ref.read(batchScanProvider.notifier).addPage(
                            enhanceState.enhancedImagePath ?? 'page.jpg',
                          );
                      if (batchState.pageCount > 1) {
                        context.go('/scanner/batch');
                      } else {
                        // Save single-page document
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Document saved successfully'),
                          ),
                        );
                        context.go('/documents');
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.scannerAccent,
                    ),
                    child: const Text('Save Document'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preview Area
// ---------------------------------------------------------------------------

class _EnhancePreview extends StatelessWidget {
  final bool showComparison;
  final FilterType filterType;

  const _EnhancePreview({
    required this.showComparison,
    required this.filterType,
  });

  @override
  Widget build(BuildContext context) {
    if (showComparison) {
      return Row(
        children: [
          Expanded(
            child: _PreviewBox(
              label: 'Before',
              filterType: FilterType.original,
            ),
          ),
          Container(width: 2, color: Colors.white24),
          Expanded(
            child: _PreviewBox(
              label: 'After',
              filterType: filterType,
            ),
          ),
        ],
      );
    }
    return _PreviewBox(filterType: filterType);
  }
}

class _PreviewBox extends StatelessWidget {
  final String? label;
  final FilterType filterType;

  const _PreviewBox({this.label, required this.filterType});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: const Color(0xFF1E1E1E),
          child: Center(
            child: Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.white24,
            ),
          ),
        ),
        if (filterType == FilterType.grayscale)
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.grey,
              BlendMode.saturation,
            ),
            child: const SizedBox.expand(),
          ),
        if (filterType == FilterType.bw)
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.black,
              BlendMode.saturation,
            ),
            child: const SizedBox.expand(),
          ),
        if (label != null)
          Positioned(
            bottom: Dimensions.spacing8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.spacing12,
                  vertical: Dimensions.spacing4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Comparison Toggle
// ---------------------------------------------------------------------------

class _ComparisonToggle extends StatelessWidget {
  final bool isOn;
  final VoidCallback onToggle;

  const _ComparisonToggle({required this.isOn, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(Dimensions.radiusXxLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusXxLarge),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.spacing12,
            vertical: Dimensions.spacing6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.compare,
                size: 16,
                color: isOn ? Colors.white : Colors.white54,
              ),
              const SizedBox(width: 4),
              Text(
                'Before / After',
                style: TextStyle(
                  color: isOn ? Colors.white : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
