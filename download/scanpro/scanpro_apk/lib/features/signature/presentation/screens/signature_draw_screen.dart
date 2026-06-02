import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/signature.dart';
import '../providers/signature_provider.dart';
import '../widgets/signature_canvas.dart';

/// Signature drawing screen.
///
/// Provides a canvas for drawing signatures with controls for
/// pen color, pen width, undo, clear, and save.
class SignatureDrawScreen extends ConsumerStatefulWidget {
  const SignatureDrawScreen({super.key});

  @override
  ConsumerState<SignatureDrawScreen> createState() =>
      _SignatureDrawScreenState();
}

class _SignatureDrawScreenState extends ConsumerState<SignatureDrawScreen> {
  final _signatureCanvasKey = GlobalKey<SignatureCanvasState>();
  final _nameController = TextEditingController();
  bool _isDefault = false;
  bool _isSaving = false;

  static const Color _primaryColor = Color(0xFF4D2DAB);

  // Pen settings.
  Color _penColor = Colors.black;
  double _penWidth = 3.0;

  static const _penColors = [
    Colors.black,
    Color(0xFF4D2DAB),
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  static const _penWidths = [2.0, 3.0, 5.0, 8.0];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Signature'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          // Undo button.
          IconButton(
            onPressed: () => _signatureCanvasKey.currentState?.undo(),
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Undo',
          ),
          // Clear button.
          IconButton(
            onPressed: () => _signatureCanvasKey.currentState?.clear(),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Canvas Area ────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _primaryColor.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Guide line.
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).size.height * 0.12,
                      child: Container(
                        height: 1,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: MediaQuery.of(context).size.height * 0.12 - 20,
                      child: Text(
                        'Sign above this line',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    // Canvas.
                    SignatureCanvas(
                      key: _signatureCanvasKey,
                      penColor: _penColor,
                      penWidth: _penWidth,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Pen Controls ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Column(
              children: [
                // Color selector.
                Row(
                  children: [
                    Text(
                      'Color',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ..._penColors.map((color) => GestureDetector(
                          onTap: () => setState(() => _penColor = color),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _penColor == color
                                  ? Border.all(
                                      color: _primaryColor,
                                      width: 3,
                                    )
                                  : Border.all(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 8),

                // Width selector.
                Row(
                  children: [
                    Text(
                      'Width',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ..._penWidths.map((width) => GestureDetector(
                          onTap: () => setState(() => _penWidth = width),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _penWidth == width
                                  ? _primaryColor.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _penWidth == width
                                    ? _primaryColor
                                    : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              width.round().toString(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _penWidth == width
                                    ? _primaryColor
                                    : colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                fontWeight: _penWidth == width
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),

          // ── Save Section ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name field.
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Signature Name',
                    hintText: 'e.g. John Doe - Formal',
                    prefixIcon: Icon(
                      Icons.label_outline_rounded,
                      color: _primaryColor.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Default toggle.
                Row(
                  children: [
                    Switch(
                      value: _isDefault,
                      activeColor: _primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Set as default signature',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Save button.
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveSignature,
                    icon: _isSaving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.save_rounded, size: 20),
                    label: Text(
                      _isSaving ? 'Saving…' : 'Save Signature',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Saves the drawn signature.
  Future<void> _saveSignature() async {
    final canvasState = _signatureCanvasKey.currentState;
    if (canvasState == null || canvasState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw your signature first'),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name for your signature'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Export the signature as base64 PNG.
    final imageBytes = await canvasState.exportPngBytes();
    if (imageBytes == null) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export signature image'),
          ),
        );
      }
      return;
    }

    final base64Image = base64Encode(imageBytes.buffer.asUint8List());

    final signature = Signature(
      id: '',
      name: name,
      imageData: base64Image,
      createdAt: DateTime.now(),
      isDefault: _isDefault,
    );

    final success = await ref.read(signatureProvider.notifier).saveSignature(
          signature,
        );

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signature saved successfully')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save signature')),
      );
    }
  }
}
