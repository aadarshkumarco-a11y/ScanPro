/// List view of document tiles.
///
/// Displays documents in a vertical [ListView] with [DocumentListTile] items.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/core/widgets/empty_state.dart';
import 'package:scanpro/core/widgets/loading_widget.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/documents/presentation/widgets/document_list_tile.dart';

/// List view of [DocumentListTile] widgets.
///
/// [documents] is the async list of documents to display.
/// [onDocumentTap] fires when a tile is tapped.
/// [onFavoriteToggle] fires when the favorite icon is pressed.
/// [onMore] fires when the overflow menu icon is pressed.
class DocumentListView extends ConsumerWidget {
  final AsyncValue<List<ScanDocument>> documents;
  final ValueChanged<ScanDocument> onDocumentTap;
  final ValueChanged<ScanDocument> onFavoriteToggle;
  final ValueChanged<ScanDocument>? onMore;

  const DocumentListView({
    super.key,
    required this.documents,
    required this.onDocumentTap,
    required this.onFavoriteToggle,
    this.onMore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return documents.when(
      loading: () => const LoadingWidget(message: 'Loading documents...'),
      error: (error, _) => Center(
        child: Text(
          error.toString(),
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (docs) {
        if (docs.isEmpty) {
          return const EmptyState(
            icon: Icons.folder_open_outlined,
            title: 'No Documents',
            subtitle: 'Scan or import documents to see them here',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.spacing8,
          ),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: Dimensions.paddingMedium + Dimensions.thumbnailSize + 12,
          ),
          itemBuilder: (context, index) {
            final doc = docs[index];
            return DocumentListTile(
              document: doc,
              onTap: () => onDocumentTap(doc),
              onFavoriteToggle: () => onFavoriteToggle(doc),
              onMore: onMore != null ? () => onMore!(doc) : null,
            );
          },
        );
      },
    );
  }
}
