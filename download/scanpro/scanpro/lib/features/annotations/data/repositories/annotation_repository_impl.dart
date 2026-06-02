import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/annotations/domain/entities/annotation.dart';
import 'package:scanpro/features/annotations/domain/repositories/annotation_repository.dart';
import 'package:scanpro/features/annotations/data/models/annotation_model.dart';

/// Implementation of [AnnotationRepository] using Hive for local storage.
///
/// Manages annotation CRUD operations with efficient page-level
/// querying through in-memory filtering of the Hive box.
class AnnotationRepositoryImpl implements AnnotationRepository {
  final Box<AnnotationModel> _annotationBox;

  static const String _annotationsBoxName = 'annotations';

  AnnotationRepositoryImpl({
    required Box<AnnotationModel> annotationBox,
  }) : _annotationBox = annotationBox;

  @override
  Future<Either<Failure, Annotation>> addAnnotation(
    Annotation annotation,
  ) async {
    try {
      final model = AnnotationModel.fromEntity(annotation);
      await _annotationBox.put(annotation.id, model);
      return Right(annotation);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to add annotation: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Annotation>>> getAnnotations(
    String documentId,
  ) async {
    try {
      final annotations = _annotationBox.values
          .where((model) => model.documentId == documentId)
          .map((model) => model.toEntity())
          .toList()
        ..sort((a, b) {
          final pageCompare = a.pageIndex.compareTo(b.pageIndex);
          if (pageCompare != 0) return pageCompare;
          return a.createdAt.compareTo(b.createdAt);
        });
      return Right(annotations);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to get annotations: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Annotation>> updateAnnotation(
    Annotation annotation,
  ) async {
    try {
      final existingModel = _annotationBox.get(annotation.id);
      if (existingModel == null) {
        return Left(
          NotFoundFailure(
            message: 'Annotation not found: ${annotation.id}',
          ),
        );
      }

      final model = AnnotationModel.fromEntity(annotation);
      await _annotationBox.put(annotation.id, model);
      return Right(annotation);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to update annotation: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAnnotation(String id) async {
    try {
      final model = _annotationBox.get(id);
      if (model == null) {
        return Left(
          NotFoundFailure(message: 'Annotation not found: $id'),
        );
      }
      await _annotationBox.delete(id);
      return const Right(unit);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to delete annotation: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Annotation>>> getAnnotationsByPage(
    String documentId,
    int pageIndex,
  ) async {
    try {
      final annotations = _annotationBox.values
          .where((model) =>
              model.documentId == documentId &&
              model.pageIndex == pageIndex)
          .map((model) => model.toEntity())
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return Right(annotations);
    } catch (e) {
      return Left(
        StorageFailure(
          message: 'Failed to get annotations by page: $e',
        ),
      );
    }
  }
}
