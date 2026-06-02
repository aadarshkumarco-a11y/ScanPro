import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/home_provider.dart';
import '../widgets/quick_action_button.dart';
import '../../../scanner/domain/entities/scanned_document.dart';
import '../../../documents/presentation/providers/document_provider.dart';

/// Home dashboard screen – the primary landing view of the app.
///
/// Displays a personalised greeting, storage usage card, quick-action
/// buttons (Scan, OCR, PDF Tools, QR), and a list of recently
/// accessed documents with a "View All" link.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load documents on first build.
    Future.microtask(() {
      ref.read(documentsProvider.notifier).loadDocuments();
      ref.read(documentsProvider.notifier).loadFolders();
      ref.read(documentsProvider.notifier).loadTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final greeting = ref.watch(greetingProvider);
    final storageInfo = ref.watch(storageInfoProvider);
    final quickActions = ref.watch(quickActionsProvider);
    final recentDocs = ref.watch(recentDocumentsProvider);
    final docsState = ref.watch(documentsProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: () async {
          ref.read(documentsProvider.notifier).loadDocuments();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar with greeting ────────────────────────────────
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 1,
              backgroundColor: colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.only(left: 20, bottom: 16, right: 20),
                title: Text(
                  greeting,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => context.push(AppRoutes.search),
                  icon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurface,
                  ),
                  tooltip: 'Search',
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Navigate to notifications screen.
                  },
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: colorScheme.onSurface,
                  ),
                  tooltip: 'Notifications',
                ),
                const SizedBox(width: 4),
              ],
            ),

            // ── Content ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Storage Usage Card ──────────────────────────
                    _StorageUsageCard(storageInfo: storageInfo),
                    const SizedBox(height: 24),

                    // ── Quick Actions ───────────────────────────────
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _QuickActionsRow(quickActions: quickActions),
                    const SizedBox(height: 28),

                    // ── Recent Documents ────────────────────────────
                    _RecentDocumentsHeader(
                      onSeeAll: () => context.go(AppRoutes.documents),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Recent Documents List ────────────────────────────────
            if (docsState.status == DocumentsStatus.loading)
              const SliverFillRemaining(
                child: LoadingWidget.inline(message: 'Loading documents…'),
              )
            else if (recentDocs.isEmpty)
              SliverToBoxAdapter(
                child: EmptyDocumentsState(
                  onAction: () => context.push(AppRoutes.scanner),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < recentDocs.length) {
                      return _RecentDocumentCard(
                        document: recentDocs[index],
                        onTap: () => context.push(
                          '${AppRoutes.documentDetail}?id=${recentDocs[index].id}',
                        ),
                      );
                    }
                    return null;
                  },
                  childCount: recentDocs.length,
                ),
              ),

            // Bottom padding for the navigation bar.
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Storage Usage Card
// ═══════════════════════════════════════════════════════════════════

class _StorageUsageCard extends StatelessWidget {
  const _StorageUsageCard({required this.storageInfo});

  final StorageInfo storageInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.08),
              AppTheme.primaryLightColor.withValues(alpha: 0.04),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Storage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.cloud_outlined,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: storageInfo.usageRatio,
                minHeight: 8,
                backgroundColor:
                    colorScheme.primary.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  storageInfo.usageRatio > 0.85
                      ? AppTheme.accentColor
                      : colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${storageInfo.usedFormatted} of ${storageInfo.totalFormatted} used',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  '${storageInfo.documentCount} docs',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Quick Actions Row
// ═══════════════════════════════════════════════════════════════════

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.quickActions});

  final List<QuickAction> quickActions;

  IconData _resolveIcon(String iconName) {
    const iconMap = <String, IconData>{
      'document_scanner': Icons.document_scanner_rounded,
      'text_fields': Icons.text_fields_rounded,
      'picture_as_pdf': Icons.picture_as_pdf_rounded,
      'qr_code_scanner': Icons.qr_code_scanner_rounded,
    };
    return iconMap[iconName] ?? Icons.apps_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: quickActions.map((action) {
        return QuickActionButton(
          icon: _resolveIcon(action.icon),
          label: action.label,
          gradientColors: action.gradientColors,
          onTap: () => context.push(action.route),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Recent Documents Header
// ═══════════════════════════════════════════════════════════════════

class _RecentDocumentsHeader extends StatelessWidget {
  const _RecentDocumentsHeader({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Documents',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'View All',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Recent Document Card
// ═══════════════════════════════════════════════════════════════════

class _RecentDocumentCard extends StatelessWidget {
  const _RecentDocumentCard({
    required this.document,
    required this.onTap,
  });

  final ScannedDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPdf = document.pdfPath != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Document icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: (isPdf
                          ? AppTheme.accentColor
                          : AppTheme.primaryColor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPdf
                      ? Icons.picture_as_pdf_rounded
                      : Icons.image_outlined,
                  color: isPdf
                      ? AppTheme.accentColor
                      : AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Title + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormatter.documentDate(document.updatedAt)}  •  ${FileUtils.formatBytes(document.fileSize)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Favourite icon
              if (document.isFavorite)
                Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.accentColor,
                  size: 18,
                ),

              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
