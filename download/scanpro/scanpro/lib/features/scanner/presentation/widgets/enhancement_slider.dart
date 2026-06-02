/// Custom slider for brightness, contrast, and sharpness adjustments.
///
/// Displays a labelled slider with an icon, value indicator, and
/// a reset-to-default button. Styled to match the indigo theme.
library;

import 'package:flutter/material.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';

/// A styled adjustment slider for the enhance screen.
///
/// [label] is the property name shown above the slider.
/// [icon] provides a visual cue for the property type.
/// [value] is the current slider position (0–100).
/// [defaultValue] is the centre/reset value.
/// [onChanged] fires continuously as the slider moves.
/// [onChangeEnd] fires when the user releases the slider.
class EnhancementSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double defaultValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  const EnhancementSlider({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    this.defaultValue = 50.0,
    required this.onChanged,
    this.onChangeEnd,
  });

  bool get _isModified => (value - defaultValue).abs() > 0.5;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingMedium,
        vertical: Dimensions.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: Dimensions.iconSmall, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: Dimensions.spacing8),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_isModified)
                InkWell(
                  onTap: () => onChanged(defaultValue),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.spacing4),
                    child: Icon(
                      Icons.refresh,
                      size: Dimensions.iconSmall + 2,
                      color: AppColors.scannerAccent,
                    ),
                  ),
                ),
              SizedBox(
                width: 40,
                child: Text(
                  value.round().toString(),
                  textAlign: TextAlign.end,
                  style: textTheme.labelSmall?.copyWith(
                    color: _isModified
                        ? AppColors.scannerAccent
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.scannerAccent,
              inactiveTrackColor: colorScheme.surfaceContainerHighest,
              thumbColor: AppColors.scannerAccent,
              overlayColor: AppColors.scannerAccent.withValues(alpha: 0.12),
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value.clamp(0.0, 100.0),
              min: 0,
              max: 100,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ],
      ),
    );
  }
}
