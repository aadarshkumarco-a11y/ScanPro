import 'package:flutter/material.dart';
import '../providers/annotation_provider.dart';

class AnnotationToolbar extends StatelessWidget {
  final AnnotationType? activeTool;
  final String activeColor;
  final ValueChanged<AnnotationType> onToolSelected;
  final ValueChanged<String> onColorSelected;

  const AnnotationToolbar({
    super.key,
    this.activeTool,
    required this.activeColor,
    required this.onToolSelected,
    required this.onColorSelected,
  });

  static const List<_ToolItem> _tools = [
    _ToolItem(type: AnnotationType.highlight, icon: Icons.highlight, label: 'Highlight'),
    _ToolItem(type: AnnotationType.underline, icon: Icons.format_underline, label: 'Underline'),
    _ToolItem(type: AnnotationType.draw, icon: Icons.draw, label: 'Draw'),
    _ToolItem(type: AnnotationType.shape, icon: Icons.crop_square, label: 'Shape'),
    _ToolItem(type: AnnotationType.note, icon: Icons.note_add, label: 'Note'),
    _ToolItem(type: AnnotationType.text, icon: Icons.text_fields, label: 'Text'),
  ];

  static const List<String> _colors = [
    '#FFFF00', // Yellow
    '#00FF00', // Green
    '#FF0000', // Red
    '#0000FF', // Blue
    '#FF00FF', // Magenta
    '#000000', // Black
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color picker row
            if (activeTool != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Text(
                      'Color:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ..._colors.map((colorHex) {
                      final color = _parseColor(colorHex);
                      final isActive = colorHex == activeColor;
                      return GestureDetector(
                        onTap: () => onColorSelected(colorHex),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: isActive
                                ? Border.all(
                                    color: theme.colorScheme.onSurface,
                                    width: 2,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            // Tools row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _tools.map((tool) {
                  final isActive = tool.type == activeTool;
                  return _ToolButton(
                    tool: tool,
                    isActive: isActive,
                    onTap: () => onToolSelected(tool.type),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class _ToolItem {
  final AnnotationType type;
  final IconData icon;
  final String label;

  const _ToolItem({
    required this.type,
    required this.icon,
    required this.label,
  });
}

class _ToolButton extends StatelessWidget {
  final _ToolItem tool;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolButton({
    required this.tool,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tool.icon,
              size: 22,
              color: isActive
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              tool.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
