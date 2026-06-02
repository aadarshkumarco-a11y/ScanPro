import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/ocr/presentation/providers/ocr_provider.dart';

class OcrScreen extends ConsumerStatefulWidget {
  const OcrScreen({super.key});

  @override
  ConsumerState<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends ConsumerState<OcrScreen> {
  String? _selectedDocumentPath;
  bool _showLanguageSheet = false;

  static const _languages = {
    'eng': 'English',
    'hin': 'Hindi',
    'spa': 'Spanish',
    'fra': 'French',
    'deu': 'German',
    'jpn': 'Japanese',
    'kor': 'Korean',
    'zho': 'Chinese (Simplified)',
    'ara': 'Arabic',
    'por': 'Portuguese',
  };

  @override
  Widget build(BuildContext context) {
    final processingState = ref.watch(ocrProcessingProvider);
    final selectedLang = ref.watch(ocrSelectedLanguageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Text Recognition'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDocumentSelector(context, theme)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 20),
            _buildLanguageSelector(context, theme, selectedLang)
                .animate()
                .fadeIn(duration: 300.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),
            if (processingState.isProcessing) ...[
              _buildProcessingIndicator(theme, processingState.progress)
                  .animate()
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 24),
            ],
            const Spacer(),
            _buildStartButton(context, theme, processingState)
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            _buildRecentHistory(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentSelector(BuildContext context, ThemeData theme) {
    final hasDocument = _selectedDocumentPath != null;

    return GestureDetector(
      onTap: _pickDocument,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 200,
        decoration: BoxDecoration(
          color: hasDocument ? theme.colorScheme.primaryContainer.withOpacity(0.3) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDocument ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: hasDocument
            ? Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 48, color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        Text('Document Selected', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                        const SizedBox(height: 4),
                        Text(_selectedDocumentPath!.split('/').last, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filledTonal(
                      onPressed: () => setState(() => _selectedDocumentPath = null),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text('Select Document or Scan', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('Tap to choose from gallery or camera', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, ThemeData theme, String selectedLang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('OCR Language', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showLanguagePicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.language),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _languages[selectedLang] ?? 'English',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingIndicator(ThemeData theme, double progress) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Extracting Text...', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('${(progress * 100).toInt()}%', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
          ],
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context, ThemeData theme, OcrProcessingState state) {
    final isReady = _selectedDocumentPath != null && !state.isProcessing;

    return FilledButton.icon(
      onPressed: isReady ? _startOcr : null,
      icon: state.isProcessing
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
            )
          : const Icon(Icons.text_fields),
      label: Text(state.isProcessing ? 'Processing...' : 'Start OCR'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context, ThemeData theme) {
    final history = ref.watch(ocrHistoryProvider);
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent OCR', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/ocr/history'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: history.length > 5 ? 5 : history.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                child: InkWell(
                  onTap: () {
                    ref.read(ocrResultProvider.notifier).state = item;
                    Navigator.pushNamed(context, '/ocr/result', arguments: item);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.extractedText.split('\n').first,
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(item.confidence * 100).toInt()}% confidence',
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickDocument() async {
    // Simulate document selection
    setState(() {
      _selectedDocumentPath = '/storage/documents/scan_${DateTime.now().millisecondsSinceEpoch}.pdf';
    });
  }

  Future<void> _startOcr() async {
    if (_selectedDocumentPath == null) return;
    final lang = ref.read(ocrSelectedLanguageProvider);
    final result = await ref.read(ocrProcessingProvider.notifier).processDocument(
          _selectedDocumentPath!,
          language: lang,
        );
    if (result != null && mounted) {
      ref.read(ocrResultProvider.notifier).state = result;
      Navigator.pushNamed(context, '/ocr/result', arguments: result);
    }
  }

  void _showLanguagePicker(BuildContext context) {
    final selectedLang = ref.read(ocrSelectedLanguageProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Select OCR Language', style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final code = _languages.keys.elementAt(index);
                  final name = _languages.values.elementAt(index);
                  final isSelected = code == selectedLang;
                  return ListTile(
                    leading: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? const Color(0xFF4D2DAB) : null),
                    title: Text(name),
                    selected: isSelected,
                    onTap: () {
                      ref.read(ocrSelectedLanguageProvider.notifier).state = code;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
