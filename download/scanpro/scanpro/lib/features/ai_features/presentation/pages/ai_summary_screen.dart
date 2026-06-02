import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/ai_features/presentation/providers/ai_provider.dart';
import 'package:scanpro/features/ai_features/presentation/widgets/ai_loading_shimmer.dart';
import 'package:scanpro/features/ai_features/presentation/widgets/key_point_card.dart';
import 'package:scanpro/features/ai_features/presentation/widgets/tag_suggestion_chip.dart';

class AiSummaryScreen extends ConsumerStatefulWidget {
  const AiSummaryScreen({super.key});

  @override
  ConsumerState<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends ConsumerState<AiSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiSummaryProvider.notifier).generateSummary('sample-doc-1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(aiSummaryProvider);
    final tagState = ref.watch(aiTagProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Summary'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _regenerateSummary(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerate',
          ),
        ],
      ),
      body: summaryState.summary.when(
        loading: () => _buildLoadingContent(theme),
        error: (error, _) => _buildErrorState(theme, error.toString()),
        data: (summary) => _buildSummaryContent(theme, summary, tagState),
      ),
    );
  }

  Widget _buildLoadingContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiLoadingShimmer(height: 120),
          const SizedBox(height: 16),
          Text('Key Points', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AiLoadingShimmer(height: 40 + (i * 4.0)),
          )),
          const SizedBox(height: 16),
          const AiLoadingShimmer(height: 48),
          const SizedBox(height: 16),
          const AiLoadingShimmer(height: 60),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Failed to generate summary', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(error, textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _regenerateSummary,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(ThemeData theme, AiSummary summary, AiTagState tagState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentPreview(theme),
          const SizedBox(height: 16),
          _buildConfidenceIndicator(theme, summary.confidence),
          const SizedBox(height: 20),
          _buildSummaryText(theme, summary.summaryText),
          const SizedBox(height: 24),
          _buildKeyPointsSection(theme, summary.keyPoints),
          const SizedBox(height: 24),
          _buildCategorySuggestion(theme, summary.suggestedCategory),
          const SizedBox(height: 20),
          _buildTagsSection(theme, tagState),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invoice_March_2025.pdf', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('3 pages • 2.4 MB', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildConfidenceIndicator(ThemeData theme, double confidence) {
    final percent = (confidence * 100).toInt();
    final color = percent >= 90 ? Colors.green : percent >= 70 ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 18, color: color),
          const SizedBox(width: 8),
          Text('AI Confidence', style: theme.textTheme.labelMedium?.copyWith(color: color)),
          const Spacer(),
          Text('$percent%', style: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: confidence,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSummaryText(ThemeData theme, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.summarize, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Summary', style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(height: 1.7)),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildKeyPointsSection(ThemeData theme, List<String> keyPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.checklist, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Key Points', style: theme.textTheme.titleMedium),
            const Spacer(),
            Text('${keyPoints.length} found', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        ...keyPoints.asMap().entries.map((entry) => KeyPointCard(
              text: entry.value,
              index: entry.key,
            )),
      ],
    );
  }

  Widget _buildCategorySuggestion(ThemeData theme, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_outlined, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Suggested Category', style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4D2DAB).withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF4D2DAB).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D2DAB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder, size: 20, color: Color(0xFF4D2DAB)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(category, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              FilledButton.tonal(
                onPressed: () => _applyCategory(category),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4D2DAB).withOpacity(0.1),
                  foregroundColor: const Color(0xFF4D2DAB),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildTagsSection(ThemeData theme, AiTagState tagState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.label, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Suggested Tags', style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        tagState.tags.when(
          loading: () => const Wrap(children: [SizedBox(width: 60, height: 32, child: AiLoadingShimmer(height: 32))]),
          error: (_, __) => Text('Failed to load tags', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
          data: (tags) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.asMap().entries.map((entry) => TagSuggestionChip(
                  suggestion: entry.value,
                  onApply: () => ref.read(aiTagProvider.notifier).applyTag(entry.key),
                  onIgnore: () => ref.read(aiTagProvider.notifier).ignoreTag(entry.key),
                )).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  void _regenerateSummary() {
    ref.read(aiSummaryProvider.notifier).generateSummary('sample-doc-1');
    ref.read(aiTagProvider.notifier).generateTags('sample-doc-1');
  }

  void _applyCategory(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category "$category" applied'), behavior: SnackBarBehavior.floating),
    );
  }
}
