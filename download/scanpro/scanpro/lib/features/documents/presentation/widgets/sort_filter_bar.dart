/// Sort dropdown and filter chips row for the documents screen.
///
/// Provides a compact bar with a sort dropdown on the left and
/// horizontally scrollable filter chips on the right.
library;

import 'package:flutter/material.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/features/documents/presentation/providers/documents_provider.dart';

/// Horizontal bar with sort dropdown and filter chips.
///
/// [sortFilter] is the current sort/filter state.
/// [onSortChanged] fires when the sort field changes.
/// [onSortDirectionToggled] fires when sort direction is toggled.
/// [onFilterChanged] fires when a filter chip is selected.
class SortFilterBar extends StatelessWidget {
  final SortFilterState sortFilter;
  final ValueChanged<DocumentSortField> onSortChanged;
  final VoidCallback onSortDirectionToggled;
  final ValueChanged<DocumentFilter> onFilterChanged;

  const SortFilterBar({
    super.key,
    required this.sortFilter,
    required this.onSortChanged,
    required this.onSortDirectionToggled,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.spacing8,
      ),
      child: Column(
        children: [
          // Sort row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingMedium,
            ),
            child: Row(
              children: [
                Text(
                  'Sort by',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: Dimensions.spacing8),
                _SortDropdown(
                  currentField: sortFilter.sortField,
                  onChanged: onSortChanged,
                ),
                const SizedBox(width: Dimensions.spacing4),
                IconButton(
                  icon: Icon(
                    sortFilter.sortAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: Dimensions.iconSmall + 2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onSortDirectionToggled,
                  tooltip: sortFilter.sortAscending
                      ? 'Sort ascending'
                      : 'Sort descending',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // Filter chips
          SizedBox(
            height: Dimensions.chipHeight + Dimensions.spacing8,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingMedium,
              ),
              itemCount: DocumentFilter.values.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: Dimensions.spacing8),
              itemBuilder: (context, index) {
                final filter = DocumentFilter.values[index];
                final isActive = sortFilter.activeFilter == filter;
                return FilterChip(
                  label: Text(_filterLabel(filter)),
                  selected: isActive,
                  onSelected: (_) => onFilterChanged(filter),
                  selectedColor: AppColors.scannerAccent.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.scannerAccent,
                  labelStyle: TextStyle(
                    color: isActive
                        ? AppColors.scannerAccent
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 12,
                  ),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(DocumentFilter filter) => switch (filter) {
        DocumentFilter.all => 'All',
        DocumentFilter.pdf => 'PDFs',
        DocumentFilter.image => 'Images',
        DocumentFilter.ocr => 'OCR',
        DocumentFilter.favorites => 'Favorites',
      };
}

// ---------------------------------------------------------------------------
// Sort Dropdown
// ---------------------------------------------------------------------------

class _SortDropdown extends StatelessWidget {
  final DocumentSortField currentField;
  final ValueChanged<DocumentSortField> onChanged;

  const _SortDropdown({required this.currentField, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.spacing12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DocumentSortField>(
          value: currentField,
          items: DocumentSortField.values
              .map((field) => DropdownMenuItem(
                    value: field,
                    child: Text(
                      _fieldLabel(field),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          iconSize: 18,
          isDense: true,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
      ),
    );
  }

  String _fieldLabel(DocumentSortField field) => switch (field) {
        DocumentSortField.name => 'Name',
        DocumentSortField.date => 'Date',
        DocumentSortField.size => 'Size',
        DocumentSortField.category => 'Category',
      };
}
