import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Describes a single filter option displayed in the selector.
class FilterOption {
  const FilterOption({
    required this.name,
    required this.label,
    required this.icon,
  });

  /// Machine-readable filter name (passed to the use case).
  final String name;

  /// Human-readable label shown under the chip.
  final String label;

  /// Icon representing the filter.
  final IconData icon;
}

/// A horizontal scrollable filter selector chip bar.
///
/// Displays a list of [FilterOption]s as selectable chips.
/// The currently selected filter is highlighted with the primary colour.
class FilterSelector extends StatelessWidget {
  const FilterSelector({
    super.key,
    required this.options,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  /// The list of filter options to display.
  final List<FilterOption> options;

  /// The name of the currently selected filter.
  final String selectedFilter;

  /// Callback when a filter is selected.
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.name == selectedFilter;

          return _FilterChip(
            option: option,
            isSelected: isSelected,
            colorScheme: colorScheme,
            theme: theme,
            onTap: () => onFilterSelected(option.name),
          );
        },
      ),
    );
  }
}

/// A single filter chip widget.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.option,
    required this.isSelected,
    required this.colorScheme,
    required this.theme,
    required this.onTap,
  });

  final FilterOption option;
  final bool isSelected;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppTheme.primaryColor
                  : colorScheme.onSurface.withValues(alpha: 0.06),
              border: isSelected
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null,
            ),
            child: Icon(
              option.icon,
              size: 22,
              color: isSelected
                  ? Colors.white
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),

          // Label
          Text(
            option.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? AppTheme.primaryColor
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Convenience accessor for the primary colour constant.
class AppTheme {
  static const Color primaryColor = Color(0xFF4D2DAB);
}
