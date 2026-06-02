import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/ocr/presentation/providers/ocr_provider.dart';

class TextBlockWidget extends StatelessWidget {
  final TextBlock block;
  final int index;

  const TextBlockWidget({super.key, required this.block, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidencePercent = (block.confidence * 100).toInt();
    final confidenceColor = confidencePercent >= 90
        ? Colors.green
        : confidencePercent >= 70
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => _copyText(context, block.text),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIndexBadge(theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      block.text,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildBoundingBoxChip(theme),
                        const SizedBox(width: 8),
                        _buildConfidenceIndicator(theme, confidencePercent, confidenceColor),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _copyText(context, block.text),
                icon: Icon(Icons.copy_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant),
                tooltip: 'Copy',
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms, delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildIndexBadge(ThemeData theme) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF4D2DAB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFF4D2DAB),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBoundingBoxChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${block.boundingBox.left.toInt()},${block.boundingBox.top.toInt()}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator(ThemeData theme, int percent, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.signal_cellular_alt, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$percent%',
          style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _copyText(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: "${text.length > 40 ? '${text.substring(0, 40)}...' : text}"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
