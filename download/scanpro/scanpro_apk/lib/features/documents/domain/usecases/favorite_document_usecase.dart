import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';

/// Use case for toggling the favourite status of a document.
class FavoriteDocumentUseCase {
  const FavoriteDocumentUseCase(this._repository);

  final DocumentRepository _repository;

  /// Toggles the favourite flag on the document identified by [documentId].
  ///
  /// Returns the updated [ScannedDocument] with the new favourite status,
  /// or a [NotFoundFailure] if the document does not exist.
  Future<Either<Failure, ScannedDocument>> call(String documentId) async {
    if (documentId.isEmpty) {
      return Left(ValidationFailure.emptyField('documentId'));
    }
    return _repository.toggleFavorite(documentId);
  }

  /// Retrieves all documents marked as favourite.
  Future<Either<Failure, List<ScannedDocument>>> getFavorites() async {
    return _repository.getFavoriteDocuments();
  }
}
