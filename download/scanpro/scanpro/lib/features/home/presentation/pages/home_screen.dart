import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/home_provider.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_document_card.dart';
import '../widgets/storage_info_card.dart';
import '../widgets/premium_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentDocs = ref.watch(recentDocumentsProvider);
    final favoriteDocs = ref.watch(favoriteDocumentsProvider);
    final storageInfo = ref.watch(storageInfoProvider);
    final quickActions = ref.watch(quickActionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            actions: [
              IconButton(
                onPressed: () {
                  // Notifications
                },
                icon: Badge(
                  label: const Text('3'),
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to profile
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    'Good morning!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    'What would you like to do today?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  const SizedBox(height: 24),

                  // Quick actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: quickActions
                        .map((action) => QuickActionButton(action: action))
                        .toList(),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                  const SizedBox(height: 28),

                  // Premium banner
                  const PremiumBanner(),
                  const SizedBox(height: 28),

                  // Recent documents
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Documents',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // View all
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Recent documents horizontal list
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recentDocs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: RecentDocumentCard(
                      document: recentDocs[index],
                      onTap: () {},
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
          ),

          // Favorites and storage
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  // Favorite documents
                  if (favoriteDocs.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Favorites',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...favoriteDocs.map(
                      (doc) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.picture_as_pdf,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            doc.name,
                            style: theme.textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            '${doc.pageCount} pages · ${doc.sizeFormatted}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () {},
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  // Storage info
                  StorageInfoCard(storageInfo: storageInfo),
                  const SizedBox(height: 24),

                  // AI Insights card
                  _buildAiInsightsCard(theme),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Insights',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Smart suggestions for you',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInsightRow(
              Icons.text_fields,
              'OCR available for 5 documents',
              theme,
            ),
            const SizedBox(height: 8),
            _buildInsightRow(
              Icons.compress,
              '3 documents can be compressed',
              theme,
            ),
            const SizedBox(height: 8),
            _buildInsightRow(
              Icons.merge,
              '2 receipts can be merged',
              theme,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 500.ms);
  }

  Widget _buildInsightRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
