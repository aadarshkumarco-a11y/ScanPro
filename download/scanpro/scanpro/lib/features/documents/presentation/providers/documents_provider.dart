/// Riverpod providers for the Documents feature presentation layer.
///
/// Exposes providers for document lists, folders, tags, favorites,
/// recent documents, trash, and sorting/filtering state.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/documents/domain/entities/folder.dart';
import 'package:scanpro/features/documents/domain/entities/tag.dart';

// ---------------------------------------------------------------------------
// Sort & Filter State
// ---------------------------------------------------------------------------

/// Sort field options for the documents list.
enum DocumentSortField {
  name,
  date,
  size,
  category,
}

/// Document type filter options.
enum DocumentFilter {
  all,
  pdf,
  image,
  ocr,
  favorites,
}

/// State for document sorting and filtering.
class SortFilterState {
  final DocumentSortField sortField;
  final bool sortAscending;
  final DocumentFilter activeFilter;
  final String searchQuery;

  const SortFilterState({
    this.sortField = DocumentSortField.date,
    this.sortAscending = false,
    this.activeFilter = DocumentFilter.all,
    this.searchQuery = '',
  });

  SortFilterState copyWith({
    DocumentSortField? sortField,
    bool? sortAscending,
    DocumentFilter? activeFilter,
    String? searchQuery,
  }) {
    return SortFilterState(
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier for document sort/filter preferences.
class SortFilterNotifier extends StateNotifier<SortFilterState> {
  SortFilterNotifier() : super(const SortFilterState());

  void setSortField(DocumentSortField field) {
    state = state.copyWith(sortField: field);
  }

  void toggleSortDirection() {
    state = state.copyWith(sortAscending: !state.sortAscending);
  }

  void setFilter(DocumentFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() => state = state.copyWith(searchQuery: '');
}

/// Provider for sort and filter state.
final documentSortProvider =
    StateNotifierProvider<SortFilterNotifier, SortFilterState>(
  (ref) => SortFilterNotifier(),
);

/// Provider for document type filter (convenience).
final documentFilterProvider = Provider<DocumentFilter>(
  (ref) => ref.watch(documentSortProvider).activeFilter,
);

// ---------------------------------------------------------------------------
// Documents List
// ---------------------------------------------------------------------------

/// Async provider that fetches all non-deleted documents and applies
/// the current sort/filter state from [documentSortProvider].
final documentsListProvider =
    FutureProvider<List<ScanDocument>>((ref) async {
  final sortFilter = ref.watch(documentSortProvider);

  // Placeholder: in production this calls the GetDocuments use case
  // via the repository provider.
  await Future.delayed(const Duration(milliseconds: 400));

  final docs = _mockDocuments();

  // Apply filter
  var filtered = docs.where((doc) {
    if (doc.isDeleted) return false;
    return switch (sortFilter.activeFilter) {
      DocumentFilter.all => true,
      DocumentFilter.pdf => doc.pdfPath != null,
      DocumentFilter.image => doc.pdfPath == null,
      DocumentFilter.ocr => doc.ocrText != null,
      DocumentFilter.favorites => doc.isFavorite,
    };
  }).toList();

  // Apply search query
  if (sortFilter.searchQuery.isNotEmpty) {
    final q = sortFilter.searchQuery.toLowerCase();
    filtered = filtered
        .where((doc) =>
            doc.title.toLowerCase().contains(q) ||
            (doc.ocrText?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  // Apply sort
  filtered.sort((a, b) {
    final cmp = switch (sortFilter.sortField) {
      DocumentSortField.name => a.title.compareTo(b.title),
      DocumentSortField.date => a.updatedAt.compareTo(b.updatedAt),
      DocumentSortField.size => a.fileSize.compareTo(b.fileSize),
      DocumentSortField.category => a.colorMode.index.compareTo(b.colorMode.index),
    };
    return sortFilter.sortAscending ? cmp : -cmp;
  });

  return filtered;
});

// ---------------------------------------------------------------------------
// Folders
// ---------------------------------------------------------------------------

/// Provider for all folders.
final foldersListProvider = FutureProvider<List<Folder>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockFolders();
});

// ---------------------------------------------------------------------------
// Tags
// ---------------------------------------------------------------------------

/// Provider for all tags.
final tagsListProvider = FutureProvider<List<Tag>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return _mockTags();
});

// ---------------------------------------------------------------------------
// Favorites
// ---------------------------------------------------------------------------

/// Provider for favorite documents.
final favoriteDocumentsProvider = FutureProvider<List<ScanDocument>>((ref) async {
  final allDocs = await ref.watch(documentsListProvider.future);
  return allDocs.where((doc) => doc.isFavorite).toList();
});

// ---------------------------------------------------------------------------
// Recent Documents
// ---------------------------------------------------------------------------

/// Provider for recently updated documents.
final recentDocumentsProvider = FutureProvider<List<ScanDocument>>((ref) async {
  final allDocs = await ref.watch(documentsListProvider.future);
  final sorted = List<ScanDocument>.from(allDocs)
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sorted.take(10).toList();
});

// ---------------------------------------------------------------------------
// Trash
// ---------------------------------------------------------------------------

/// Provider for soft-deleted documents (trash).
final trashDocumentsProvider = FutureProvider<List<ScanDocument>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockDocuments().where((doc) => doc.isDeleted).toList();
});

// ---------------------------------------------------------------------------
// Document Detail
// ---------------------------------------------------------------------------

/// Provider that fetches a single document by its ID.
final documentDetailProvider =
    FutureProvider.family<ScanDocument, String>((ref, id) async {
  final allDocs = await ref.watch(documentsListProvider.future);
  return allDocs.firstWhere(
    (doc) => doc.id == id,
    orElse: () => throw Exception('Document not found'),
  );
});

// ---------------------------------------------------------------------------
// Mock Data (replace with real use case calls in production)
// ---------------------------------------------------------------------------

List<ScanDocument> _mockDocuments() {
  final now = DateTime.now();
  return [
    ScanDocument(
      id: '1',
      title: 'Invoice March 2025',
      filePath: '/docs/invoice_mar.pdf',
      pdfPath: '/docs/invoice_mar.pdf',
      thumbnailPath: '/docs/invoice_mar_thumb.jpg',
      isFavorite: true,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 1)),
      fileSize: 245000,
      pageCount: 3,
      ocrText: 'Invoice #1234 Total: \$450.00',
      syncStatus: SyncStatus.synced,
    ),
    ScanDocument(
      id: '2',
      title: 'Meeting Notes',
      filePath: '/docs/notes.jpg',
      thumbnailPath: '/docs/notes_thumb.jpg',
      folderId: 'f1',
      tags: ['t1'],
      isFavorite: false,
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 4)),
      fileSize: 1200000,
      pageCount: 1,
      colorMode: ColorMode.grayscale,
      enhancementType: EnhancementType.auto,
    ),
    ScanDocument(
      id: '3',
      title: 'Contract Draft',
      filePath: '/docs/contract.pdf',
      pdfPath: '/docs/contract.pdf',
      tags: ['t2'],
      isFavorite: true,
      isArchived: true,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 25)),
      fileSize: 890000,
      pageCount: 12,
      ocrText: 'This Agreement is entered into...',
      syncStatus: SyncStatus.pendingUpload,
    ),
    ScanDocument(
      id: '4',
      title: 'Receipt - Office Supplies',
      filePath: '/docs/receipt.jpg',
      isDeleted: true,
      createdAt: now.subtract(const Duration(days: 40)),
      updatedAt: now.subtract(const Duration(days: 40)),
      fileSize: 340000,
    ),
  ];
}

List<Folder> _mockFolders() {
  final now = DateTime.now();
  return [
    Folder(
      id: 'f1',
      name: 'Work',
      color: '#2196F3',
      icon: 'work',
      documentCount: 5,
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now,
    ),
    Folder(
      id: 'f2',
      name: 'Personal',
      color: '#FF5722',
      icon: 'person',
      documentCount: 3,
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now.subtract(const Duration(days: 3)),
    ),
    Folder(
      id: 'f3',
      name: 'Receipts',
      color: '#4CAF50',
      icon: 'receipt',
      documentCount: 8,
      parentId: 'f1',
      createdAt: now.subtract(const Duration(days: 45)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
  ];
}

List<Tag> _mockTags() {
  return [
    const Tag(id: 't1', name: 'Important', color: '#F44336', usageCount: 5, createdAt: _dummyDate),
    const Tag(id: 't2', name: 'Legal', color: '#9C27B0', usageCount: 3, createdAt: _dummyDate),
    const Tag(id: 't3', name: 'Finance', color: '#4CAF50', usageCount: 7, createdAt: _dummyDate),
  ];
}

// ignore: unused_element
const _dummyDate = DateTime(2025, 1, 1);
