/// Responsive grid of document cards.
///
/// Adapts column count based on screen width using [GridView.builder]
/// with [SliverGridDelegateWithFixedCrossAxisCount].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/core/theme/dimensions.dart';
import 'package:scanpro/core/widgets/empty_state.dart';
import 'package:scanpro/core/widgets/loading_widget.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/documents/presentation/widgets/document_card.dart';

/// Responsive grid view of [DocumentCard] widgets.
///
/// [documents] is the async list of documents to display.
/// [onDocumentTap] fires when a document card is tapped.
/// [onFavoriteToggle] fires when the favorite icon is pressed.
class DocumentGridView extends ConsumerWidget {
  final AsyncValue<List<ScanDocument>> documents;
  final ValueChanged<ScanDocument> onDocumentTap;
  final ValueChanged<ScanDocument> onFavoriteToggle;

  const DocumentGridView({
    super.key,
    required this.documents,
    required this.onDocumentTap,
    required this.onFavoriteToggle,
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _calculateColumns(constraints.maxWidth);
            return GridView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSmall,
                vertical: Dimensions.spacing8,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.72,
                crossAxisSpacing: Dimensions.spacing8,
                mainAxisSpacing: Dimensions.spacing8,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                return DocumentCard(
                  document: doc,
                  onTap: () => onDocumentTap(doc),
                  onFavoriteToggle: () => onFavoriteToggle(doc),
                );
              },
            );
          },
        );
      },
    );
  }

  int _calculateColumns(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }
}
