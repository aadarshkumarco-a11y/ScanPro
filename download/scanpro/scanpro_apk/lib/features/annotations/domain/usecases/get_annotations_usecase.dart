import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/annotations/domain/entities/annotation.dart';
import 'package:scanpro/features/annotations/domain/repositories/annotation_repository.dart';

/// Use case for retrieving annotations for a document.
///
/// Supports fetching all annotations for a document or filtering
/// by a specific page number.
class GetAnnotationsUseCase {
  const GetAnnotationsUseCase(this._repository);

  final AnnotationRepository _repository;

  /// Retrieves all annotations for the given [documentId].
  ///
  /// Returns a list of [Annotation]s ordered by page, then creation time.
  Future<Either<Failure, List<Annotation>>> getByDocument(
    String documentId,
  ) async {
    if (documentId.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Document ID'));
    }

    return _repository.getAnnotationsByDocument(documentId);
  }

  /// Retrieves annotations for a specific [documentId] and [page].
  ///
  /// Returns annotations for that page ordered by creation time.
  Future<Either<Failure, List<Annotation>>> getByPage(
    String documentId,
    int page,
  ) async {
    if (documentId.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Document ID'));
    }

    if (page < 0) {
      return Left(ValidationFailure.outOfRange('Page number'));
    }

    return _repository.getAnnotationsByPage(documentId, page);
  }
}
