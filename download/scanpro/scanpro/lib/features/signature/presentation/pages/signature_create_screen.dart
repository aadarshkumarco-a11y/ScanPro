import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/signature_provider.dart';
import '../widgets/signature_canvas.dart';

class SignatureCreateScreen extends ConsumerStatefulWidget {
  const SignatureCreateScreen({super.key});

  @override
  ConsumerState<SignatureCreateScreen> createState() =>
      _SignatureCreateScreenState();
}

class _SignatureCreateScreenState extends ConsumerState<SignatureCreateScreen> {
  final List<List<Offset>> _strokes = [];
  final List<List<Offset>> _undoStack = [];
  List<Offset> _currentStroke = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;

  static const List<Color> _colors = [
    Colors.black,
    Colors.blue,
    Colors.red,
  ];

  void _onStrokeStart(Offset point) {
    setState(() {
      _currentStroke = [point];
    });
  }

  void _onStrokeUpdate(Offset point) {
    setState(() {
      _currentStroke = [..._currentStroke, point];
    });
  }

  void _onStrokeEnd() {
    if (_currentStroke.isEmpty) return;
    setState(() {
      _strokes.add(List.from(_currentStroke));
      _undoStack.clear();
      _currentStroke = [];
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _undoStack.add(_strokes.removeLast());
    });
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _undoStack.clear();
      _currentStroke = [];
    });
  }

  Future<void> _save() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw a signature first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final signature = SignatureModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Signature ${ref.read(signatureProvider).signatures.length + 1}',
      createdAt: DateTime.now(),
      color: '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
      strokeWidth: _strokeWidth,
    );

    await ref.read(signatureProvider.notifier).addSignature(signature);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signature saved successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Signature'),
        actions: [
          IconButton(
            onPressed: _undo,
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
          ),
          IconButton(
            onPressed: _clear,
            icon: const Icon(Icons.clear),
            tooltip: 'Clear',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SignatureCanvas(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
                  strokeColor: _selectedColor,
                  strokeWidth: _strokeWidth,
                  onStrokeStart: _onStrokeStart,
                  onStrokeUpdate: _onStrokeUpdate,
                  onStrokeEnd: _onStrokeEnd,
                ),
              ),
            ),
          ),
          _buildColorPicker(theme),
          _buildStrokeWidthSelector(theme),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Save Signature'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Color:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          ..._colors.map((color) {
            final isSelected = color == _selectedColor;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: isSelected
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 3,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStrokeWidthSelector(ThemeData theme) {
    const widths = [2.0, 3.0, 5.0];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Width:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          ...widths.map((width) {
            final isSelected = width == _strokeWidth;
            return GestureDetector(
              onTap: () => setState(() => _strokeWidth = width),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Text(
                  width.toInt().toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
