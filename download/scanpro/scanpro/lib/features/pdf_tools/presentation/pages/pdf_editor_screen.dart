import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/pdf_tools/presentation/providers/pdf_provider.dart';
import 'package:scanpro/features/pdf_tools/presentation/widgets/pdf_thumbnail.dart';

class PdfEditorScreen extends ConsumerStatefulWidget {
  const PdfEditorScreen({super.key});

  @override
  ConsumerState<PdfEditorScreen> createState() => _PdfEditorScreenState();
}

class _PdfEditorScreenState extends ConsumerState<PdfEditorScreen> {
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final pageState = ref.watch(pdfPageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(pageState.document?.name ?? 'Page Editor'),
        centerTitle: true,
        actions: [
          if (pageState.selectedPages.isNotEmpty) ...[
            IconButton(
              onPressed: () => ref.read(pdfPageProvider.notifier).rotateSelected(),
              icon: const Icon(Icons.rotate_right_outlined),
              tooltip: 'Rotate selected',
            ),
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete selected',
            ),
          ],
          IconButton(
            onPressed: () => setState(() => _isSelectionMode = !_isSelectionMode),
            icon: Icon(_isSelectionMode ? Icons.check_circle : Icons.checklist),
            tooltip: _isSelectionMode ? 'Done' : 'Select pages',
          ),
          if (pageState.hasUnsavedChanges)
            TextButton(
              onPressed: _saveChanges,
              child: const Text('Save'),
            ),
        ],
      ),
      body: pageState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : pageState.document == null
              ? _buildEmptyState(theme)
              : _buildPageGrid(theme, pageState),
      bottomNavigationBar: pageState.document != null ? _buildBottomBar(theme, pageState) : null,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_document, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('No document loaded', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Open a PDF to start editing pages', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadSampleDocument,
            icon: const Icon(Icons.folder_open),
            label: const Text('Open PDF'),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildPageGrid(ThemeData theme, PdfPageState pageState) {
    return Column(
      children: [
        if (_isSelectionMode && pageState.selectedPages.isNotEmpty)
          _buildSelectionBar(theme, pageState),
        Expanded(
          child: ReorderableGridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.707,
            ),
            itemCount: pageState.pages.length,
            onReorder: (oldIndex, newIndex) => ref.read(pdfPageProvider.notifier).reorderPages(oldIndex, newIndex),
            itemBuilder: (context, index) {
              final pageInfo = pageState.pages[index];
              final isSelected = pageState.selectedPages.contains(pageInfo.pageNumber);

              return GestureDetector(
                key: ValueKey('page_${pageInfo.pageNumber}_$index'),
                onTap: _isSelectionMode
                    ? () => ref.read(pdfPageProvider.notifier).togglePageSelection(pageInfo.pageNumber)
                    : null,
                onLongPress: () {
                  setState(() => _isSelectionMode = true);
                  ref.read(pdfPageProvider.notifier).togglePageSelection(pageInfo.pageNumber);
                },
                child: PdfThumbnail(
                  pageNumber: pageInfo.pageNumber,
                  isSelected: isSelected,
                  isSelectable: _isSelectionMode,
                  rotation: pageInfo.rotation,
                  showDragHandle: !_isSelectionMode,
                ),
              ).animate().fadeIn(duration: 200.ms, delay: (index * 30).ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionBar(ThemeData theme, PdfPageState pageState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4D2DAB).withOpacity(0.1),
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Text(
            '${pageState.selectedPages.length} selected',
            style: theme.textTheme.titleSmall?.copyWith(color: const Color(0xFF4D2DAB)),
          ),
          const Spacer(),
          TextButton(
            onPressed: pageState.selectedPages.length == pageState.pages.length
                ? () => ref.read(pdfPageProvider.notifier).clearSelection()
                : () => ref.read(pdfPageProvider.notifier).selectAll(),
            child: Text(pageState.selectedPages.length == pageState.pages.length ? 'Deselect All' : 'Select All'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, PdfPageState pageState) {
    return SafeArea(
      child: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.rotate_right_outlined,
              label: 'Rotate',
              onTap: pageState.selectedPages.isNotEmpty
                  ? () => ref.read(pdfPageProvider.notifier).rotateSelected()
                  : null,
            ),
            _buildActionButton(
              icon: Icons.delete_outline,
              label: 'Delete',
              onTap: pageState.selectedPages.isNotEmpty ? _confirmDelete : null,
              color: theme.colorScheme.error,
            ),
            _buildActionButton(
              icon: Icons.add_page,
              label: 'Insert',
              onTap: _insertPage,
            ),
            _buildActionButton(
              icon: Icons.swap_horiz,
              label: 'Replace',
              onTap: _replacePage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: color),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  void _loadSampleDocument() {
    final doc = PdfDocument(
      id: 'editor-sample',
      name: 'Editable_Document.pdf',
      path: '/storage/documents/editable.pdf',
      pageCount: 10,
      fileSizeBytes: 4200000,
      lastModified: DateTime.now(),
    );
    ref.read(pdfPageProvider.notifier).loadDocument(doc);
  }

  void _confirmDelete() {
    final count = ref.read(pdfPageProvider).selectedPages.length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pages'),
        content: Text('Are you sure you want to delete $count page${count == 1 ? '' : 's'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(pdfPageProvider.notifier).deleteSelected();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _insertPage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Insert page: select image or PDF'), behavior: SnackBarBehavior.floating),
    );
  }

  void _replacePage() {
    if (ref.read(pdfPageProvider).selectedPages.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select exactly one page to replace'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Replace page: select replacement'), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _saveChanges() async {
    final success = await ref.read(pdfPageProvider.notifier).saveChanges();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved!'), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
