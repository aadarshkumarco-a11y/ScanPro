import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart' as app_error;
import '../../../../core/widgets/loading_widget.dart';
import '../../../../di/app_module.dart';
import '../../domain/entities/document_folder.dart';
import '../../domain/entities/document_tag.dart';
import '../../../scanner/domain/entities/scanned_document.dart';
import '../providers/document_provider.dart';
import '../widgets/document_card.dart';
import '../widgets/folder_chip.dart';

/// Document list/grid view with search, sort, filter, and folder navigation.
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(documentsProvider.notifier).loadDocuments();
      ref.read(documentsProvider.notifier).loadFolders();
      ref.read(documentsProvider.notifier).loadTags();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final documentsState = ref.watch(documentsProvider);
    final isGridView = ref.watch(isGridViewProvider);
    final sortFilterState = ref.watch(sortFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search documents…',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                onChanged: (query) {
                  ref.read(sortFilterProvider.notifier).setSearchQuery(query);
                },
              )
            : Text(
                'Documents',
                style: theme.appBarTheme.titleTextStyle,
              ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                _searchController.clear();
                ref.read(sortFilterProvider.notifier).setSearchQuery('');
              }
            },
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {
              ref.read(isGridViewProvider.notifier).state = !isGridView;
            },
            icon: Icon(
              isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (value) {
              final sortField = DocumentSortField.values.firstWhere(
                (e) => e.name == value,
                orElse: () => DocumentSortField.date,
              );
              ref.read(sortFilterProvider.notifier).setSortField(sortField);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'size', child: Text('Sort by Size')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () async {
          await ref.read(documentsProvider.notifier).loadDocuments();
          await ref.read(documentsProvider.notifier).loadFolders();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Folders row ──────────────────────────────────────────
            if (documentsState.folders.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildFolderRow(
                  context,
                  colorScheme,
                  documentsState.folders,
                ),
              ),

            // ── Tags filter row ──────────────────────────────────────
            if (documentsState.tags.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildTagRow(context, colorScheme, documentsState.tags),
              ),

            // ── Document content ─────────────────────────────────────
            _buildDocumentContent(
              context,
              theme,
              colorScheme,
              documentsState,
              isGridView,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.scanner),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.document_scanner_rounded, size: 22),
        label: const Text(
          'Scan',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  /// Builds the horizontal scrollable folder row.
  Widget _buildFolderRow(
    BuildContext context,
    ColorScheme colorScheme,
    List<DocumentFolder> folders,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Folders',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: folders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final folder = folders[index];
                final isSelected =
                    ref.watch(documentsProvider).selectedFolderId == folder.id;
                return FolderChip(
                  folder: folder,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(documentsProvider.notifier).setFolderFilter(
                          isSelected ? null : folder.id,
                        );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the horizontal scrollable tag filter row.
  Widget _buildTagRow(
    BuildContext context,
    ColorScheme colorScheme,
    List<DocumentTag> tags,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: tags.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final tag = tags[index];
            final isSelected =
                ref.watch(documentsProvider).selectedTag == tag.name;
            return ChoiceChip(
              label: Text(tag.name),
              selected: isSelected,
              onSelected: (_) {
                ref.read(documentsProvider.notifier).setTagFilter(
                      isSelected ? null : tag.name,
                    );
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the main document content area (loading, error, empty, or list).
  Widget _buildDocumentContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    DocumentsState documentsState,
    bool isGridView,
  ) {
    if (documentsState.status == DocumentsStatus.loading) {
      return const SliverFillRemaining(
        child: LoadingWidget.inline(message: 'Loading documents…'),
      );
    }

    if (documentsState.status == DocumentsStatus.error) {
      return SliverFillRemaining(
        child: app_error.AppErrorWidget(
          message: documentsState.errorMessage ?? 'Unknown error',
          onRetry: () => ref.read(documentsProvider.notifier).loadDocuments(),
        ),
      );
    }

    final documents = _applySortAndFilter(
      documentsState.documents,
      ref.read(sortFilterProvider),
    );

    if (documents.isEmpty) {
      return SliverFillRemaining(
        child: EmptyDocumentsState(
          onAction: () => context.go(AppRoutes.scanner),
        ),
      );
    }

    if (isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => DocumentCard(
              document: documents[index],
              isGridView: true,
              onTap: () => _navigateToDetail(documents[index].id),
              onFavoriteToggle: () => ref
                  .read(documentsProvider.notifier)
                  .toggleFavorite(documents[index].id),
              onDelete: () => ref
                  .read(documentsProvider.notifier)
                  .moveToTrash(documents[index].id),
            ),
            childCount: documents.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DocumentCard(
              document: documents[index],
              isGridView: false,
              onTap: () => _navigateToDetail(documents[index].id),
              onFavoriteToggle: () => ref
                  .read(documentsProvider.notifier)
                  .toggleFavorite(documents[index].id),
              onDelete: () => ref
                  .read(documentsProvider.notifier)
                  .moveToTrash(documents[index].id),
            ),
          ),
          childCount: documents.length,
        ),
      ),
    );
  }

  /// Applies current sort and filter state to the document list.
  List<ScannedDocument> _applySortAndFilter(
    List<ScannedDocument> documents,
    SortFilterState sortFilter,
  ) {
    var filtered = documents;

    // Search filter
    if (sortFilter.searchQuery.isNotEmpty) {
      final query = sortFilter.searchQuery.toLowerCase();
      filtered = filtered.where((d) {
        return d.name.toLowerCase().contains(query) ||
            (d.ocrText?.toLowerCase().contains(query) ?? false) ||
            d.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    // Category filter
    switch (sortFilter.filter) {
      case DocumentFilter.favorites:
        filtered = filtered.where((d) => d.isFavorite).toList();
        break;
      case DocumentFilter.pdf:
        filtered = filtered
            .where((d) => d.pdfPath != null || FileUtils.isPdf(d.filePath))
            .toList();
        break;
      case DocumentFilter.image:
        filtered = filtered
            .where((d) => FileUtils.isImage(d.filePath))
            .toList();
        break;
      case DocumentFilter.ocr:
        filtered = filtered.where((d) => d.ocrText != null).toList();
        break;
      case DocumentFilter.all:
        break;
    }

    // Sort
    switch (sortFilter.sortField) {
      case DocumentSortField.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case DocumentSortField.date:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case DocumentSortField.size:
        filtered.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
      case DocumentSortField.category:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    if (sortFilter.sortOrder == SortOrder.ascending) {
      filtered = filtered.reversed.toList();
    }

    return filtered;
  }

  /// Navigates to the document detail screen.
  void _navigateToDetail(String documentId) {
    context.go(
      '${AppRoutes.documentDetail}?id=$documentId',
    );
  }
}

/// Convenience accessor for AppTheme.
class AppTheme {
  static const Color primaryColor = Color(0xFF4D2DAB);
}
