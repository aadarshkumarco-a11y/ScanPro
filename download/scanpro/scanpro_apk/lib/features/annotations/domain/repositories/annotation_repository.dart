import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/annotations/domain/entities/annotation.dart';

/// Abstract repository contract for annotation operations.
///
/// Defines the domain-level API for adding, updating, deleting,
/// and querying annotations on document pages.
abstract class AnnotationRepository {
  /// Adds a new annotation.
  ///
  /// Returns the saved [Annotation] with generated ID and timestamps.
  Future<Either<Failure, Annotation>> addAnnotation(Annotation annotation);

  /// Updates an existing annotation.
  ///
  /// Returns the updated [Annotation] with refreshed [updatedAt].
  Future<Either<Failure, Annotation>> updateAnnotation(Annotation annotation);

  /// Deletes an annotation by [annotationId].
  Future<Either<Failure, Unit>> deleteAnnotation(String annotationId);

  /// Retrieves all annotations for a given [documentId].
  ///
  /// Returns annotations ordered by page, then creation time.
  Future<Either<Failure, List<Annotation>>> getAnnotationsByDocument(
    String documentId,
  );

  /// Retrieves annotations for a specific [documentId] and [page].
  ///
  /// Returns annotations for that page ordered by creation time.
  Future<Either<Failure, List<Annotation>>> getAnnotationsByPage(
    String documentId,
    int page,
  );
}
