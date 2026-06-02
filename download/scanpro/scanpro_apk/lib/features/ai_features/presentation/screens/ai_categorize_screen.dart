import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/ai_result.dart';
import '../providers/ai_provider.dart';

/// AI auto-categorize screen.
///
/// Allows the user to input document text, then displays
/// the AI-suggested categories, subcategories, and tags.
class AiCategorizeScreen extends ConsumerStatefulWidget {
  const AiCategorizeScreen({super.key});

  @override
  ConsumerState<AiCategorizeScreen> createState() =>
      _AiCategorizeScreenState();
}

class _AiCategorizeScreenState extends ConsumerState<AiCategorizeScreen> {
  final _textController = TextEditingController();
  static const Color _primaryColor = Color(0xFF4D2DAB);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final aiState = ref.watch(aiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto-Categorize'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Description ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF26A69A)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI will analyze your document and suggest '
                      'categories, subcategories, and tags.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Text Input ─────────────────────────────────────────────
            Text(
              'Document Text',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Paste document text to categorize…',
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Categorize Button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: aiState.status == AiStatus.loading
                    ? null
                    : _categorize,
                icon: aiState.status == AiStatus.loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.category_rounded, size: 20),
                label: Text(
                  aiState.status == AiStatus.loading
                      ? 'Analyzing…'
                      : 'Categorize Document',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Error ──────────────────────────────────────────────────
            if (aiState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        aiState.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Result ─────────────────────────────────────────────────
            if (aiState.currentResult != null &&
                aiState.currentResult!.type == AiFeatureType.categorize)
              _CategorizeResultCard(
                result: aiState.currentResult!,
                primaryColor: _primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _categorize() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter document text')),
      );
      return;
    }

    await ref.read(aiProvider.notifier).categorizeDocument(text: text);
  }
}

/// Card displaying the categorization result.
class _CategorizeResultCard extends StatelessWidget {
  const _CategorizeResultCard({
    required this.result,
    required this.primaryColor,
  });

  final AiResult result;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final metadata = result.metadata;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Categorization',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),

        // Primary Category
        if (metadata['primary_category'] != null) ...[
          _CategoryRow(
            label: 'Primary Category',
            value: metadata['primary_category'].toString(),
            icon: Icons.folder_rounded,
            color: primaryColor,
          ),
          const SizedBox(height: 8),
        ],

        // Subcategories
        if (metadata['subcategories'] is List) ...[
          Text(
            'Subcategories',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: (metadata['subcategories'] as List)
                .map((cat) => Chip(
                      label: Text(
                        cat.toString(),
                        style: theme.textTheme.labelSmall,
                      ),
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      side: BorderSide.none,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Tags
        if (metadata['tags'] is List) ...[
          Text(
            'Suggested Tags',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: (metadata['tags'] as List)
                .map((tag) => Chip(
                      label: Text(
                        '#${tag.toString()}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF00897B),
                        ),
                      ),
                      backgroundColor:
                          const Color(0xFF00897B).withValues(alpha: 0.1),
                      side: BorderSide.none,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Confidence
        if (result.confidence != null)
          _CategoryRow(
            label: 'Confidence',
            value: '${(result.confidence! * 100).round()}%',
            icon: result.isHighConfidence
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            color: result.isHighConfidence ? Colors.green : Colors.orange,
          ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
