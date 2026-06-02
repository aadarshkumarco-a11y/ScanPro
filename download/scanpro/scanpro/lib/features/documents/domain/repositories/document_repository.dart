import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';

/// Abstract repository defining the contract for document management operations.
///
/// Provides CRUD operations, filtering, searching, and organization
/// features for scanned documents.
abstract class DocumentRepository {
  /// Retrieves all documents with optional filtering.
  ///
  /// Returns a list of [ScanDocument] entities, or a [Failure].
  Future<Either<Failure, List<ScanDocument>>> getDocuments();

  /// Retrieves a single document by its [id].
  ///
  /// Returns the [ScanDocument] if found, or a [NotFoundFailure].
  Future<Either<Failure, ScanDocument>> getDocument(String id);

  /// Creates a new document record.
  ///
  /// [document] is the entity to persist.
  /// Returns the created [ScanDocument] with any server-assigned fields.
  Future<Either<Failure, ScanDocument>> createDocument(
    ScanDocument document,
  );

  /// Updates an existing document.
  ///
  /// [document] contains the updated fields (must have a valid [id]).
  /// Returns the updated [ScanDocument].
  Future<Either<Failure, ScanDocument>> updateDocument(
    ScanDocument document,
  );

  /// Soft-deletes a document by marking it as deleted.
  ///
  /// [id] is the document identifier.
  /// Returns unit on success or a [Failure].
  Future<Either<Failure, Unit>> deleteDocument(String id);

  /// Restores a previously soft-deleted document.
  ///
  /// [id] is the document identifier.
  /// Returns the restored [ScanDocument].
  Future<Either<Failure, ScanDocument>> restoreDocument(String id);

  /// Retrieves all documents marked as favorites.
  Future<Either<Failure, List<ScanDocument>>> getFavorites();

  /// Retrieves recently accessed documents.
  ///
  /// [limit] specifies the maximum number of documents to return.
  Future<Either<Failure, List<ScanDocument>>> getRecent({int limit = 10});

  /// Retrieves documents in a specific folder.
  ///
  /// [folderId] is the folder identifier. Pass null for root-level documents.
  Future<Either<Failure, List<ScanDocument>>> getByFolder(String? folderId);

  /// Retrieves documents with a specific tag.
  ///
  /// [tagId] is the tag identifier.
  Future<Either<Failure, List<ScanDocument>>> getByTag(String tagId);

  /// Searches documents by title and OCR text content.
  ///
  /// [query] is the search string.
  /// Returns matching documents ranked by relevance.
  Future<Either<Failure, List<ScanDocument>>> searchDocuments(
    String query,
  );
}
