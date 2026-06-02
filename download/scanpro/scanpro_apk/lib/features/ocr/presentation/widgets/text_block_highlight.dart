import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/ocr_result.dart';

/// Widget to highlight detected text blocks with bounding box
/// visualization and confidence indicators.
///
/// Each block displays its text content with a colored border
/// indicating confidence level, and optionally highlights
/// search query matches within the text.
class TextBlockHighlight extends StatelessWidget {
  const TextBlockHighlight({
    super.key,
    required this.block,
    this.searchQuery = '',
    this.onTap,
  });

  /// The text block to display.
  final TextBlock block;

  /// Optional search query to highlight within the text.
  final String searchQuery;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Returns the confidence-based color.
  Color get _confidenceColor {
    if (block.confidence >= 0.8) return AppTheme.successColor;
    if (block.confidence >= 0.6) return AppTheme.warningColor;
    return AppTheme.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidenceColor = _confidenceColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: confidenceColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: confidenceColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Block Header ─────────────────────────────────────
              Row(
                children: [
                  // Block type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      block.blockType.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Confidence indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        block.confidence >= 0.7
                            ? Icons.verified_rounded
                            : Icons.warning_amber_rounded,
                        size: 14,
                        color: confidenceColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(block.confidence * 100).toInt()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: confidenceColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Bounding Box Info ────────────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.crop_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Position: ${block.boundingBox[0].toInt()}, ${block.boundingBox[1].toInt()} → ${block.boundingBox[2].toInt()}, ${block.boundingBox[3].toInt()}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Text Content ─────────────────────────────────────
              if (searchQuery.isNotEmpty && block.text.toLowerCase().contains(searchQuery.toLowerCase()))
                _buildHighlightedText(theme)
              else
                Text(
                  block.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds text with search query highlighting.
  Widget _buildHighlightedText(ThemeData theme) {
    final spans = <TextSpan>[];
    final lowerText = block.text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    int start = 0;

    while (start < lowerText.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: block.text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: block.text.substring(start, index)));
      }

      spans.add(TextSpan(
        text: block.text.substring(index, index + searchQuery.length),
        style: TextStyle(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.25),
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ));

      start = index + searchQuery.length;
    }

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        children: spans,
      ),
    );
  }
}
