import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/ai_result.dart';
import '../providers/ai_provider.dart';

/// AI Summary generation screen.
///
/// Allows the user to select a document or paste text,
/// adjust summary length, and view the generated summary.
class AiSummaryScreen extends ConsumerStatefulWidget {
  const AiSummaryScreen({super.key});

  @override
  ConsumerState<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends ConsumerState<AiSummaryScreen> {
  final _textController = TextEditingController();
  int _maxWords = AppConstants.aiSummaryMaxWordsDefault;
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
        title: const Text('AI Summary'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          if (aiState.currentResult != null)
            IconButton(
              onPressed: () {
                // Copy result to clipboard.
              },
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Document Input ─────────────────────────────────────────
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
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Paste your document text here, or select '
                    'a document from your library…',
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
                suffixIcon: IconButton(
                  onPressed: () => _textController.clear(),
                  icon: Icon(
                    Icons.clear_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Select document button.
            OutlinedButton.icon(
              onPressed: () {
                // In production, this would open a document picker.
              },
              icon: Icon(
                Icons.folder_open_rounded,
                color: _primaryColor,
                size: 18,
              ),
              label: Text(
                'Select Document',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _primaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _primaryColor.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Summary Length ─────────────────────────────────────────
            Row(
              children: [
                Text(
                  'Summary Length',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '$_maxWords words',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Slider(
              value: _maxWords.toDouble(),
              min: 50,
              max: AppConstants.aiSummaryMaxWordsLimit.toDouble(),
              divisions: 9,
              activeColor: _primaryColor,
              label: '$_maxWords',
              onChanged: (value) {
                setState(() {
                  _maxWords = value.round();
                });
              },
            ),
            const SizedBox(height: 16),

            // ── Generate Button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: aiState.status == AiStatus.loading
                    ? null
                    : _generateSummary,
                icon: aiState.status == AiStatus.loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 20),
                label: Text(
                  aiState.status == AiStatus.loading
                      ? 'Generating Summary…'
                      : 'Generate Summary',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
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
                    Icon(
                      Icons.error_outline_rounded,
                      color: colorScheme.error,
                      size: 20,
                    ),
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
                aiState.currentResult!.type == AiFeatureType.summary) ...[
              _SummaryResultCard(
                result: aiState.currentResult!,
                primaryColor: _primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateSummary() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or select document text')),
      );
      return;
    }

    await ref.read(aiProvider.notifier).summarizeDocument(
          text: text,
          maxWords: _maxWords,
        );
  }
}

/// Card displaying the generated summary result.
class _SummaryResultCard extends StatelessWidget {
  const _SummaryResultCard({
    required this.result,
    required this.primaryColor,
  });

  final AiResult result;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.summarize_rounded,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'AI Summary',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),
            if (result.confidence != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: result.isHighConfidence
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(result.confidence! * 100).round()}% confidence',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: result.isHighConfidence
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: SelectableText(
            result.resultText,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
