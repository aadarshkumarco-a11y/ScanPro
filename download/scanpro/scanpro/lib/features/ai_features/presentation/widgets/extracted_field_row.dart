import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanpro/features/ai_features/presentation/providers/ai_provider.dart';

class ExtractedFieldRow extends StatelessWidget {
  final ExtractedField field;
  final bool isLast;

  const ExtractedFieldRow({
    super.key,
    required this.field,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(10))
            : BorderRadius.zero,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              field.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              field.value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (field.isCopyable)
            IconButton(
              onPressed: () => _copyValue(context, field.value),
              icon: Icon(
                Icons.copy_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Copy ${field.label}',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  void _copyValue(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $value'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
