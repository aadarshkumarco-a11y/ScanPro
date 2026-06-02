import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Page range selector widget for the PDF split feature.
///
/// Provides a text input for entering page ranges and displays
/// the list of added ranges with remove buttons.
class PageRangeSelector extends StatefulWidget {
  const PageRangeSelector({
    super.key,
    required this.pageRanges,
    required this.onAddRange,
    required this.onRemoveRange,
  });

  /// Current list of page range strings.
  final List<String> pageRanges;

  /// Callback when a new range is added.
  final ValueChanged<String> onAddRange;

  /// Callback when a range at [index] is removed.
  final ValueChanged<int> onRemoveRange;

  @override
  State<PageRangeSelector> createState() => _PageRangeSelectorState();
}

class _PageRangeSelectorState extends State<PageRangeSelector> {
  final _rangeController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _rangeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Validates and adds a page range.
  void _addRange() {
    final text = _rangeController.text.trim();
    if (text.isEmpty) return;

    // Basic validation: must match patterns like '1', '1-3', '5-10'
    final singlePage = RegExp(r'^\d+$');
    final pageRange = RegExp(r'^\d+-\d+$');

    if (!singlePage.hasMatch(text) && !pageRange.hasMatch(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid format. Use: 1, 1-3, 5-10'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Additional validation for range: start <= end
    if (pageRange.hasMatch(text)) {
      final parts = text.split('-');
      final start = int.parse(parts[0]);
      final end = int.parse(parts[1]);
      if (start > end) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Start page must be less than or equal to end page.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      if (start < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Page numbers must be 1 or greater.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    widget.onAddRange(text);
    _rangeController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Input Row ──────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _rangeController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: 'Page Range',
                  hintText: 'e.g. 1-3 or 5',
                  prefixIcon: const Icon(Icons.filter_1_rounded, size: 18),
                  suffixIcon: IconButton(
                    onPressed: _addRange,
                    icon: Icon(
                      Icons.add_circle_rounded,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addRange(),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _addRange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),

        // ── Quick Add Chips ────────────────────────────────────────────
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _QuickRangeChip(
              label: '1-1',
              onTap: () => widget.onAddRange('1-1'),
            ),
            _QuickRangeChip(
              label: '1-3',
              onTap: () => widget.onAddRange('1-3'),
            ),
            _QuickRangeChip(
              label: 'Odd pages',
              onTap: () {
                // Add multiple single-page ranges for odd pages
                widget.onAddRange('1-1');
                widget.onAddRange('3-3');
                widget.onAddRange('5-5');
                widget.onAddRange('7-7');
              },
            ),
          ],
        ),

        // ── Added Ranges List ──────────────────────────────────────────
        if (widget.pageRanges.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: widget.pageRanges.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final range = widget.pageRanges[index];
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    'Pages: $range',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    _getPageCountDescription(range),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => widget.onRemoveRange(index),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.error.withValues(alpha: 0.6),
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// Returns a description of the page count for a range string.
  String _getPageCountDescription(String range) {
    if (range.contains('-')) {
      final parts = range.split('-');
      final start = int.tryParse(parts[0].trim()) ?? 1;
      final end = int.tryParse(parts[1].trim()) ?? 1;
      final count = end - start + 1;
      return '$count page${count != 1 ? 's' : ''}';
    }
    return '1 page';
  }
}

/// Quick-add chip for common page ranges.
class _QuickRangeChip extends StatelessWidget {
  const _QuickRangeChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: AppTheme.primaryColor,
      ),
      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.08),
      side: BorderSide(
        color: AppTheme.primaryColor.withValues(alpha: 0.2),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
