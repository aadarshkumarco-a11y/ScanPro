import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/pdf_tools/presentation/providers/pdf_provider.dart';
import 'package:scanpro/features/pdf_tools/presentation/widgets/page_range_input.dart';
import 'package:scanpro/features/pdf_tools/presentation/widgets/pdf_thumbnail.dart';

class PdfSplitScreen extends ConsumerStatefulWidget {
  const PdfSplitScreen({super.key});

  @override
  ConsumerState<PdfSplitScreen> createState() => _PdfSplitScreenState();
}

class _PdfSplitScreenState extends ConsumerState<PdfSplitScreen> {
  final _rangeController = TextEditingController();
  SplitMode _splitMode = SplitMode.byRange;
  int _everyNPages = 1;
  final Set<int> _selectedExtractPages = {};

  @override
  void dispose() {
    _rangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splitState = ref.watch(pdfSplitProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split PDF'),
        centerTitle: true,
      ),
      body: splitState.document == null
          ? _buildDocumentPicker(theme)
          : _buildSplitContent(theme, splitState),
      bottomNavigationBar: splitState.document != null ? _buildSplitButton(theme, splitState) : null,
    );
  }

  Widget _buildDocumentPicker(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call_split, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('Select a PDF to split', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Choose a document and specify how to split it', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadSampleDocument,
            icon: const Icon(Icons.folder_open),
            label: const Text('Select PDF'),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildSplitContent(ThemeData theme, PdfSplitState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentInfo(theme, state.document!),
          const SizedBox(height: 20),
          _buildSplitModeSelector(theme, state),
          const SizedBox(height: 20),
          _buildSplitModeContent(theme, state),
          if (state.splitOptions.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSplitOptionsList(theme, state),
          ],
          const SizedBox(height: 20),
          _buildPageThumbnails(theme, state),
        ],
      ),
    );
  }

  Widget _buildDocumentInfo(ThemeData theme, PdfDocument doc) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
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
            IconButton(
              onPressed: () => ref.read(pdfSplitProvider.notifier).state = const PdfSplitState(),
              icon: Icon(Icons.close, size: 20, color: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSplitModeSelector(ThemeData theme, PdfSplitState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Split Mode', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        SegmentedButton<SplitMode>(
          segments: const [
            ButtonSegment(value: SplitMode.byRange, label: Text('By Range'), icon: Icon(Icons.format_list_numbered, size: 16)),
            ButtonSegment(value: SplitMode.everyN, label: Text('Every N'), icon: Icon(Icons.repeat, size: 16)),
            ButtonSegment(value: SplitMode.extract, label: Text('Extract'), icon: Icon(Icons.content_copy, size: 16)),
          ],
          selected: {_splitMode},
          onSelectionChanged: (modes) => setState(() => _splitMode = modes.first),
        ),
      ],
    );
  }

  Widget _buildSplitModeContent(ThemeData theme, PdfSplitState state) {
    switch (_splitMode) {
      case SplitMode.byRange:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageRangeInput(
              controller: _rangeController,
              maxPages: state.document!.pageCount,
              onSubmitted: _addRangeSplit,
            ),
            const SizedBox(height: 8),
            Text(
              'Example: 1-3, 5, 7-9',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        );
      case SplitMode.everyN:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Split every N pages', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.outlined(
                  onPressed: _everyNPages > 1 ? () => setState(() => _everyNPages--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  width: 64,
                  alignment: Alignment.center,
                  child: Text('$_everyNPages', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
                IconButton.outlined(
                  onPressed: _everyNPages < state.document!.pageCount ? () => setState(() => _everyNPages++) : null,
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _addEveryNSplit(state.document!.pageCount),
                    child: const Text('Add Split'),
                  ),
                ),
              ],
            ),
          ],
        );
      case SplitMode.extract:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tap pages to select for extraction', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            if (_selectedExtractPages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FilledButton.tonal(
                  onPressed: _addExtractSplit,
                  child: Text('Extract ${_selectedExtractPages.length} selected pages'),
                ),
              ),
          ],
        );
    }
  }

  Widget _buildSplitOptionsList(ThemeData theme, PdfSplitState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Split Options (${state.splitOptions.length})', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            TextButton(
              onPressed: () => ref.read(pdfSplitProvider.notifier).state = state.copyWith(splitOptions: []),
              child: const Text('Clear All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...state.splitOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF4D2DAB).withOpacity(0.1),
                child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF4D2DAB), fontSize: 12)),
              ),
              title: Text(option.name),
              subtitle: Text(option.pageRanges.map((r) => r.length == 1 ? '${r.first}' : '${r.first}-${r.last}').join(', ')),
              trailing: IconButton(
                onPressed: () => ref.read(pdfSplitProvider.notifier).removeSplitOption(index),
                icon: Icon(Icons.close, size: 18, color: theme.colorScheme.error),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPageThumbnails(ThemeData theme, PdfSplitState state) {
    if (state.document == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pages', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemCount: state.document!.pageCount,
          itemBuilder: (context, index) {
            final page = index + 1;
            final isSelected = _splitMode == SplitMode.extract && _selectedExtractPages.contains(page);
            return GestureDetector(
              onTap: _splitMode == SplitMode.extract ? () => _toggleExtractPage(page) : null,
              child: PdfThumbnail(
                pageNumber: page,
                isSelected: isSelected,
                isSelectable: _splitMode == SplitMode.extract,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSplitButton(ThemeData theme, PdfSplitState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.isSplitting) _buildProgressBar(theme, state.progress),
            FilledButton.icon(
              onPressed: state.splitOptions.isNotEmpty && !state.isSplitting ? _splitDocument : null,
              icon: state.isSplitting
                  ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                  : const Icon(Icons.call_split, size: 18),
              label: Text(state.isSplitting ? 'Splitting...' : 'Split into ${state.splitOptions.length} file${state.splitOptions.length == 1 ? '' : 's'}'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)),
              const SizedBox(width: 12),
              Text('Splitting...', style: theme.textTheme.bodyMedium),
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

  void _loadSampleDocument() {
    final doc = PdfDocument(
      id: 'split-sample',
      name: 'Report_2025.pdf',
      path: '/storage/documents/report_2025.pdf',
      pageCount: 15,
      fileSizeBytes: 3200000,
      lastModified: DateTime.now(),
    );
    ref.read(pdfSplitProvider.notifier).setDocument(doc);
  }

  void _addRangeSplit() {
    final text = _rangeController.text.trim();
    if (text.isEmpty) return;
    final ranges = _parsePageRanges(text);
    if (ranges.isEmpty) return;
    ref.read(pdfSplitProvider.notifier).addSplitOption('Split_${ref.read(pdfSplitProvider).splitOptions.length + 1}', ranges);
    _rangeController.clear();
  }

  void _addEveryNSplit(int totalPages) {
    final ranges = <List<int>>[];
    for (int i = 1; i <= totalPages; i += _everyNPages) {
      final end = (i + _everyNPages - 1).clamp(1, totalPages);
      ranges.add(List.generate(end - i + 1, (j) => i + j));
    }
    ref.read(pdfSplitProvider.notifier).addSplitOption('Every_${_everyNPages}_pages', ranges);
  }

  void _addExtractSplit() {
    if (_selectedExtractPages.isEmpty) return;
    final sorted = _selectedExtractPages.toList()..sort();
    ref.read(pdfSplitProvider.notifier).addSplitOption('Extracted_pages', [sorted]);
    setState(() => _selectedExtractPages.clear());
  }

  void _toggleExtractPage(int page) {
    setState(() {
      if (_selectedExtractPages.contains(page)) {
        _selectedExtractPages.remove(page);
      } else {
        _selectedExtractPages.add(page);
      }
    });
  }

  List<List<int>> _parsePageRanges(String input) {
    final ranges = <List<int>>[];
    try {
      for (final part in input.split(',')) {
        final trimmed = part.trim();
        if (trimmed.contains('-')) {
          final bounds = trimmed.split('-');
          final start = int.parse(bounds[0].trim());
          final end = int.parse(bounds[1].trim());
          ranges.add(List.generate(end - start + 1, (i) => start + i));
        } else {
          ranges.add([int.parse(trimmed)]);
        }
      }
    } catch (_) {
      return [];
    }
    return ranges;
  }

  Future<void> _splitDocument() async {
    final results = await ref.read(pdfSplitProvider.notifier).split();
    if (results.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Split into ${results.length} files!'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'Open', onPressed: () {}),
        ),
      );
    }
  }
}

enum SplitMode { byRange, everyN, extract }
