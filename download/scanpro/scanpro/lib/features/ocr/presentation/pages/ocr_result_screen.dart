import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/ocr/presentation/providers/ocr_provider.dart';
import 'package:scanpro/features/ocr/presentation/widgets/text_block_widget.dart';
import 'package:scanpro/features/ocr/presentation/widgets/smart_action_chip.dart';

class OcrResultScreen extends ConsumerStatefulWidget {
  const OcrResultScreen({super.key});

  @override
  ConsumerState<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends ConsumerState<OcrResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showTranslated = false;

  static const _targetLanguages = {
    'hin': 'Hindi',
    'spa': 'Spanish',
    'fra': 'French',
    'deu': 'German',
    'jpn': 'Japanese',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(ocrResultProvider);
    final smartActions = ref.watch(ocrSmartActionsProvider);
    final translationState = ref.watch(ocrTranslationProvider);
    final theme = Theme.of(context);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('OCR Result')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text('No OCR result found', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Result'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _shareResult(result),
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, result),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'copy_all', child: Text('Copy All Text')),
              const PopupMenuItem(value: 'export_txt', child: Text('Export as TXT')),
              const PopupMenuItem(value: 'export_pdf', child: Text('Export as PDF')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Text'), Tab(text: 'Blocks')],
        ),
      ),
      body: Column(
        children: [
          _buildConfidenceBar(theme, result.confidence),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTextViewTab(theme, result, translationState),
                _buildBlocksView(theme, result),
              ],
            ),
          ),
          if (smartActions.isNotEmpty) _buildSmartActionsBar(theme, smartActions),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(theme, result),
    );
  }

  Widget _buildConfidenceBar(ThemeData theme, double confidence) {
    final percent = (confidence * 100).toInt();
    final color = percent >= 90 ? Colors.green : percent >= 70 ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, size: 18, color: color),
          const SizedBox(width: 8),
          Text('Confidence: $percent%', style: theme.textTheme.labelLarge?.copyWith(color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: confidence,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTextViewTab(ThemeData theme, OcrResult result, AsyncValue<OcrTranslation> translationState) {
    final displayText = _showTranslated && translationState.hasValue && translationState.value!.translatedText.isNotEmpty
        ? translationState.value!.translatedText
        : result.extractedText;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showTranslated && translationState.isLoading)
            _buildTranslationLoading(theme)
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: SelectableText(
                displayText,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
              ),
            ),
            if (_showTranslated && translationState.hasValue) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.translate, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Translated to ${_targetLanguages[translationState.value!.targetLanguage] ?? translationState.value!.targetLanguage}',
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 16),
          if (result.smartActions.isNotEmpty) ...[
            Text('Detected Content', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.smartActions.map((action) => SmartActionChip(action: action)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTranslationLoading(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Translating...', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildBlocksView(ThemeData theme, OcrResult result) {
    if (result.textBlocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.text_fields_outlined, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('No text blocks available', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: result.textBlocks.length,
      itemBuilder: (context, index) {
        final block = result.textBlocks[index];
        return TextBlockWidget(block: block, index: index)
            .animate()
            .fadeIn(duration: 200.ms, delay: (index * 50).ms)
            .slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildSmartActionsBar(ThemeData theme, List<SmartAction> actions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Smart Actions', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: actions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => SmartActionChip(action: actions[index]),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 300.ms);
  }

  Widget _buildBottomActions(ThemeData theme, OcrResult result) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyAll(result.extractedText),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy All'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: _showTranslatePicker,
                icon: const Icon(Icons.translate, size: 18),
                label: Text(_showTranslated ? 'Original' : 'Translate'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyAll(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard'), behavior: SnackBarBehavior.floating),
    );
  }

  void _shareResult(OcrResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing OCR result...'), behavior: SnackBarBehavior.floating),
    );
  }

  void _handleMenuAction(String action, OcrResult result) {
    switch (action) {
      case 'copy_all':
        _copyAll(result.extractedText);
        break;
      case 'export_txt':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exporting as TXT...'), behavior: SnackBarBehavior.floating),
        );
        break;
      case 'export_pdf':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exporting as PDF...'), behavior: SnackBarBehavior.floating),
        );
        break;
    }
  }

  void _showTranslatePicker() {
    if (_showTranslated) {
      setState(() => _showTranslated = false);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Translate To', style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _targetLanguages.length,
              itemBuilder: (context, index) {
                final code = _targetLanguages.keys.elementAt(index);
                final name = _targetLanguages.values.elementAt(index);
                return ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text(name),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _showTranslated = true);
                    final result = ref.read(ocrResultProvider);
                    if (result != null) {
                      ref.read(ocrTranslationProvider.notifier).translate(
                            result.extractedText,
                            result.language,
                            code,
                          );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
