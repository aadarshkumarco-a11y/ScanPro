import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/search/presentation/providers/search_provider.dart';
import 'package:scanpro/features/search/presentation/widgets/search_result_tile.dart';
import 'package:scanpro/features/search/presentation/widgets/search_category_chip.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);
    final suggestions = ref.read(searchProvider.notifier).getSuggestions();
    final hasQuery = searchState.query.isNotEmpty;
    final hasResults = searchState.results.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _buildSearchField(theme),
        actions: [
          if (hasQuery)
            TextButton(
              onPressed: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).updateQuery('');
                _searchFocusNode.requestFocus();
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryChips(theme, searchState),
          Expanded(
            child: searchState.isSearching
                ? _buildLoadingState(theme)
                : !hasQuery
                    ? _buildEmptyState(theme, searchState, suggestions)
                    : hasResults
                        ? _buildResultsList(theme, searchState)
                        : _buildNoResults(theme, searchState.query),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: (value) => ref.read(searchProvider.notifier).updateQuery(value),
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Search files, content, tags...',
        hintStyle: TextStyle(color: theme.colorScheme.outline),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ref.watch(searchProvider).isSearching
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                ),
              )
            : null,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme, SearchState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SearchCategory.values.map((category) {
          final isActive = state.activeCategories.contains(category);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SearchCategoryChip(
              category: category,
              isSelected: isActive,
              onTap: () => ref.read(searchProvider.notifier).toggleCategory(category),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, SearchState state, List<SearchSuggestion> suggestions) {
    final history = state.searchHistory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (history.isNotEmpty) ...[
            _buildSectionHeader(
              theme,
              'Recent Searches',
              onAction: 'Clear All',
              onActionTap: () => ref.read(searchProvider.notifier).clearHistory(),
            ),
            const SizedBox(height: 8),
            ...history.take(5).map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(Icons.history, size: 20, color: theme.colorScheme.onSurfaceVariant),
                  title: Text(item, style: theme.textTheme.bodyMedium),
                  trailing: IconButton(
                    onPressed: () => ref.read(searchProvider.notifier).removeHistoryItem(item),
                    icon: Icon(Icons.close, size: 16, color: theme.colorScheme.outline),
                  ),
                  onTap: () {
                    _searchController.text = item;
                    ref.read(searchProvider.notifier).updateQuery(item);
                  },
                )),
            const SizedBox(height: 16),
          ],
          if (suggestions.isNotEmpty) ...[
            _buildSectionHeader(theme, 'Suggestions'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map((s) => ActionChip(
                    avatar: Icon(s.isHistory ? Icons.history : Icons.trending_up, size: 16),
                    label: Text(s.text),
                    onPressed: () {
                      _searchController.text = s.text;
                      ref.read(searchProvider.notifier).updateQuery(s.text);
                    },
                  )).toList(),
            ),
          ],
          const SizedBox(height: 24),
          _buildSectionHeader(theme, 'Quick Categories'),
          const SizedBox(height: 12),
          _buildQuickCategoryGrid(theme),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, {String? onAction, VoidCallback? onActionTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        if (onAction != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(onAction, style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildQuickCategoryGrid(ThemeData theme) {
    final categories = [
      (Icons.picture_as_pdf, 'PDFs', Colors.red),
      (Icons.description, 'Documents', Colors.blue),
      (Icons.image, 'Images', Colors.green),
      (Icons.label, 'Tagged', Colors.orange),
      (Icons.folder, 'Folders', Colors.amber.shade800),
      (Icons.text_fields, 'OCR Content', Colors.teal),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final (icon, label, color) = categories[index];
        return Card(
          child: InkWell(
            onTap: () {
              _searchController.text = label.toLowerCase();
              ref.read(searchProvider.notifier).updateQuery(label.toLowerCase());
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(label, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsList(ThemeData theme, SearchState state) {
    final grouped = <SearchCategory, List<SearchResult>>{};
    for (final result in state.results) {
      grouped.putIfAbsent(result.category, () => []).add(result);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final category = grouped.keys.elementAt(index);
        final results = grouped[category]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(theme, _categoryLabel(category), onAction: '${results.length} found'),
            const SizedBox(height: 8),
            ...results.map((result) => SearchResultTile(
                  result: result,
                  query: state.query,
                )),
            const SizedBox(height: 16),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms);
      },
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Searching...', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildNoResults(ThemeData theme, String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('No results found', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Try different keywords or filters', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  String _categoryLabel(SearchCategory category) {
    switch (category) {
      case SearchCategory.files:
        return 'Files';
      case SearchCategory.ocrContent:
        return 'OCR Content';
      case SearchCategory.tags:
        return 'Tags';
      case SearchCategory.folders:
        return 'Folders';
    }
  }
}
