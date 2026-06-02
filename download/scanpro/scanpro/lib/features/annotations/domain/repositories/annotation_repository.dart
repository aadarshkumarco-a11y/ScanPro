import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/annotations/domain/entities/annotation.dart';

/// Abstract repository defining the contract for annotation management.
///
/// Provides CRUD operations for document annotations with support
/// for page-level filtering.
abstract class AnnotationRepository {
  /// Adds a new annotation to a document.
  ///
  /// [annotation] is the annotation entity to create.
  /// Returns the created [Annotation] with any assigned fields.
  Future<Either<Failure, Annotation>> addAnnotation(Annotation annotation);

  /// Retrieves all annotations for a document.
  ///
  /// [documentId] is the document identifier.
  /// Returns a list of [Annotation] entities ordered by page and position.
  Future<Either<Failure, List<Annotation>>> getAnnotations(String documentId);

  /// Updates an existing annotation.
  ///
  /// [annotation] is the annotation entity with updated fields.
  /// Returns the updated [Annotation].
  Future<Either<Failure, Annotation>> updateAnnotation(Annotation annotation);

  /// Deletes an annotation.
  ///
  /// [id] is the annotation identifier.
  /// Returns unit on success.
  Future<Either<Failure, Unit>> deleteAnnotation(String id);

  /// Retrieves annotations for a specific page of a document.
  ///
  /// [documentId] is the document identifier.
  /// [pageIndex] is the 0-based page index.
  /// Returns a list of [Annotation] entities on that page.
  Future<Either<Failure, List<Annotation>>> getAnnotationsByPage(
    String documentId,
    int pageIndex,
  );
}
