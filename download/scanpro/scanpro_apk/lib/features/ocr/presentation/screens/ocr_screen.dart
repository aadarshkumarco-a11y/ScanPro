import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/ocr_provider.dart';

/// OCR screen with document selection, language picker, start OCR
/// button, and a progress indicator.
///
/// Users can select a scanned document, choose an OCR language, and
/// initiate text recognition. Results are displayed in a separate
/// screen.
class OcrScreen extends ConsumerStatefulWidget {
  const OcrScreen({super.key});

  @override
  ConsumerState<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends ConsumerState<OcrScreen> {
  final List<Map<String, String>> _availableLanguages = const [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'it', 'name': 'Italian'},
    {'code': 'pt', 'name': 'Portuguese'},
    {'code': 'zh', 'name': 'Chinese'},
    {'code': 'ja', 'name': 'Japanese'},
    {'code': 'ko', 'name': 'Korean'},
    {'code': 'ar', 'name': 'Arabic'},
    {'code': 'hi', 'name': 'Hindi'},
    {'code': 'ru', 'name': 'Russian'},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ocrProvider.notifier).reset());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ocrState = ref.watch(ocrProvider);
    final ocrNotifier = ref.read(ocrProvider.notifier);
    final isProcessing = ocrState.status == OcrStatus.recognizing ||
        ocrState.status == OcrStatus.extracting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Illustration ─────────────────────────────────
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.text_fields_rounded,
                  size: 56,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Extract Text from Documents',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Select a document and language to start OCR',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // ── Document Selection Card ─────────────────────────────
            Text(
              'Select Document',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            _DocumentSelectionCard(
              selectedDocumentPath: ocrState.selectedDocumentPath,
              onTap: () => _showDocumentPicker(context, ocrNotifier),
            ),
            const SizedBox(height: 24),

            // ── Language Picker ─────────────────────────────────────
            Text(
              'Recognition Language',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            _LanguagePicker(
              languages: _availableLanguages,
              selectedLanguage: ocrState.selectedLanguage,
              onLanguageSelected: (code) => ocrNotifier.setLanguage(code),
            ),
            const SizedBox(height: 32),

            // ── Progress Indicator ──────────────────────────────────
            if (isProcessing) ...[
              _ProgressSection(
                status: ocrState.status,
                progress: ocrState.progress,
              ),
              const SizedBox(height: 24),
            ],

            // ── Error Message ───────────────────────────────────────
            if (ocrState.status == OcrStatus.error &&
                ocrState.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ocrState.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Action Buttons ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isProcessing
                    ? null
                    : () async {
                        await ocrNotifier.recognizeText();
                        final newState = ref.read(ocrProvider);
                        if (newState.status == OcrStatus.success &&
                            newState.currentResult != null) {
                          if (mounted) {
                            context.go(AppRoutes.ocrResult);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isProcessing ? Icons.hourglass_empty_rounded : Icons
                        .text_fields_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isProcessing ? 'Recognizing…' : 'Start OCR',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: isProcessing
                    ? null
                    : () async {
                        await ocrNotifier.extractTextRegions();
                        final newState = ref.read(ocrProvider);
                        if (newState.status == OcrStatus.success &&
                            newState.currentResult != null) {
                          if (mounted) {
                            context.go(AppRoutes.ocrResult);
                          }
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isProcessing
                          ? Icons.hourglass_empty_rounded
                          : Icons.crop_free_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isProcessing
                          ? 'Extracting…'
                          : 'Extract Text Regions',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Recent OCR Results ──────────────────────────────────
            if (ocrState.results.isNotEmpty) ...[
              Text(
                'Recent Results',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              ...ocrState.results.take(5).map((result) => _OcrResultTile(
                    result: result,
                    onTap: () {
                      ocrNotifier.selectDocument(
                        documentId: result.documentId,
                        documentPath: '',
                      );
                      context.go(AppRoutes.ocrResult);
                    },
                    onDelete: () =>
                        ocrNotifier.deleteResult(result.id),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  /// Shows a document picker bottom sheet.
  void _showDocumentPicker(BuildContext context, OcrNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DocumentPickerSheet(
        onDocumentSelected: (documentId, documentPath) {
          notifier.selectDocument(
            documentId: documentId,
            documentPath: documentPath,
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Card widget for document selection.
class _DocumentSelectionCard extends StatelessWidget {
  const _DocumentSelectionCard({
    required this.selectedDocumentPath,
    required this.onTap,
  });

  final String? selectedDocumentPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDocument = selectedDocumentPath != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasDocument
              ? AppTheme.primaryColor.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasDocument
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasDocument
                    ? AppTheme.primaryColor.withValues(alpha: 0.15)
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasDocument
                    ? Icons.description_rounded
                    : Icons.add_photo_alternate_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasDocument
                        ? 'Document Selected'
                        : 'Tap to select a document',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDocument
                        ? selectedDocumentPath!.split('/').last
                        : 'Choose from scanned documents or gallery',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Language picker widget with selectable chips.
class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({
    required this.languages,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  final List<Map<String, String>> languages;
  final String selectedLanguage;
  final ValueChanged<String> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: languages.map((lang) {
        final isSelected = lang['code'] == selectedLanguage;
        return ChoiceChip(
          label: Text(lang['name']!),
          selected: isSelected,
          onSelected: (_) => onLanguageSelected(lang['code']!),
          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? AppTheme.primaryColor
                : Theme.of(context).colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }
}

/// Progress section with status text and linear progress bar.
class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.status,
    required this.progress,
  });

  final OcrStatus status;
  final double progress;

  String get _statusText {
    switch (status) {
      case OcrStatus.recognizing:
        return 'Recognizing text…';
      case OcrStatus.extracting:
        return 'Extracting text regions…';
      default:
        return 'Processing…';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _statusText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
}

/// Tile for displaying a recent OCR result.
class _OcrResultTile extends StatelessWidget {
  const _OcrResultTile({
    required this.result,
    required this.onTap,
    required this.onDelete,
  });

  final dynamic result;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.text_snippet_rounded,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          result.text.length > 50
              ? '${result.text.substring(0, 50)}…'
              : result.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${result.wordCount} words • ${(result.confidence * 100).toInt()}% confidence',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: Icon(
            Icons.delete_outline_rounded,
            color: theme.colorScheme.error.withValues(alpha: 0.7),
            size: 20,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Bottom sheet for document selection.
class _DocumentPickerSheet extends StatelessWidget {
  const _DocumentPickerSheet({
    required this.onDocumentSelected,
  });

  final void Function(String documentId, String documentPath)
      onDocumentSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Document',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Gallery option
                  _PickerOption(
                    icon: Icons.photo_library_rounded,
                    title: 'Import from Gallery',
                    subtitle: 'Select an image from your device',
                    onTap: () {
                      // In production, use image_picker/file_picker
                      onDocumentSelected('gallery', '/path/to/gallery/image.jpg');
                    },
                  ),
                  const SizedBox(height: 8),
                  _PickerOption(
                    icon: Icons.scanner_rounded,
                    title: 'Use Scanner',
                    subtitle: 'Scan a new document now',
                    onTap: () {
                      onDocumentSelected('scan', '/path/to/scan/image.jpg');
                    },
                  ),
                  const SizedBox(height: 8),
                  _PickerOption(
                    icon: Icons.folder_open_rounded,
                    title: 'Recent Documents',
                    subtitle: 'Choose from scanned documents',
                    onTap: () {
                      onDocumentSelected('recent', '/path/to/recent/doc.jpg');
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Option tile within the document picker sheet.
class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.primaryColor.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
