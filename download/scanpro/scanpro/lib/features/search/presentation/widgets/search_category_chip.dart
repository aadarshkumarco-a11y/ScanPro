import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/search/presentation/providers/search_provider.dart';

class SearchCategoryChip extends StatelessWidget {
  final SearchCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const SearchCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, label, color) = _categoryMetadata();

    return FilterChip(
      selected: isSelected,
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : color),
      label: Text(label),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected ? Colors.white : color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      selectedColor: const Color(0xFF4D2DAB),
      backgroundColor: color.withOpacity(0.08),
      side: BorderSide(
        color: isSelected ? const Color(0xFF4D2DAB) : color.withOpacity(0.3),
        width: isSelected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      showCheckmark: false,
    ).animate(target: isSelected ? 1.0 : 0.0).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 150.ms,
        );
  }

  (IconData, String, Color) _categoryMetadata() {
    switch (category) {
      case SearchCategory.files:
        return (Icons.insert_drive_file_outlined, 'Files', Colors.red);
      case SearchCategory.ocrContent:
        return (Icons.text_fields, 'OCR Content', Colors.teal);
      case SearchCategory.tags:
        return (Icons.label_outline, 'Tags', Colors.orange);
      case SearchCategory.folders:
        return (Icons.folder_outlined, 'Folders', Colors.amber.shade800);
    }
  }
}
