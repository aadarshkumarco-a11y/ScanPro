import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/di/app_module.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/documents/data/datasources/document_local_datasource.dart';
import 'package:scanpro/features/documents/data/repositories/document_repository_impl.dart';
import 'package:scanpro/features/documents/domain/entities/document_folder.dart';
import 'package:scanpro/features/documents/domain/entities/document_tag.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';
import 'package:scanpro/features/documents/domain/usecases/favorite_document_usecase.dart';
import 'package:scanpro/features/documents/domain/usecases/get_documents_usecase.dart';
import 'package:scanpro/features/documents/domain/usecases/manage_folders_usecase.dart';
import 'package:scanpro/features/documents/domain/usecases/manage_tags_usecase.dart';
import 'package:scanpro/features/documents/domain/usecases/trash_usecase.dart';

// ═══════════════════════════════════════════════════════════════════
//  Repository Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the [DocumentRepository] implementation.
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final documentsBox = ref.watch(documentsBoxProvider);
  final foldersBox = ref.watch(foldersBoxProvider);
  final tagsBox = ref.watch(tagsBoxProvider);

  final localDatasource = DocumentLocalDatasource(
    documentsBox: documentsBox,
    foldersBox: foldersBox,
    tagsBox: tagsBox,
  );

  return DocumentRepositoryImpl(localDatasource: localDatasource);
});

// ═══════════════════════════════════════════════════════════════════
//  Use Case Providers
// ═══════════════════════════════════════════════════════════════════

/// Provides the [GetDocumentsUseCase].
final getDocumentsUseCaseProvider = Provider<GetDocumentsUseCase>((ref) {
  return GetDocumentsUseCase(ref.watch(documentRepositoryProvider));
});

/// Provides the [ManageFoldersUseCase].
final manageFoldersUseCaseProvider = Provider<ManageFoldersUseCase>((ref) {
  return ManageFoldersUseCase(ref.watch(documentRepositoryProvider));
});

/// Provides the [ManageTagsUseCase].
final manageTagsUseCaseProvider = Provider<ManageTagsUseCase>((ref) {
  return ManageTagsUseCase(ref.watch(documentRepositoryProvider));
});

/// Provides the [FavoriteDocumentUseCase].
final favoriteDocumentUseCaseProvider = Provider<FavoriteDocumentUseCase>((ref) {
  return FavoriteDocumentUseCase(ref.watch(documentRepositoryProvider));
});

/// Provides the [TrashUseCase].
final trashUseCaseProvider = Provider<TrashUseCase>((ref) {
  return TrashUseCase(ref.watch(documentRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════
//  Documents State
// ═══════════════════════════════════════════════════════════════════

/// Possible load states for document lists.
enum DocumentsStatus {
  initial,
  loading,
  loaded,
  error,
}

/// State holder for the documents feature.
class DocumentsState {
  final DocumentsStatus status;
  final List<ScannedDocument> documents;
  final List<ScannedDocument> favoriteDocuments;
  final List<ScannedDocument> trashedDocuments;
  final List<DocumentFolder> folders;
  final List<DocumentTag> tags;
  final String? errorMessage;
  final String? selectedFolderId;
  final String? selectedTag;

  const DocumentsState({
    this.status = DocumentsStatus.initial,
    this.documents = const [],
    this.favoriteDocuments = const [],
    this.trashedDocuments = const [],
    this.folders = const [],
    this.tags = const [],
    this.errorMessage,
    this.selectedFolderId,
    this.selectedTag,
  });

  DocumentsState copyWith({
    DocumentsStatus? status,
    List<ScannedDocument>? documents,
    List<ScannedDocument>? favoriteDocuments,
    List<ScannedDocument>? trashedDocuments,
    List<DocumentFolder>? folders,
    List<DocumentTag>? tags,
    String? errorMessage,
    String? selectedFolderId,
    String? selectedTag,
  }) {
    return DocumentsState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      favoriteDocuments: favoriteDocuments ?? this.favoriteDocuments,
      trashedDocuments: trashedDocuments ?? this.trashedDocuments,
      folders: folders ?? this.folders,
      tags: tags ?? this.tags,
      errorMessage: errorMessage,
      selectedFolderId: selectedFolderId ?? this.selectedFolderId,
      selectedTag: selectedTag ?? this.selectedTag,
    );
  }
}

/// State notifier for the documents feature.
class DocumentsNotifier extends StateNotifier<DocumentsState> {
  DocumentsNotifier({
    required DocumentRepository repository,
    required GetDocumentsUseCase getDocumentsUseCase,
    required ManageFoldersUseCase manageFoldersUseCase,
    required ManageTagsUseCase manageTagsUseCase,
    required FavoriteDocumentUseCase favoriteDocumentUseCase,
    required TrashUseCase trashUseCase,
  })  : _repository = repository,
        _getDocumentsUseCase = getDocumentsUseCase,
        _manageFoldersUseCase = manageFoldersUseCase,
        _manageTagsUseCase = manageTagsUseCase,
        _favoriteDocumentUseCase = favoriteDocumentUseCase,
        _trashUseCase = trashUseCase,
        super(const DocumentsState());

  final DocumentRepository _repository;
  final GetDocumentsUseCase _getDocumentsUseCase;
  final ManageFoldersUseCase _manageFoldersUseCase;
  final ManageTagsUseCase _manageTagsUseCase;
  final FavoriteDocumentUseCase _favoriteDocumentUseCase;
  final TrashUseCase _trashUseCase;

  // ── Documents ─────────────────────────────────────────────────────

  /// Loads all documents from storage.
  Future<void> loadDocuments() async {
    state = state.copyWith(status: DocumentsStatus.loading);

    final result = await _getDocumentsUseCase(
      folderId: state.selectedFolderId,
      tag: state.selectedTag,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: DocumentsStatus.error,
        errorMessage: failure.message,
      ),
      (documents) => state = state.copyWith(
        status: DocumentsStatus.loaded,
        documents: documents,
      ),
    );
  }

  /// Toggles the favourite status of a document.
  Future<void> toggleFavorite(String documentId) async {
    final result = await _favoriteDocumentUseCase(documentId);

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (updatedDoc) {
        final updatedDocs = state.documents.map((d) {
          return d.id == documentId ? updatedDoc : d;
        }).toList();
        state = state.copyWith(documents: updatedDocs);
      },
    );
  }

  /// Loads all favourite documents.
  Future<void> loadFavorites() async {
    final result = await _favoriteDocumentUseCase.getFavorites();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (favorites) => state = state.copyWith(favoriteDocuments: favorites),
    );
  }

  /// Moves a document to the trash.
  Future<void> moveToTrash(String documentId) async {
    final result = await _trashUseCase.moveToTrash(documentId);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        final updatedDocs = state.documents
            .where((d) => d.id != documentId)
            .toList();
        state = state.copyWith(documents: updatedDocs);
      },
    );
  }

  /// Loads all trashed documents.
  Future<void> loadTrashedDocuments() async {
    final result = await _trashUseCase.getTrashedDocuments();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (trashed) => state = state.copyWith(trashedDocuments: trashed),
    );
  }

  /// Restores a document from the trash.
  Future<void> restoreFromTrash(String documentId) async {
    final result = await _trashUseCase.restore(documentId);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        final updatedTrash = state.trashedDocuments
            .where((d) => d.id != documentId)
            .toList();
        state = state.copyWith(trashedDocuments: updatedTrash);
      },
    );
  }

  /// Permanently deletes a document.
  Future<void> permanentDelete(String documentId) async {
    final result = await _trashUseCase.permanentDelete(documentId);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        final updatedTrash = state.trashedDocuments
            .where((d) => d.id != documentId)
            .toList();
        state = state.copyWith(trashedDocuments: updatedTrash);
      },
    );
  }

  /// Empties the trash.
  Future<void> emptyTrash() async {
    final result = await _trashUseCase.emptyTrash();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) => state = state.copyWith(trashedDocuments: []),
    );
  }

  /// Sets the selected folder filter.
  Future<void> setFolderFilter(String? folderId) async {
    state = state.copyWith(selectedFolderId: folderId);
    await loadDocuments();
  }

  /// Sets the selected tag filter.
  Future<void> setTagFilter(String? tag) async {
    state = state.copyWith(selectedTag: tag);
    await loadDocuments();
  }

  // ── Folders ───────────────────────────────────────────────────────

  /// Loads all folders.
  Future<void> loadFolders() async {
    final result = await _repository.getFolders();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (folders) => state = state.copyWith(folders: folders),
    );
  }

  /// Creates a new folder.
  Future<void> createFolder({
    required String name,
    String? color,
    String? icon,
  }) async {
    final result = await _manageFoldersUseCase.createFolder(
      name: name,
      color: color,
      icon: icon,
    );
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (folder) {
        final updatedFolders = [...state.folders, folder];
        state = state.copyWith(folders: updatedFolders);
      },
    );
  }

  /// Renames an existing folder.
  Future<void> renameFolder({
    required String folderId,
    required String newName,
  }) async {
    final result = await _manageFoldersUseCase.renameFolder(
      folderId: folderId,
      newName: newName,
    );
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (updated) {
        final updatedFolders = state.folders.map((f) {
          return f.id == folderId ? updated : f;
        }).toList();
        state = state.copyWith(folders: updatedFolders);
      },
    );
  }

  /// Deletes a folder.
  Future<void> deleteFolder(String folderId) async {
    final result = await _manageFoldersUseCase.deleteFolder(folderId);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        final updatedFolders = state.folders
            .where((f) => f.id != folderId)
            .toList();
        state = state.copyWith(folders: updatedFolders);
      },
    );
  }

  // ── Tags ──────────────────────────────────────────────────────────

  /// Loads all tags.
  Future<void> loadTags() async {
    final result = await _repository.getTags();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (tags) => state = state.copyWith(tags: tags),
    );
  }

  /// Creates a new tag.
  Future<void> createTag({required String name, String? color}) async {
    final result = await _manageTagsUseCase.createTag(
      name: name,
      color: color,
    );
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (tag) {
        final updatedTags = [...state.tags, tag];
        state = state.copyWith(tags: updatedTags);
      },
    );
  }

  /// Deletes a tag.
  Future<void> deleteTag(String tagId) async {
    final result = await _manageTagsUseCase.deleteTag(tagId);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        final updatedTags = state.tags.where((t) => t.id != tagId).toList();
        state = state.copyWith(tags: updatedTags);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Provider
// ═══════════════════════════════════════════════════════════════════

/// Provider for the [DocumentsNotifier].
final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, DocumentsState>((ref) {
  return DocumentsNotifier(
    repository: ref.watch(documentRepositoryProvider),
    getDocumentsUseCase: ref.watch(getDocumentsUseCaseProvider),
    manageFoldersUseCase: ref.watch(manageFoldersUseCaseProvider),
    manageTagsUseCase: ref.watch(manageTagsUseCaseProvider),
    favoriteDocumentUseCase: ref.watch(favoriteDocumentUseCaseProvider),
    trashUseCase: ref.watch(trashUseCaseProvider),
  );
});

/// Provider for the current documents list.
final documentsListProvider = Provider<List<ScannedDocument>>((ref) {
  return ref.watch(documentsProvider).documents;
});

/// Provider for folders.
final foldersProvider = Provider<List<DocumentFolder>>((ref) {
  return ref.watch(documentsProvider).folders;
});

/// Provider for tags.
final tagsProvider = Provider<List<DocumentTag>>((ref) {
  return ref.watch(documentsProvider).tags;
});

/// Provider for favourite documents.
final favoriteDocumentsProvider = Provider<List<ScannedDocument>>((ref) {
  return ref.watch(documentsProvider).favoriteDocuments;
});

/// Provider for trashed documents.
final trashedDocumentsProvider = Provider<List<ScannedDocument>>((ref) {
  return ref.watch(documentsProvider).trashedDocuments;
});
