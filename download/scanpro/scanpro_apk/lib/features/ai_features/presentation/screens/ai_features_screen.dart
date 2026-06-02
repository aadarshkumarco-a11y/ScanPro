import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/ai_result.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_feature_card.dart';

/// AI features hub screen.
///
/// Displays a grid of feature cards, each representing an AI
/// capability: Summarize, Categorize, Smart Rename, Extract Key Info.
/// Tapping a card navigates to the corresponding feature screen.
class AiFeaturesScreen extends ConsumerStatefulWidget {
  const AiFeaturesScreen({super.key});

  @override
  ConsumerState<AiFeaturesScreen> createState() => _AiFeaturesScreenState();
}

class _AiFeaturesScreenState extends ConsumerState<AiFeaturesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(aiProvider.notifier).loadResults());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final aiState = ref.watch(aiProvider);
    const primaryColor = Color(0xFF4D2DAB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Features'),
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
            // ── Header Banner ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4D2DAB), Color(0xFF7C5CC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI-Powered Tools',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use Gemini AI to summarize, categorize, '
                    'rename, and extract data from your documents.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Feature Cards ──────────────────────────────────────────
            Text(
              'Features',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                AiFeatureCard(
                  icon: Icons.summarize_rounded,
                  title: 'Summarize',
                  description: 'Generate concise document summaries',
                  gradientColors: [
                    const Color(0xFF4D2DAB),
                    const Color(0xFF6B4EC0),
                  ],
                  onTap: () => context.push(AppConstants.aiSummaryRoute),
                ),
                AiFeatureCard(
                  icon: Icons.category_rounded,
                  title: 'Categorize',
                  description: 'Auto-categorize your documents',
                  gradientColors: [
                    const Color(0xFF00897B),
                    const Color(0xFF26A69A),
                  ],
                  onTap: () => context.push(
                    '${AppConstants.aiFeaturesRoute}/categorize',
                  ),
                ),
                AiFeatureCard(
                  icon: Icons.drive_file_rename_outline_rounded,
                  title: 'Smart Rename',
                  description: 'AI-powered name suggestions',
                  gradientColors: [
                    const Color(0xFFE65100),
                    const Color(0xFFFF8F00),
                  ],
                  onTap: () => context.push(
                    '${AppConstants.aiFeaturesRoute}/rename',
                  ),
                ),
                AiFeatureCard(
                  icon: Icons.data_object_rounded,
                  title: 'Extract Info',
                  description: 'Pull key data from documents',
                  gradientColors: [
                    const Color(0xFF1565C0),
                    const Color(0xFF42A5F5),
                  ],
                  onTap: () => context.push(
                    '${AppConstants.aiFeaturesRoute}/extract',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Recent Results ─────────────────────────────────────────
            if (aiState.results.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Results',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to full results history.
                    },
                    child: Text(
                      'View All',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...aiState.results.take(3).map((result) => _RecentResultTile(
                    result: result,
                    primaryColor: primaryColor,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tile displaying a recent AI result.
class _RecentResultTile extends StatelessWidget {
  const _RecentResultTile({
    required this.result,
    required this.primaryColor,
  });

  final AiResult result;
  final Color primaryColor;

  IconData _featureIcon(AiFeatureType type) {
    switch (type) {
      case AiFeatureType.summary:
        return Icons.summarize_rounded;
      case AiFeatureType.categorize:
        return Icons.category_rounded;
      case AiFeatureType.rename:
        return Icons.drive_file_rename_outline_rounded;
      case AiFeatureType.extract:
        return Icons.data_object_rounded;
      case AiFeatureType.qa:
        return Icons.question_answer_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _featureIcon(result.type),
            color: primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          result.type.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          result.resultText.length > 60
              ? '${result.resultText.substring(0, 60)}…'
              : result.resultText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatDate(result.createdAt),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}';
  }
}
