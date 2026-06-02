import 'package:flutter/material.dart';

/// A reusable empty-state placeholder widget.
///
/// Displays a large icon, a bold title, a descriptive subtitle,
/// and an optional call-to-action button – ideal for screens
/// where content has not yet been created or is filtered to zero.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize = 72,
  });

  /// The illustration / icon for the empty state.
  final IconData icon;

  /// Short bold heading (e.g. "No Documents").
  final String title;

  /// Longer description explaining why the list is empty.
  final String subtitle;

  /// Optional CTA button label. If `null`, no button is shown.
  final String? actionLabel;

  /// Callback when the CTA button is pressed.
  final VoidCallback? onAction;

  /// Custom icon colour; defaults to `colorScheme.primary`.
  final Color? iconColor;

  /// Custom icon size (default 72).
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize + 32,
              height: iconSize + 32,
              decoration: BoxDecoration(
                color: (iconColor ?? colorScheme.primary)
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Pre-configured Empty States ───────────────────────────────────

/// Empty state for the documents list.
class EmptyDocumentsState extends StatelessWidget {
  const EmptyDocumentsState({super.key, this.onAction});

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.folder_open_rounded,
      title: 'No Documents Yet',
      subtitle:
          'Start scanning documents to build your library. Tap the button below to begin.',
      actionLabel: 'Scan Now',
      onAction: onAction,
    );
  }
}

/// Empty state for search results.
class EmptySearchState extends StatelessWidget {
  const EmptySearchState({super.key, this.onAction, this.query = ''});

  final VoidCallback? onAction;
  final String query;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      subtitle: query.isNotEmpty
          ? 'No documents matching "$query". Try different keywords.'
          : 'Try searching with different keywords or filters.',
      actionLabel: onAction != null ? 'Clear Filters' : null,
      onAction: onAction,
    );
  }
}

/// Empty state for OCR results.
class EmptyOcrState extends StatelessWidget {
  const EmptyOcrState({super.key, this.onAction});

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.text_fields_rounded,
      title: 'No Text Detected',
      subtitle:
          'The image does not contain readable text. Try scanning a clearer document.',
      actionLabel: 'Scan Again',
      onAction: onAction,
    );
  }
}

/// Empty state for cloud sync.
class EmptySyncState extends StatelessWidget {
  const EmptySyncState({super.key, this.onAction});

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.cloud_outlined,
      title: 'Nothing to Sync',
      subtitle: 'All your documents are up to date. New scans will sync automatically.',
      actionLabel: onAction != null ? 'Sync Now' : null,
      onAction: onAction,
    );
  }
}

/// Empty state for the trash / recently deleted.
class EmptyTrashState extends StatelessWidget {
  const EmptyTrashState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.delete_outline_rounded,
      title: 'Trash is Empty',
      subtitle: 'Deleted documents will appear here for 30 days before permanent removal.',
    );
  }
}

/// Empty state for signatures.
class EmptySignatureState extends StatelessWidget {
  const EmptySignatureState({super.key, this.onAction});

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.draw_rounded,
      title: 'No Signatures Saved',
      subtitle: 'Create a signature to quickly sign documents and PDFs.',
      actionLabel: 'Create Signature',
      onAction: onAction,
    );
  }
}

/// Empty state for folders.
class EmptyFolderState extends StatelessWidget {
  const EmptyFolderState({super.key, this.onAction});

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.create_new_folder_outlined,
      title: 'Folder is Empty',
      subtitle: 'Move documents into this folder to organise your library.',
      actionLabel: onAction != null ? 'Add Documents' : null,
      onAction: onAction,
    );
  }
}

/// Empty state for QR scan history.
class EmptyQrHistoryState extends StatelessWidget {
  const EmptyQrHistoryState({super.key, this.onAction});

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.qr_code_scanner_rounded,
      title: 'No Scanned Codes',
      subtitle: 'Scan a QR code or barcode and the results will appear here.',
      actionLabel: 'Scan QR Code',
      onAction: onAction,
    );
  }
}
