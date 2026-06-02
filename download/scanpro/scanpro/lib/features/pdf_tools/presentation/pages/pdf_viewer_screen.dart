import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/pdf_tools/presentation/providers/pdf_provider.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showBookmarks = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final document = ref.watch(currentPdfDocumentProvider);
    final currentPage = ref.watch(pdfViewerPageProvider);
    final zoom = ref.watch(pdfViewerZoomProvider);
    final showThumbnails = ref.watch(pdfShowThumbnailsProvider);
    final theme = Theme.of(context);

    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PDF Viewer')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf_outlined, size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text('No document loaded', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadSampleDocument,
                icon: const Icon(Icons.folder_open),
                label: const Text('Open PDF'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search in PDF...',
                  border: InputBorder.none,
                ),
                style: theme.textTheme.bodyLarge,
                onSubmitted: (value) => _searchInPdf(value),
              )
            : Text(document.name, style: theme.textTheme.titleMedium),
        centerTitle: !_isSearching,
        actions: _buildAppBarActions(theme),
      ),
      body: Row(
        children: [
          if (showThumbnails) _buildThumbnailSidebar(theme, document),
          Expanded(child: _buildPdfView(theme, document, currentPage)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme, document, currentPage),
    );
  }

  List<Widget> _buildAppBarActions(ThemeData theme) {
    return [
      IconButton(
        onPressed: () => setState(() => _isSearching = !_isSearching),
        icon: Icon(_isSearching ? Icons.close : Icons.search),
        tooltip: _isSearching ? 'Close search' : 'Search',
      ),
      IconButton(
        onPressed: () => setState(() => _showBookmarks = !_showBookmarks),
        icon: Icon(_showBookmarks ? Icons.bookmark : Icons.bookmark_outline),
        tooltip: 'Bookmarks',
      ),
      IconButton(
        onPressed: _shareDocument,
        icon: const Icon(Icons.share_outlined),
        tooltip: 'Share',
      ),
      PopupMenuButton<String>(
        onSelected: _handleMenuAction,
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'annotate', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Annotate'))),
          const PopupMenuItem(value: 'sign', child: ListTile(leading: Icon(Icons.draw_outlined), title: Text('Sign'))),
          const PopupMenuItem(value: 'print', child: ListTile(leading: Icon(Icons.print_outlined), title: Text('Print'))),
        ],
      ),
    ];
  }

  Widget _buildThumbnailSidebar(ThemeData theme, PdfDocument document) {
    return Container(
      width: 80,
      color: theme.colorScheme.surfaceContainerLow,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: document.pageCount,
        itemBuilder: (context, index) {
          final page = index + 1;
          final isSelected = page == ref.watch(pdfViewerPageProvider);
          return GestureDetector(
            onTap: () => ref.read(pdfViewerPageProvider.notifier).state = page,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? const Color(0xFF4D2DAB) : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 0.707,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text('$page', style: theme.textTheme.labelSmall),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('$page', style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPdfView(ThemeData theme, PdfDocument document, int currentPage) {
    return GestureDetector(
      onDoubleTap: () {
        final newZoom = ref.read(pdfViewerZoomProvider) == 1.0 ? 2.0 : 1.0;
        ref.read(pdfViewerZoomProvider.notifier).state = newZoom;
      },
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: AnimatedScale(
              scale: ref.watch(pdfViewerZoomProvider),
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 300,
                height: 424,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 8),
                      Text('Page $currentPage', style: theme.textTheme.titleMedium),
                      Text('of ${document.pageCount}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, PdfDocument document, int currentPage) {
    return SafeArea(
      child: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: currentPage > 1
                  ? () => ref.read(pdfViewerPageProvider.notifier).state = currentPage - 1
                  : null,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous page',
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  child: Text('$currentPage', textAlign: TextAlign.center, style: theme.textTheme.titleSmall),
                ),
                Text(' / ${document.pageCount}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            IconButton(
              onPressed: currentPage < document.pageCount
                  ? () => ref.read(pdfViewerPageProvider.notifier).state = currentPage + 1
                  : null,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next page',
            ),
            const VerticalDivider(width: 1),
            IconButton(
              onPressed: () => ref.read(pdfShowThumbnailsProvider.notifier).state = !ref.read(pdfShowThumbnailsProvider),
              icon: Icon(
                ref.watch(pdfShowThumbnailsProvider) ? Icons.view_sidebar : Icons.view_sidebar_outlined,
                color: ref.watch(pdfShowThumbnailsProvider) ? const Color(0xFF4D2DAB) : null,
              ),
              tooltip: 'Toggle thumbnails',
            ),
          ],
        ),
      ),
    );
  }

  void _loadSampleDocument() {
    final doc = PdfDocument(
      id: 'sample-1',
      name: 'Sample Document.pdf',
      path: '/storage/documents/sample.pdf',
      pageCount: 12,
      fileSizeBytes: 2457600,
      lastModified: DateTime.now(),
    );
    ref.read(currentPdfDocumentProvider.notifier).state = doc;
  }

  void _searchInPdf(String query) {
    if (query.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for "$query"...'), behavior: SnackBarBehavior.floating),
    );
  }

  void _shareDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing PDF...'), behavior: SnackBarBehavior.floating),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'annotate':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening annotation tools...'), behavior: SnackBarBehavior.floating),
        );
        break;
      case 'sign':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening signature pad...'), behavior: SnackBarBehavior.floating),
        );
        break;
      case 'print':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preparing to print...'), behavior: SnackBarBehavior.floating),
        );
        break;
    }
  }
}
