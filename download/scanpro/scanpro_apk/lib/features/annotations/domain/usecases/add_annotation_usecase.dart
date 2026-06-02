import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/annotations/domain/entities/annotation.dart';
import 'package:scanpro/features/annotations/domain/repositories/annotation_repository.dart';

/// Use case for adding a new annotation to a document.
///
/// Validates the annotation data before delegating to
/// [AnnotationRepository.addAnnotation].
class AddAnnotationUseCase {
  const AddAnnotationUseCase(this._repository);

  final AnnotationRepository _repository;

  /// Executes the add annotation operation.
  ///
  /// [annotation] – the annotation to add.
  /// Validates that the document ID is not empty, the page is
  /// non-negative, and the data map is not empty.
  Future<Either<Failure, Annotation>> call(Annotation annotation) async {
    if (annotation.documentId.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Document ID'));
    }

    if (annotation.page < 0) {
      return Left(ValidationFailure.outOfRange('Page number'));
    }

    if (annotation.data.isEmpty) {
      return Left(ValidationFailure.emptyField('Annotation data'));
    }

    return _repository.addAnnotation(annotation);
  }
}
