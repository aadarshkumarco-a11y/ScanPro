/// Folder card with color, icon, name, and document count.
///
/// Used in both grid and list layouts of the documents screen.
library;

import 'package:flutter/material.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/features/documents/domain/entities/folder.dart';

/// A card displaying folder summary information.
///
/// [folder] is the source folder entity.
/// [onTap] fires when the card is tapped.
class FolderCard extends StatelessWidget {
  final Folder folder;
  final VoidCallback? onTap;

  const FolderCard({super.key, required this.folder, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final folderColor = _parseColor(folder.color);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingCard),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Folder icon with color
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: folderColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _folderIcon,
                  size: Dimensions.iconLarge,
                  color: folderColor,
                ),
              ),
              const SizedBox(height: Dimensions.spacing12),
              // Folder name
              Text(
                folder.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: Dimensions.spacing4),
              // Document count
              Text(
                '${folder.documentCount} ${folder.documentCount == 1 ? 'doc' : 'docs'}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              // Subfolder indicator
              if (!folder.isRoot) ...[
                const SizedBox(height: Dimensions.spacing4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.spacing8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    'Subfolder',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData get _folderIcon => switch (folder.icon) {
        'work' => Icons.work_outlined,
        'person' => Icons.person_outlined,
        'receipt' => Icons.receipt_long_outlined,
        'school' => Icons.school_outlined,
        'finance' => Icons.account_balance_outlined,
        _ => Icons.folder_outlined,
      };

  Color _parseColor(String hex) {
    try {
      final code = hex.replaceFirst('#', '');
      return Color(int.parse('FF$code', radix: 16));
    } catch (_) {
      return AppColors.scannerAccent;
    }
  }
}
