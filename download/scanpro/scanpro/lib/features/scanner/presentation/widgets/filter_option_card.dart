/// Filter selection card used in the enhance screen.
///
/// Displays a small preview thumbnail, filter name, and a selected
/// indicator ring. Tapping the card selects the filter.
library;

import 'package:flutter/material.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/features/scanner/presentation/providers/scanner_provider.dart';

/// A single filter option shown in the horizontal filter list.
///
/// [filter] identifies which filter this card represents.
/// [isSelected] highlights the card with the primary ring.
/// [onTap] fires when the user selects this filter.
/// [thumbnailProvider] optional image provider for the preview.
class FilterOptionCard extends StatelessWidget {
  final FilterType filter;
  final bool isSelected;
  final VoidCallback onTap;
  final ImageProvider? thumbnailProvider;

  const FilterOptionCard({
    super.key,
    required this.filter,
    required this.isSelected,
    required this.onTap,
    this.thumbnailProvider,
  });

  String get _label => switch (filter) {
        FilterType.original => 'Original',
        FilterType.auto => 'Auto',
        FilterType.bw => 'B&W',
        FilterType.magicColor => 'Magic',
        FilterType.grayscale => 'Grayscale',
      };

  IconData get _icon => switch (filter) {
        FilterType.original => Icons.image_outlined,
        FilterType.auto => Icons.auto_fix_high,
        FilterType.bw => Icons.contrast,
        FilterType.magicColor => Icons.auto_awesome,
        FilterType.grayscale => Icons.gradient,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Dimensions.animationDuration,
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              border: Border.all(
                color: isSelected
                    ? AppColors.scannerAccent
                    : colorScheme.outlineVariant,
                width: isSelected ? 3.0 : 1.5,
              ),
              color: colorScheme.surfaceContainerHighest,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium - 1),
              child: thumbnailProvider != null
                  ? Image(
                      image: thumbnailProvider!,
                      fit: BoxFit.cover,
                      color: filter == FilterType.grayscale
                          ? Colors.grey
                          : null,
                      colorBlendMode: filter == FilterType.grayscale
                          ? BlendMode.saturation
                          : null,
                    )
                  : Center(
                      child: Icon(
                        _icon,
                        color: isSelected
                            ? AppColors.scannerAccent
                            : colorScheme.onSurfaceVariant,
                        size: Dimensions.iconLarge,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: Dimensions.spacing6),
          Text(
            _label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? AppColors.scannerAccent
                      : colorScheme.onSurfaceVariant,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}
