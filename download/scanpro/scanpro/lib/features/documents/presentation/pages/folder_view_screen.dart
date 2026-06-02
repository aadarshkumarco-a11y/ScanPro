/// Folder view screen showing folder contents with sort/filter options.
///
/// Displays folder header with name, color, and document count,
/// then a grid or list of documents inside the folder,
/// plus a create subfolder button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanpro/core/theme/color_schemes.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/core/widgets/empty_state.dart';
import 'package:scanpro/core/widgets/loading_widget.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/documents/domain/entities/folder.dart';
import 'package:scanpro/features/documents/presentation/providers/documents_provider.dart';
import 'package:scanpro/features/documents/presentation/widgets/document_card.dart';
import 'package:scanpro/features/documents/presentation/widgets/sort_filter_bar.dart';

/// Screen displaying the contents of a specific folder.
class FolderViewScreen extends ConsumerStatefulWidget {
  final String folderId;

  const FolderViewScreen({super.key, required this.folderId});

  @override
  ConsumerState<FolderViewScreen> createState() => _FolderViewScreenState();
}

class _FolderViewScreenState extends ConsumerState<FolderViewScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(foldersListProvider);
    final docsAsync = ref.watch(documentsListProvider);
    final sortFilter = ref.watch(documentSortProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return foldersAsync.when(
      loading: () => const Scaffold(
        body: LoadingWidget(message: 'Loading folder...'),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(child: Text(error.toString())),
      ),
      data: (folders) {
        final folder = folders.where((f) => f.id == widget.folderId).firstOrNull;
        if (folder == null) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const EmptyState(
              icon: Icons.folder_off_outlined,
              title: 'Folder Not Found',
              subtitle: 'This folder may have been deleted',
            ),
          );
        }
        return _buildContent(context, folder, docsAsync, sortFilter);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    Folder folder,
    AsyncValue<List<ScanDocument>> docsAsync,
    SortFilterState sortFilter,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final folderColor = _parseColor(folder.color);
    final folderDocs = docsAsync.whenOrNull< List<ScanDocument>>(
      data: (docs) => docs.where((d) => d.folderId == folder.id).toList(),
    ) ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(folder.name),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Folder Header ────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingMedium),
            color: folderColor.withValues(alpha: 0.08),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: folderColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    color: folderColor,
                    size: Dimensions.iconLarge,
                  ),
                ),
                const SizedBox(width: Dimensions.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${folder.documentCount} document${folder.documentCount != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sort & Filter ────────────────────────────────
          SortFilterBar(
            sortFilter: sortFilter,
            onSortChanged: (field) =>
                ref.read(documentSortProvider.notifier).setSortField(field),
            onSortDirectionToggled: () =>
                ref.read(documentSortProvider.notifier).toggleSortDirection(),
            onFilterChanged: (filter) =>
                ref.read(documentSortProvider.notifier).setFilter(filter),
          ),

          // ── Create Subfolder ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingMedium,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  // Placeholder: create subfolder dialog
                },
                icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                label: const Text('Create Subfolder'),
              ),
            ),
          ),

          // ── Documents List / Grid ────────────────────────
          Expanded(
            child: folderDocs.isEmpty
                ? const EmptyState(
                    icon: Icons.folder_open_outlined,
                    title: 'Empty Folder',
                    subtitle: 'Scan or move documents into this folder',
                  )
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.all(Dimensions.paddingSmall),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: Dimensions.spacing8,
                          mainAxisSpacing: Dimensions.spacing8,
                        ),
                        itemCount: folderDocs.length,
                        itemBuilder: (context, index) {
                          final doc = folderDocs[index];
                          return DocumentCard(
                            document: doc,
                            onTap: () =>
                                context.push('/documents/${doc.id}'),
                            onFavoriteToggle: () {
                              ref.invalidate(documentsListProvider);
                            },
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(Dimensions.paddingSmall),
                        itemCount: folderDocs.length,
                        itemBuilder: (context, index) {
                          final doc = folderDocs[index];
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                doc.pdfPath != null
                                    ? Icons.picture_as_pdf_outlined
                                    : Icons.image_outlined,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              title: Text(doc.title),
                              subtitle: Text(
                                _formatDate(doc.updatedAt),
                              ),
                              onTap: () =>
                                  context.push('/documents/${doc.id}'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final code = hex.replaceFirst('#', '');
      return Color(int.parse('FF$code', radix: 16));
    } catch (_) {
      return AppColors.scannerAccent;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
