/// Main documents screen with grid/list toggle, sort, filter, and search.
///
/// Provides the primary entry point for the Documents feature with
/// pull-to-refresh, view mode toggle, and a FAB to start scanning.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/documents/domain/entities/folder.dart';
import 'package:scanpro/features/documents/presentation/providers/documents_provider.dart';
import 'package:scanpro/features/documents/presentation/widgets/document_grid_view.dart';
import 'package:scanpro/features/documents/presentation/widgets/document_list_view.dart';
import 'package:scanpro/features/documents/presentation/widgets/folder_card.dart';
import 'package:scanpro/features/documents/presentation/widgets/sort_filter_bar.dart';

/// Main documents screen showing all non-deleted documents and folders.
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _isGridView = true;
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentsListProvider);
    final foldersAsync = ref.watch(foldersListProvider);
    final sortFilter = ref.watch(documentSortProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search documents...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => ref
                    .read(documentSortProvider.notifier)
                    .setSearchQuery(value),
              )
            : const Text('Documents'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (_showSearch) return;
              _searchController.clear();
              ref.read(documentSortProvider.notifier).clearSearch();
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Sort & Filter Bar ────────────────────────────
          SortFilterBar(
            sortFilter: sortFilter,
            onSortChanged: (field) =>
                ref.read(documentSortProvider.notifier).setSortField(field),
            onSortDirectionToggled: () =>
                ref.read(documentSortProvider.notifier).toggleSortDirection(),
            onFilterChanged: (filter) =>
                ref.read(documentSortProvider.notifier).setFilter(filter),
          ),

          // ── Folders Section ──────────────────────────────
          if (sortFilter.activeFilter == DocumentFilter.all)
            foldersAsync.when(
              data: (folders) {
                if (folders.isEmpty) return const SizedBox.shrink();
                return _FoldersSection(
                  folders: folders,
                  onFolderTap: (folder) =>
                      context.push('/documents/folder/${folder.id}'),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

          // ── Documents Grid / List ────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(documentsListProvider);
                ref.invalidate(foldersListProvider);
              },
              child: _isGridView
                  ? DocumentGridView(
                      documents: docsAsync,
                      onDocumentTap: (doc) =>
                          context.push('/documents/${doc.id}'),
                      onFavoriteToggle: _onFavoriteToggle,
                    )
                  : DocumentListView(
                      documents: docsAsync,
                      onDocumentTap: (doc) =>
                          context.push('/documents/${doc.id}'),
                      onFavoriteToggle: _onFavoriteToggle,
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/scanner'),
        tooltip: 'Scan document',
        child: const Icon(Icons.document_scanner),
      ),
    );
  }

  void _onFavoriteToggle(ScanDocument doc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(doc.isFavorite
            ? 'Removed from favorites'
            : 'Added to favorites'),
        duration: const Duration(seconds: 1),
      ),
    );
    ref.invalidate(documentsListProvider);
  }
}

// ---------------------------------------------------------------------------
// Folders Section
// ---------------------------------------------------------------------------

class _FoldersSection extends StatelessWidget {
  final List<Folder> folders;
  final ValueChanged<Folder> onFolderTap;

  const _FoldersSection({required this.folders, required this.onFolderTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingMedium,
            Dimensions.spacing12,
            Dimensions.paddingMedium,
            Dimensions.spacing8,
          ),
          child: Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: Dimensions.iconMedium,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: Dimensions.spacing8),
              Text(
                'Folders',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingMedium,
            ),
            itemCount: folders.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: Dimensions.spacing8),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 130,
                child: FolderCard(
                  folder: folders[index],
                  onTap: () => onFolderTap(folders[index]),
                ),
              );
            },
          ),
        ),
        const Divider(height: Dimensions.spacing24),
      ],
    );
  }
}
