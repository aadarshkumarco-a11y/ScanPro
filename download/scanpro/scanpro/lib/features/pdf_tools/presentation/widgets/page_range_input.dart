import 'package:flutter/material.dart';

class PageRangeInput extends StatelessWidget {
  final TextEditingController controller;
  final int maxPages;
  final VoidCallback onSubmitted;
  final String? errorText;

  const PageRangeInput({
    super.key,
    required this.controller,
    required this.maxPages,
    required this.onSubmitted,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Page Range',
          style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmitted(),
                decoration: InputDecoration(
                  hintText: '1-3, 5, 7-9',
                  hintStyle: TextStyle(color: theme.colorScheme.outline),
                  errorText: errorText,
                  prefixIcon: const Icon(Icons.format_list_numbered, size: 20),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          controller.text = '1-$maxPages';
                          onSubmitted();
                        },
                        icon: const Icon(Icons.select_all, size: 18),
                        tooltip: 'Select all pages',
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF4D2DAB), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onSubmitted,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Total pages: $maxPages • Use commas to separate ranges',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }

  /// Parses a page range string like "1-3, 5, 7-9" into a list of page numbers.
  static List<int> parseRanges(String input, int maxPages) {
    final pages = <int>[];
    try {
      for (final part in input.split(',')) {
        final trimmed = part.trim();
        if (trimmed.isEmpty) continue;
        if (trimmed.contains('-')) {
          final bounds = trimmed.split('-');
          final start = int.parse(bounds[0].trim());
          final end = int.parse(bounds[1].trim());
          for (int i = start; i <= end && i <= maxPages; i++) {
            if (i > 0 && !pages.contains(i)) pages.add(i);
          }
        } else {
          final page = int.parse(trimmed);
          if (page > 0 && page <= maxPages && !pages.contains(page)) pages.add(page);
        }
      }
    } catch (_) {
      return [];
    }
    pages.sort();
    return pages;
  }

  /// Validates a page range string.
  static String? validate(String input, int maxPages) {
    if (input.trim().isEmpty) return 'Please enter a page range';
    final pages = parseRanges(input, maxPages);
    if (pages.isEmpty) return 'Invalid page range';
    if (pages.any((p) => p < 1 || p > maxPages)) return 'Pages must be between 1 and $maxPages';
    return null;
  }
}
