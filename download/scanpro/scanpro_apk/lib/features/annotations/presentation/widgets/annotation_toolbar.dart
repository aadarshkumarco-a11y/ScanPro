import 'package:flutter/material.dart';

import '../../domain/entities/annotation.dart';

/// Bottom toolbar widget for selecting annotation tools.
///
/// Displays a row of tool buttons: highlight pen, draw, shapes,
/// note, and text. The currently selected tool is highlighted.
/// Also includes an "Add" button to create a new annotation
/// with the selected tool type.
class AnnotationToolbar extends StatelessWidget {
  const AnnotationToolbar({
    super.key,
    this.selectedTool,
    required this.onToolSelected,
    required this.onAddAnnotation,
  });

  /// The currently selected annotation tool type, or null if none selected.
  final AnnotationType? selectedTool;

  /// Callback when a tool is selected or deselected.
  final ValueChanged<AnnotationType?> onToolSelected;

  /// Callback when the add annotation button is pressed.
  final VoidCallback onAddAnnotation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const primaryColor = Color(0xFF4D2DAB);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Tool Buttons Row ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ToolButton(
                    icon: Icons.highlight_rounded,
                    label: 'Highlight',
                    type: AnnotationType.highlight,
                    isSelected: selectedTool == AnnotationType.highlight,
                    accentColor: Colors.amber,
                    primaryColor: primaryColor,
                    onTap: () => onToolSelected(
                      selectedTool == AnnotationType.highlight
                          ? null
                          : AnnotationType.highlight,
                    ),
                  ),
                  _ToolButton(
                    icon: Icons.draw_rounded,
                    label: 'Draw',
                    type: AnnotationType.draw,
                    isSelected: selectedTool == AnnotationType.draw,
                    accentColor: Colors.red,
                    primaryColor: primaryColor,
                    onTap: () => onToolSelected(
                      selectedTool == AnnotationType.draw
                          ? null
                          : AnnotationType.draw,
                    ),
                  ),
                  _ToolButton(
                    icon: Icons.crop_square_rounded,
                    label: 'Shape',
                    type: AnnotationType.shape,
                    isSelected: selectedTool == AnnotationType.shape,
                    accentColor: Colors.green,
                    primaryColor: primaryColor,
                    onTap: () => onToolSelected(
                      selectedTool == AnnotationType.shape
                          ? null
                          : AnnotationType.shape,
                    ),
                  ),
                  _ToolButton(
                    icon: Icons.sticky_note_2_rounded,
                    label: 'Note',
                    type: AnnotationType.note,
                    isSelected: selectedTool == AnnotationType.note,
                    accentColor: Colors.orange,
                    primaryColor: primaryColor,
                    onTap: () => onToolSelected(
                      selectedTool == AnnotationType.note
                          ? null
                          : AnnotationType.note,
                    ),
                  ),
                  _ToolButton(
                    icon: Icons.text_fields_rounded,
                    label: 'Text',
                    type: AnnotationType.text,
                    isSelected: selectedTool == AnnotationType.text,
                    accentColor: Colors.blue,
                    primaryColor: primaryColor,
                    onTap: () => onToolSelected(
                      selectedTool == AnnotationType.text
                          ? null
                          : AnnotationType.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Add Annotation Button ────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  onPressed: onAddAnnotation,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(
                    selectedTool != null
                        ? 'Add ${_toolDisplayName(selectedTool!)}'
                        : 'Add Annotation',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the display name for an annotation type.
  String _toolDisplayName(AnnotationType type) {
    switch (type) {
      case AnnotationType.highlight:
        return 'Highlight';
      case AnnotationType.draw:
        return 'Drawing';
      case AnnotationType.shape:
        return 'Shape';
      case AnnotationType.note:
        return 'Note';
      case AnnotationType.text:
        return 'Text';
    }
  }
}

/// A single tool button in the annotation toolbar.
class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.type,
    required this.isSelected,
    required this.accentColor,
    required this.primaryColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final AnnotationType type;
  final bool isSelected;
  final Color accentColor;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: primaryColor, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : accentColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? primaryColor : null,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
