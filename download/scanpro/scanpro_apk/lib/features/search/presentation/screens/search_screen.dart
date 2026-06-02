import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/search_result.dart';
import '../providers/search_provider.dart';

/// Global search screen with search bar, recent searches, suggestions,
/// result tabs (All, Documents, OCR Text, Tags), and result cards.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _tabController = TabController(
      length: SearchTab.values.length,
      vsync: this,
    );

    // Load recent searches on init.
    Future.microtask(() {
      ref.read(searchProvider.notifier).loadRecentSearches();
    });

    // Auto-focus the search field.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      ref.read(searchProvider.notifier).clearSearch();
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchProvider.notifier).search(query);
    }
  }

  void _onTabChanged(int index) {
    ref.read(searchProvider.notifier).setTab(SearchTab.values[index]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final searchState = ref.watch(searchProvider);

    // Sync tab controller with state.
    final tabIndex = SearchTab.values.indexOf(searchState.selectedTab);
    if (_tabController.index != tabIndex && !_tabController.indexIsChanging) {
      _tabController.animateTo(tabIndex);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          onSubmitted: _onSearchSubmitted,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Search documents, OCR text, tags…',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).clearSearch();
              },
              icon: Icon(
                Icons.close_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
        bottom: searchState.results.isNotEmpty
            ? TabBar(
                controller: _tabController,
                onTap: _onTabChanged,
                tabs: [
                  Tab(text: 'All (${searchState.results.length})'),
                  Tab(
                    text:
                        'Documents (${searchState.results.where((r) => r.type == SearchResultType.document).length})',
                  ),
                  Tab(
                    text:
                        'OCR Text (${searchState.results.where((r) => r.type == SearchResultType.ocrText).length})',
                  ),
                  Tab(
                    text:
                        'Tags (${searchState.results.where((r) => r.type == SearchResultType.tag).length})',
                  ),
                ],
              )
            : null,
      ),
      body: searchState.status == SearchStatus.loading
          ? const LoadingWidget.inline(message: 'Searching…')
          : searchState.query.isEmpty
              ? _buildRecentSearches(searchState)
              : _buildSearchResults(searchState),
    );
  }

  // ── Recent Searches ────────────────────────────────────────────────

  Widget _buildRecentSearches(SearchState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.recentSearches.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_rounded,
        title: 'Search ScanPro',
        subtitle:
            'Find documents by name, OCR text content, or tags. '
            'Start typing to begin your search.',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(searchProvider.notifier).clearRecentSearches();
                },
                child: Text(
                  'Clear All',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.recentSearches.map((query) {
              return ActionChip(
                onPressed: () {
                  _searchController.text = query;
                  ref.read(searchProvider.notifier).search(query);
                },
                avatar: Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                label: Text(query),
                labelStyle: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // ── Search Suggestions ────────────────────────────────────
          Text(
            'Suggestions',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _SuggestionTile(
            icon: Icons.document_scanner_outlined,
            label: 'Scanned documents',
            onTap: () {
              _searchController.text = 'scan';
              ref.read(searchProvider.notifier).search('scan');
            },
          ),
          _SuggestionTile(
            icon: Icons.receipt_long_outlined,
            label: 'Receipts',
            onTap: () {
              _searchController.text = 'receipt';
              ref.read(searchProvider.notifier).search('receipt');
            },
          ),
          _SuggestionTile(
            icon: Icons.text_fields_outlined,
            label: 'Documents with OCR text',
            onTap: () {
              _searchController.text = 'invoice';
              ref.read(searchProvider.notifier).search('invoice');
            },
          ),
        ],
      ),
    );
  }

  // ── Search Results ─────────────────────────────────────────────────

  Widget _buildSearchResults(SearchState state) {
    final filtered = state.filteredResults;

    if (state.status == SearchStatus.loaded && filtered.isEmpty) {
      return EmptySearchState(
        query: state.query,
        onAction: () {
          _searchController.clear();
          ref.read(searchProvider.notifier).clearSearch();
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _SearchResultCard(
          result: filtered[index],
          query: state.query,
          onTap: () => context.push(
            '${AppRoutes.documentDetail}?id=${filtered[index].id}',
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Suggestion Tile
// ═══════════════════════════════════════════════════════════════════

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: colorScheme.primary,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.search_rounded,
        size: 18,
        color: colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: onTap,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Search Result Card
// ═══════════════════════════════════════════════════════════════════

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.result,
    required this.query,
    required this.onTap,
  });

  final SearchResult result;
  final String query;
  final VoidCallback onTap;

  IconData _typeIcon() {
    switch (result.type) {
      case SearchResultType.document:
        return Icons.description_rounded;
      case SearchResultType.ocrText:
        return Icons.text_fields_rounded;
      case SearchResultType.tag:
        return Icons.label_rounded;
      case SearchResultType.folder:
        return Icons.folder_rounded;
    }
  }

  Color _typeColor() {
    switch (result.type) {
      case SearchResultType.document:
        return AppTheme.primaryColor;
      case SearchResultType.ocrText:
        return AppTheme.infoColor;
      case SearchResultType.tag:
        return AppTheme.secondaryColor;
      case SearchResultType.folder:
        return AppTheme.warningColor;
    }
  }

  String _typeLabel() {
    switch (result.type) {
      case SearchResultType.document:
        return 'Document';
      case SearchResultType.ocrText:
        return 'OCR Text';
      case SearchResultType.tag:
        return 'Tag';
      case SearchResultType.folder:
        return 'Folder';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typeColor = _typeColor();

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _typeIcon(),
                  color: typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.matchedText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _typeLabel(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.relativeTime(result.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
