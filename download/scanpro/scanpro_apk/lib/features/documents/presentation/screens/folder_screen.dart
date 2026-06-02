import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../scanner/domain/entities/scanned_document.dart';
import '../providers/document_provider.dart';
import '../widgets/document_card.dart';

/// Folder contents view screen.
///
/// Displays all documents within a specific folder, with the
/// folder name in the app bar and support for grid/list toggle.
class FolderScreen extends ConsumerStatefulWidget {
  const FolderScreen({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  final String folderId;
  final String folderName;

  @override
  ConsumerState<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends ConsumerState<FolderScreen> {
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(documentsProvider.notifier).setFolderFilter(widget.folderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final documentsState = ref.watch(documentsProvider);
    final documents = documentsState.documents;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_rounded,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.folderName,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'rename') {
                _showRenameDialog();
              } else if (action == 'delete') {
                _confirmDeleteFolder();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename Folder')),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete Folder',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
      body: documents.isEmpty
          ? const EmptyFolderState()
          : _isGridView
              ? _buildGridView(documents)
              : _buildListView(documents),
    );
  }

  /// Builds the grid layout for documents.
  Widget _buildGridView(List<ScannedDocument> documents) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return DocumentCard(
          document: documents[index],
          isGridView: true,
          onTap: () {},
          onFavoriteToggle: () => ref
              .read(documentsProvider.notifier)
              .toggleFavorite(documents[index].id),
          onDelete: () => ref
              .read(documentsProvider.notifier)
              .moveToTrash(documents[index].id),
        );
      },
    );
  }

  /// Builds the list layout for documents.
  Widget _buildListView(List<ScannedDocument> documents) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return DocumentCard(
          document: documents[index],
          isGridView: false,
          onTap: () {},
          onFavoriteToggle: () => ref
              .read(documentsProvider.notifier)
              .toggleFavorite(documents[index].id),
          onDelete: () => ref
              .read(documentsProvider.notifier)
              .moveToTrash(documents[index].id),
        );
      },
    );
  }

  /// Shows a rename dialog for the folder.
  void _showRenameDialog() {
    final controller = TextEditingController(text: widget.folderName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(documentsProvider.notifier).renameFolder(
                    folderId: widget.folderId,
                    newName: controller.text.trim(),
                  );
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog for deleting the folder.
  void _confirmDeleteFolder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
          'Delete "${widget.folderName}"? Documents inside will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(documentsProvider.notifier).deleteFolder(widget.folderId);
              Navigator.of(this.context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(this.context).colorScheme.error,
              foregroundColor: Theme.of(this.context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Convenience accessor for the primary colour constant.
class AppTheme {
  static const Color primaryColor = Color(0xFF4D2DAB);
}
