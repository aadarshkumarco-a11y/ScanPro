import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/ai_features/presentation/providers/ai_provider.dart';
import 'package:scanpro/features/ai_features/presentation/widgets/ai_loading_shimmer.dart';
import 'package:scanpro/features/ai_features/presentation/widgets/extracted_field_row.dart';

class AiExtractScreen extends ConsumerStatefulWidget {
  const AiExtractScreen({super.key});

  @override
  ConsumerState<AiExtractScreen> createState() => _AiExtractScreenState();
}

class _AiExtractScreenState extends ConsumerState<AiExtractScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiExtractDataProvider.notifier).extractData('sample-doc-1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final extractState = ref.watch(aiExtractDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Data Extraction'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.read(aiExtractDataProvider.notifier).extractData('sample-doc-1'),
            icon: const Icon(Icons.refresh),
            tooltip: 'Re-extract',
          ),
        ],
      ),
      body: extractState.data.when(
        loading: () => _buildLoadingContent(theme),
        error: (error, _) => _buildErrorState(theme, error.toString()),
        data: (data) => _buildExtractedContent(theme, data),
      ),
    );
  }

  Widget _buildLoadingContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiLoadingShimmer(height: 80),
          const SizedBox(height: 16),
          Text('Extracted Fields', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...List.generate(6, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: AiLoadingShimmer(height: 48),
          )),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Failed to extract data', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(error, textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => ref.read(aiExtractDataProvider.notifier).extractData('sample-doc-1'),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedContent(ThemeData theme, ExtractedData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentTypeCard(theme, data),
          const SizedBox(height: 20),
          _buildFieldsTable(theme, data),
          const SizedBox(height: 20),
          _buildExportButtons(theme, data),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeCard(ThemeData theme, ExtractedData data) {
    final (icon, color) = _documentTypeStyle(data.documentType);
    final confidencePercent = (data.typeConfidence * 100).toInt();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: const Color(0xFF4D2DAB).withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detected Type', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text(data.documentTypeName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        '$confidencePercent% confident',
                        style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.96, 0.96));
  }

  Widget _buildFieldsTable(ThemeData theme, ExtractedData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.table_chart, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Extracted Fields', style: theme.textTheme.titleMedium),
            const Spacer(),
            Text('${data.fields.length} fields', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        // Header row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(
            children: [
              SizedBox(width: 120, child: Text('Field', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant))),
              Expanded(child: Text('Value', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant))),
              const SizedBox(width: 40),
            ],
          ),
        ),
        ...data.fields.asMap().entries.map((entry) {
          final isLast = entry.key == data.fields.length - 1;
          return ExtractedFieldRow(
            field: entry.value,
            isLast: isLast,
          ).animate().fadeIn(duration: 200.ms, delay: (entry.key * 50).ms).slideX(begin: 0.05, end: 0);
        }),
      ],
    );
  }

  Widget _buildExportButtons(ThemeData theme, ExtractedData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Export Data', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportAs('JSON', data),
                icon: const Icon(Icons.data_object, size: 18),
                label: const Text('JSON'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportAs('CSV', data),
                icon: const Icon(Icons.table_rows, size: 18),
                label: const Text('CSV'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _exportAs('Clipboard', data),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy All'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  (IconData, Color) _documentTypeStyle(DocumentType type) {
    switch (type) {
      case DocumentType.invoice:
        return (Icons.receipt_long, Colors.blue);
      case DocumentType.receipt:
        return (Icons.point_of_sale, Colors.green);
      case DocumentType.resume:
        return (Icons.person, Colors.purple);
      case DocumentType.contract:
        return (Icons.gavel, Colors.orange);
      case DocumentType.report:
        return (Icons.assessment, Colors.teal);
      case DocumentType.letter:
        return (Icons.mail, Colors.indigo);
      case DocumentType.other:
        return (Icons.description, Colors.grey);
    }
  }

  void _exportAs(String format, ExtractedData data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported as $format'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'Open', onPressed: () {}),
      ),
    );
  }
}
