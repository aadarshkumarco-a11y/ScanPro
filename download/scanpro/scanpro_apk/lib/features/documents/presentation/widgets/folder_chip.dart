import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/document_folder.dart';

/// A compact chip widget representing a document folder.
///
/// Displays the folder name with an optional document count badge
/// and a coloured indicator. Supports selection state for filtering.
class FolderChip extends StatelessWidget {
  const FolderChip({
    super.key,
    required this.folder,
    required this.isSelected,
    required this.onTap,
  });

  /// The folder to display.
  final DocumentFolder folder;

  /// Whether this chip is currently selected (active filter).
  final bool isSelected;

  /// Callback when the chip is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Parse folder colour, defaulting to primary.
    final folderColor = _parseColor(folder.color) ?? AppTheme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? folderColor.withValues(alpha: 0.12)
              : colorScheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: folderColor, width: 1.5)
              : Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Folder icon with colour indicator
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected
                    ? folderColor.withValues(alpha: 0.2)
                    : folderColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                _parseIcon(folder.icon),
                size: 12,
                color: folderColor,
              ),
            ),
            const SizedBox(width: 6),

            // Folder name
            Text(
              folder.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? folderColor : colorScheme.onSurface,
              ),
            ),

            // Document count badge
            if (folder.documentCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? folderColor.withValues(alpha: 0.15)
                      : colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${folder.documentCount}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? folderColor
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Parses a hex colour string, returning null on failure.
  Color? _parseColor(String? hexColor) {
    if (hexColor == null) return null;
    try {
      final hex = hexColor.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Parses an icon name string, returning a default folder icon.
  IconData _parseIcon(String? iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work_rounded;
      case 'receipt':
        return Icons.receipt_long_rounded;
      case 'medical':
        return Icons.medical_services_rounded;
      case 'travel':
        return Icons.flight_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'finance':
        return Icons.account_balance_rounded;
      default:
        return Icons.folder_rounded;
    }
  }
}

/// Convenience accessor for the primary colour constant.
class AppTheme {
  static const Color primaryColor = Color(0xFF4D2DAB);
}
