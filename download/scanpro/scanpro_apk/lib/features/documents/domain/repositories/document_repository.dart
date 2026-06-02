import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/documents/domain/entities/document_folder.dart';
import 'package:scanpro/features/documents/domain/entities/document_tag.dart';

/// Abstract repository contract for document management operations.
///
/// Defines the domain-level API for querying, organising, and
/// managing scanned documents, folders, tags, and trash operations.
/// Implementations must convert data-layer exceptions into [Failure]s.
abstract class DocumentRepository {
  // ── Documents ─────────────────────────────────────────────────────

  /// Retrieves all documents, optionally filtered by folder or tag.
  ///
  /// Returns a list of [ScannedDocument]s, or a [CacheFailure] on error.
  Future<Either<Failure, List<ScannedDocument>>> getDocuments({
    String? folderId,
    String? tag,
    bool includeDeleted = false,
  });

  /// Retrieves a single document by [documentId].
  ///
  /// Returns the [ScannedDocument], or a [NotFoundFailure] if not found.
  Future<Either<Failure, ScannedDocument>> getDocumentById(String documentId);

  /// Moves a document to the trash by [documentId].
  Future<Either<Failure, Unit>> moveToTrash(String documentId);

  /// Restores a document from the trash by [documentId].
  Future<Either<Failure, Unit>> restoreFromTrash(String documentId);

  /// Permanently deletes a document by [documentId].
  Future<Either<Failure, Unit>> permanentDelete(String documentId);

  /// Empties the trash, permanently deleting all trashed documents.
  Future<Either<Failure, Unit>> emptyTrash();

  /// Retrieves all documents currently in the trash.
  Future<Either<Failure, List<ScannedDocument>>> getTrashedDocuments();

  /// Toggles the favourite status of a document.
  Future<Either<Failure, ScannedDocument>> toggleFavorite(String documentId);

  /// Retrieves all favourite documents.
  Future<Either<Failure, List<ScannedDocument>>> getFavoriteDocuments();

  /// Moves a document to a folder.
  Future<Either<Failure, ScannedDocument>> moveDocumentToFolder({
    required String documentId,
    String? folderId,
  });

  /// Adds a tag to a document.
  Future<Either<Failure, ScannedDocument>> addTagToDocument({
    required String documentId,
    required String tag,
  });

  /// Removes a tag from a document.
  Future<Either<Failure, ScannedDocument>> removeTagFromDocument({
    required String documentId,
    required String tag,
  });

  /// Renames a document.
  Future<Either<Failure, ScannedDocument>> renameDocument({
    required String documentId,
    required String newName,
  });

  // ── Folders ───────────────────────────────────────────────────────

  /// Retrieves all folders.
  Future<Either<Failure, List<DocumentFolder>>> getFolders();

  /// Creates a new folder.
  Future<Either<Failure, DocumentFolder>> createFolder({
    required String name,
    String? color,
    String? icon,
    String? parentFolderId,
  });

  /// Renames an existing folder.
  Future<Either<Failure, DocumentFolder>> renameFolder({
    required String folderId,
    required String newName,
  });

  /// Deletes a folder by [folderId].
  Future<Either<Failure, Unit>> deleteFolder(String folderId);

  // ── Tags ──────────────────────────────────────────────────────────

  /// Retrieves all tags.
  Future<Either<Failure, List<DocumentTag>>> getTags();

  /// Creates a new tag.
  Future<Either<Failure, DocumentTag>> createTag({
    required String name,
    String? color,
  });

  /// Deletes a tag by [tagId].
  Future<Either<Failure, Unit>> deleteTag(String tagId);
}
