import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// share_plus removed – using stub implementation

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/ocr_result.dart';
import '../providers/ocr_provider.dart';
import '../widgets/text_block_highlight.dart';

/// OCR result screen displaying recognized text with highlighting,
/// copy all, share, edit, and search-within-text functionality.
class OcrResultScreen extends ConsumerStatefulWidget {
  const OcrResultScreen({super.key});

  @override
  ConsumerState<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends ConsumerState<OcrResultScreen> {
  bool _isEditing = false;
  late TextEditingController _editController;
  String _searchQuery = '';
  bool _showSearch = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController();
  }

  @override
  void dispose() {
    _editController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ocrState = ref.watch(ocrProvider);
    final result = ocrState.currentResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('OCR Result'),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.text_fields_rounded,
                size: 64,
                color: colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'No OCR result available',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.ocr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Start OCR'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Result'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                _searchQuery = '';
              });
            },
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
            ),
            tooltip: 'Search in text',
          ),
          IconButton(
            onPressed: () => _toggleEdit(result),
            icon: Icon(
              _isEditing ? Icons.check_rounded : Icons.edit_rounded,
            ),
            tooltip: _isEditing ? 'Done editing' : 'Edit text',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, result),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy_all',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Copy All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'select_all',
                child: Row(
                  children: [
                    Icon(Icons.select_all_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Select All'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: _showSearch
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search in text…',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          // ── Result Info Bar ────────────────────────────────────────
          _ResultInfoBar(result: result),

          // ── Text Content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: _isEditing
                  ? _buildEditMode(theme, result)
                  : _buildViewMode(theme, colorScheme, result),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomActionBar(result: result),
    );
  }

  /// Builds the text view mode with search highlighting.
  Widget _buildViewMode(
    ThemeData theme,
    ColorScheme colorScheme,
    OcrResult result,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Text Blocks with Highlighting ──────────────────────────
        if (result.blocks.isNotEmpty) ...[
          Text(
            'Detected Text Blocks',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ...result.blocks.map((block) => TextBlockHighlight(
                block: block,
                searchQuery: _searchQuery,
              )),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
        ],

        // ── Full Text ──────────────────────────────────────────────
        Text(
          'Full Text',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: SelectableText(
            result.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the text edit mode.
  Widget _buildEditMode(ThemeData theme, OcrResult result) {
    _editController.text = result.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppTheme.warningColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Edit mode — changes are local only',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.warningColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _editController,
          maxLines: null,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            filled: true,
          ),
        ),
      ],
    );
  }

  /// Toggles edit mode.
  void _toggleEdit(OcrResult result) {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _editController.text = result.text;
      }
    });
  }

  /// Handles menu actions.
  void _handleMenuAction(String action, OcrResult result) {
    switch (action) {
      case 'copy_all':
        Clipboard.setData(ClipboardData(text: result.text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Text copied to clipboard')),
        );
      case 'share':
        Clipboard.setData(ClipboardData(text: result.text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Text copied to clipboard')),
        );
      case 'select_all':
        // SelectableText handles this natively
        break;
    }
  }
}

/// Information bar showing OCR confidence, language, and word count.
class _ResultInfoBar extends StatelessWidget {
  const _ResultInfoBar({required this.result});

  final OcrResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          _InfoChip(
            icon: Icons.language_rounded,
            label: result.language.toUpperCase(),
          ),
          const SizedBox(width: 12),
          _InfoChip(
            icon: Icons.speed_rounded,
            label: '${(result.confidence * 100).toInt()}%',
            color: result.isHighConfidence
                ? AppTheme.successColor
                : AppTheme.warningColor,
          ),
          const SizedBox(width: 12),
          _InfoChip(
            icon: Icons.text_fields_rounded,
            label: '${result.wordCount} words',
          ),
          const SizedBox(width: 12),
          _InfoChip(
            icon: Icons.widgets_rounded,
            label: '${result.blocks.length} blocks',
          ),
        ],
      ),
    );
  }
}

/// Small info chip for the result bar.
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? AppTheme.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom action bar with copy and share buttons.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.result});

  final OcrResult result;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy All'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Text copied to clipboard')),
                  );
                },
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
