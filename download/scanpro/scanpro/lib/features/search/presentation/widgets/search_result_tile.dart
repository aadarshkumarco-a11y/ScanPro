import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/search/presentation/providers/search_provider.dart';

class SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final String query;

  const SearchResultTile({super.key, required this.result, required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildCategoryIcon(theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedText(
                      result.title,
                      query,
                      theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600) ?? const TextStyle(),
                    ),
                    const SizedBox(height: 2),
                    _buildSubtitle(theme),
                  ],
                ),
              ),
              _buildCategoryBadge(theme),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildCategoryIcon(ThemeData theme) {
    final colors = {
      SearchCategory.files: Colors.red,
      SearchCategory.ocrContent: Colors.teal,
      SearchCategory.tags: Colors.orange,
      SearchCategory.folders: Colors.amber.shade800,
    };
    final color = colors[result.category] ?? theme.colorScheme.primary;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(result.icon, color: color, size: 20),
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    String subtitle = result.subtitle;
    if (result.lastModified != null) {
      final days = DateTime.now().difference(result.lastModified!).inDays;
      final timeLabel = days == 0 ? 'Today' : days == 1 ? 'Yesterday' : '$days days ago';
      subtitle = '$subtitle • $timeLabel';
    }
    return Text(
      subtitle,
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCategoryBadge(ThemeData theme) {
    final labels = {
      SearchCategory.files: 'File',
      SearchCategory.ocrContent: 'OCR',
      SearchCategory.tags: 'Tag',
      SearchCategory.folders: 'Folder',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        labels[result.category] ?? '',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query, TextStyle baseStyle) {
    if (query.isEmpty) return Text(text, style: baseStyle);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) return Text(text, style: baseStyle);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: text.substring(0, matchIndex)),
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: baseStyle.copyWith(
              color: const Color(0xFF4D2DAB),
              fontWeight: FontWeight.bold,
              backgroundColor: const Color(0xFF4D2DAB).withOpacity(0.12),
            ),
          ),
          TextSpan(text: text.substring(matchIndex + query.length)),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context) {
    switch (result.category) {
      case SearchCategory.files:
        if (result.filePath != null) {
          Navigator.pushNamed(context, '/pdf/viewer', arguments: result.filePath);
        }
        break;
      case SearchCategory.ocrContent:
        Navigator.pushNamed(context, '/ocr/result', arguments: result.id);
        break;
      case SearchCategory.tags:
        Navigator.pushNamed(context, '/search', arguments: {'tag': result.title});
        break;
      case SearchCategory.folders:
        Navigator.pushNamed(context, '/folder', arguments: result.title);
        break;
    }
  }
}
