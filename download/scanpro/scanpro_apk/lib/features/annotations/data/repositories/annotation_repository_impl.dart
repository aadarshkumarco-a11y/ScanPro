import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/annotation.dart';
import '../../domain/repositories/annotation_repository.dart';
import '../datasources/annotation_local_datasource.dart';
import '../models/annotation_model.dart';

/// Concrete implementation of [AnnotationRepository].
///
/// Delegates local persistence to [AnnotationLocalDatasource].
/// All exceptions are caught and converted to the appropriate
/// [Failure] subclass.
class AnnotationRepositoryImpl implements AnnotationRepository {
  AnnotationRepositoryImpl({
    required AnnotationLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  final AnnotationLocalDatasource _localDatasource;

  // ── Add ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Annotation>> addAnnotation(
    Annotation annotation,
  ) async {
    try {
      final saved = await _localDatasource.addAnnotation(annotation);
      return Right(saved.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to add annotation: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  // ── Update ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Annotation>> updateAnnotation(
    Annotation annotation,
  ) async {
    try {
      final updated = await _localDatasource.updateAnnotation(annotation);
      return Right(updated.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to update annotation: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  // ── Delete ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> deleteAnnotation(String annotationId) async {
    try {
      await _localDatasource.deleteAnnotation(annotationId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to delete annotation: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  // ── Get By Document ────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Annotation>>> getAnnotationsByDocument(
    String documentId,
  ) async {
    try {
      final models = _localDatasource.getAnnotationsByDocument(documentId);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get annotations: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  // ── Get By Page ────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Annotation>>> getAnnotationsByPage(
    String documentId,
    int page,
  ) async {
    try {
      final models =
          _localDatasource.getAnnotationsByPage(documentId, page);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get annotations for page: ${e.toString()}',
        code: 1003,
      ));
    }
  }
}
