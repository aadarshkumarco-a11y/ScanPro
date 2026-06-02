import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/pdf_tools/presentation/providers/pdf_provider.dart';

class PdfMergeScreen extends ConsumerStatefulWidget {
  const PdfMergeScreen({super.key});

  @override
  ConsumerState<PdfMergeScreen> createState() => _PdfMergeScreenState();
}

class _PdfMergeScreenState extends ConsumerState<PdfMergeScreen> {
  bool _showPreview = false;

  @override
  Widget build(BuildContext context) {
    final mergeState = ref.watch(pdfMergeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge PDFs'),
        centerTitle: true,
        actions: [
          if (mergeState.documents.isNotEmpty)
            IconButton(
              onPressed: () => _showMergePreview(mergeState),
              icon: const Icon(Icons.preview_outlined),
              tooltip: 'Preview',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(theme, mergeState),
          Expanded(child: _buildDocumentList(theme, mergeState)),
          if (mergeState.isMerging) _buildProgressBar(theme, mergeState.progress),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(theme, mergeState),
    );
  }

  Widget _buildHeader(ThemeData theme, PdfMergeState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4D2DAB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.merge_type, color: Color(0xFF4D2DAB)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Merge Documents', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '${state.documents.length} document${state.documents.length == 1 ? '' : 's'} selected • ${_totalPages(state)} total pages',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildDocumentList(ThemeData theme, PdfMergeState state) {
    if (state.documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf_outlined, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('No documents selected', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Add PDFs to merge them together', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _addDocument,
              icon: const Icon(Icons.add),
              label: const Text('Add PDFs'),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.documents.length,
      onReorder: (oldIndex, newIndex) => ref.read(pdfMergeProvider.notifier).reorderDocuments(oldIndex, newIndex),
      proxyDecorator: (child, index, animation) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(animation.value);
          return Transform.scale(scale: 1.02 + 0.03 * t, child: child);
        },
        child: child,
      ),
      itemBuilder: (context, index) {
        final doc = state.documents[index];
        return _buildDocumentCard(theme, doc, index)
            .animate()
            .fadeIn(duration: 200.ms, delay: (index * 50).ms)
            .slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildDocumentCard(ThemeData theme, PdfDocument doc, int index) {
    return Card(
      key: ValueKey('merge_doc_${doc.id}_$index'),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_indicator, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${doc.pageCount} pages • ${doc.fileSize}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4D2DAB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('#${index + 1}', style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF4D2DAB), fontWeight: FontWeight.bold)),
            ),
            IconButton(
              onPressed: () => ref.read(pdfMergeProvider.notifier).removeDocument(index),
              icon: Icon(Icons.close, size: 20, color: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, double progress) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)),
              const SizedBox(width: 12),
              Text('Merging PDFs...', style: theme.textTheme.bodyMedium),
              const Spacer(),
              Text('${(progress * 100).toInt()}%', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, backgroundColor: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(4)),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme, PdfMergeState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: state.isMerging ? null : _addDocument,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add More'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: state.documents.length >= 2 && !state.isMerging ? _mergeDocuments : null,
                icon: state.isMerging
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                    : const Icon(Icons.merge_type, size: 18),
                label: Text(state.isMerging ? 'Merging...' : 'Merge ${state.documents.length} PDFs'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _totalPages(PdfMergeState state) => state.documents.fold(0, (sum, doc) => sum + doc.pageCount);

  void _addDocument() {
    final doc = PdfDocument(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Document_${ref.read(pdfMergeProvider).documents.length + 1}.pdf',
      path: '/storage/documents/doc_${DateTime.now().millisecondsSinceEpoch}.pdf',
      pageCount: (3 + (DateTime.now().millisecond % 15)),
      fileSizeBytes: (500000 + (DateTime.now().millisecond % 3000000)),
      lastModified: DateTime.now(),
    );
    ref.read(pdfMergeProvider.notifier).addDocument(doc);
  }

  Future<void> _mergeDocuments() async {
    final result = await ref.read(pdfMergeProvider.notifier).merge();
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDFs merged successfully!'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'Open', onPressed: () {}),
        ),
      );
    }
  }

  void _showMergePreview(PdfMergeState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Merge Preview', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.all(16),
                itemCount: state.documents.length,
                itemBuilder: (context, index) {
                  final doc = state.documents[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4D2DAB).withOpacity(0.1),
                      child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF4D2DAB))),
                    ),
                    title: Text(doc.name),
                    subtitle: Text('${doc.pageCount} pages'),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Total: ${_totalPages(state)} pages',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: const Color(0xFF4D2DAB)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
