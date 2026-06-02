import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../scanner/domain/entities/scanned_document.dart';
import '../providers/document_provider.dart';

/// Document detail screen with preview, and action buttons for
/// share, rename, move, delete, OCR, PDF export, and favourite toggle.
class DocumentDetailScreen extends ConsumerStatefulWidget {
  const DocumentDetailScreen({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  ScannedDocument? _document;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadDocument());
  }

  Future<void> _loadDocument() async {
    final result = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(widget.documentId);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (document) {
        if (mounted) {
          setState(() => _document = document);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Document')),
        body: const LoadingWidget.inline(message: 'Loading document…'),
      );
    }

    final doc = _document!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          doc.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () => _toggleFavorite(doc),
            icon: Icon(
              doc.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: doc.isFavorite ? AppTheme.accentColor : null,
            ),
            tooltip: doc.isFavorite ? 'Remove from favourites' : 'Add to favourites',
          ),
          PopupMenuButton<String>(
            onSelected: (action) => _onActionSelected(action, doc),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              const PopupMenuItem(value: 'move', child: Text('Move to Folder')),
              const PopupMenuItem(value: 'ocr', child: Text('Extract Text (OCR)')),
              const PopupMenuItem(value: 'pdf', child: Text('Export as PDF')),
              const PopupMenuItem(value: 'share', child: Text('Share')),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Preview ────────────────────────────────────────
            _buildImagePreview(doc, colorScheme),

            const SizedBox(height: 20),

            // ── Document Info ────────────────────────────────────────
            _buildInfoSection(theme, colorScheme, doc),

            const SizedBox(height: 16),

            // ── Tags ─────────────────────────────────────────────────
            if (doc.tags.isNotEmpty) ...[
              _buildTagsSection(theme, colorScheme, doc),
              const SizedBox(height: 16),
            ],

            // ── OCR Text Preview ─────────────────────────────────────
            if (doc.ocrText != null && doc.ocrText!.isNotEmpty) ...[
              _buildOcrPreview(theme, colorScheme, doc),
              const SizedBox(height: 16),
            ],

            // ── Quick Actions ────────────────────────────────────────
            _buildQuickActions(colorScheme, doc),
          ],
        ),
      ),
    );
  }

  /// Builds the document image preview.
  Widget _buildImagePreview(ScannedDocument doc, ColorScheme colorScheme) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: doc.filePath.isNotEmpty && File(doc.filePath).existsSync()
            ? Image.file(
                File(doc.filePath),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
              )
            : _buildPlaceholder(colorScheme),
      ),
    );
  }

  /// Builds a placeholder when the image is not available.
  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 8),
          Text(
            'Document Preview',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the document information section.
  Widget _buildInfoSection(
    ThemeData theme,
    ColorScheme colorScheme,
    ScannedDocument doc,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today_rounded,
              'Created',
              _formatDate(doc.createdAt),
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.update_rounded,
              'Modified',
              _formatDate(doc.updatedAt),
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.attach_file_rounded,
              'Size',
              FileUtils.formatBytes(doc.fileSize),
              colorScheme,
            ),
            if (doc.pages.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.description_rounded,
                'Pages',
                '${doc.pages.length}',
                colorScheme,
              ),
            ],
            if (doc.isSynced) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.cloud_done_rounded,
                'Synced',
                'Yes',
                colorScheme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a single info row with icon, label, and value.
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  /// Builds the tags section.
  Widget _buildTagsSection(
    ThemeData theme,
    ColorScheme colorScheme,
    ScannedDocument doc,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: doc.tags
                  .map((tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the OCR text preview section.
  Widget _buildOcrPreview(
    ThemeData theme,
    ColorScheme colorScheme,
    ScannedDocument doc,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.text_fields_rounded,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Extracted Text',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go(AppRoutes.ocr),
                  child: const Text('View Full'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              doc.ocrText!,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the quick action buttons row.
  Widget _buildQuickActions(ColorScheme colorScheme, ScannedDocument doc) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _onActionSelected('share', doc),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('Share'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _onActionSelected('pdf', doc),
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: const Text('PDF'),
          ),
        ),
      ],
    );
  }

  /// Handles action selection from the popup menu or quick actions.
  void _onActionSelected(String action, ScannedDocument doc) {
    switch (action) {
      case 'rename':
        _showRenameDialog(doc);
        break;
      case 'move':
        _showMoveDialog(doc);
        break;
      case 'ocr':
        context.go(AppRoutes.ocr);
        break;
      case 'pdf':
        context.go(AppRoutes.pdfCreate);
        break;
      case 'share':
        // In production, this would use share_plus.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share feature coming soon')),
        );
        break;
      case 'delete':
        _confirmDelete(doc);
        break;
    }
  }

  /// Toggles the favourite status of a document.
  Future<void> _toggleFavorite(ScannedDocument doc) async {
    await ref.read(documentsProvider.notifier).toggleFavorite(doc.id);
    await _loadDocument();
  }

  /// Shows a dialog to rename the document.
  void _showRenameDialog(ScannedDocument doc) {
    final controller = TextEditingController(text: doc.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Document Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ref
                  .read(documentRepositoryProvider)
                  .renameDocument(
                    documentId: doc.id,
                    newName: controller.text.trim(),
                  );
              result.fold(
                (failure) => ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text(failure.message)),
                ),
                (_) {
                  _loadDocument();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Document renamed')),
                  );
                },
              );
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog to move the document to a folder.
  void _showMoveDialog(ScannedDocument doc) {
    final folders = ref.read(documentsProvider).folders;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Folder'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return ListTile(
                leading: const Icon(Icons.folder_rounded),
                title: Text(folder.name),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await ref
                      .read(documentRepositoryProvider)
                      .moveDocumentToFolder(
                        documentId: doc.id,
                        folderId: folder.id,
                      );
                  result.fold(
                    (failure) =>
                        ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text(failure.message)),
                    ),
                    (_) {
                      _loadDocument();
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text('Moved to ${folder.name}'),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a document.
  void _confirmDelete(ScannedDocument doc) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Move "${doc.name}" to trash?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(documentsProvider.notifier)
                  .moveToTrash(doc.id);
              if (mounted) {
                GoRouter.of(this.context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Formats a [DateTime] for display.
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Convenience accessors for theme colours.
class AppTheme {
  static const Color primaryColor = Color(0xFF4D2DAB);
  static const Color accentColor = Color(0xFFFF6B6B);
}
