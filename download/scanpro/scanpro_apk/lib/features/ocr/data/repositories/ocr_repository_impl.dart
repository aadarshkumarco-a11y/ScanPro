import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../datasources/ocr_local_datasource.dart';
import '../datasources/ocr_ml_datasource.dart';
import '../models/ocr_result_model.dart';

/// Concrete implementation of [OcrRepository].
///
/// Delegates text recognition to [OcrMlDatasource] using Google ML Kit,
/// and persistence to [OcrLocalDatasource] using Hive. All exceptions
/// are caught and converted to the appropriate [Failure] subclass.
class OcrRepositoryImpl implements OcrRepository {
  OcrRepositoryImpl({
    required OcrMlDatasource mlDatasource,
    required OcrLocalDatasource localDatasource,
  })  : _mlDatasource = mlDatasource,
        _localDatasource = localDatasource;

  final OcrMlDatasource _mlDatasource;
  final OcrLocalDatasource _localDatasource;

  // ── Recognize Text ───────────────────────────────────────────────

  @override
  Future<Either<Failure, OcrResult>> recognizeText({
    required String imagePath,
    String language = 'en',
  }) async {
    try {
      final result = await _mlDatasource.recognizeText(
        imagePath: imagePath,
        documentId: '', // Will be set by caller
        language: language,
      );

      final saved = await _localDatasource.saveOcrResult(result);
      return Right(saved.toEntity());
    } on OcrException catch (e) {
      return Left(OcrFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(OcrFailure.processingError());
    }
  }

  // ── Recognize Text From Path ─────────────────────────────────────

  @override
  Future<Either<Failure, OcrResult>> recognizeTextFromPath({
    required String filePath,
    String language = 'en',
  }) async {
    try {
      final result = await _mlDatasource.recognizeText(
        imagePath: filePath,
        documentId: '',
        language: language,
      );

      final saved = await _localDatasource.saveOcrResult(result);
      return Right(saved.toEntity());
    } on OcrException catch (e) {
      return Left(OcrFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(OcrFailure.processingError());
    }
  }

  // ── Get OCR Results ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<OcrResult>>> getOcrResults() async {
    try {
      final models = _localDatasource.getOcrResults();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get OCR results: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  // ── Get OCR Result By Document ID ────────────────────────────────

  @override
  Future<Either<Failure, OcrResult>> getOcrResultByDocumentId(
    String documentId,
  ) async {
    try {
      final model = _localDatasource.getOcrResultByDocumentId(documentId);
      if (model == null) {
        return Left(NotFoundFailure.document());
      }
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get OCR result: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  // ── Delete OCR Result ────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> deleteOcrResult(String ocrResultId) async {
    try {
      await _localDatasource.deleteOcrResult(ocrResultId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to delete OCR result: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  // ── Extract Text Regions ─────────────────────────────────────────

  @override
  Future<Either<Failure, OcrResult>> extractTextRegions({
    required String imagePath,
    String language = 'en',
  }) async {
    try {
      final result = await _mlDatasource.extractTextRegions(
        imagePath: imagePath,
        documentId: '',
        language: language,
      );

      final saved = await _localDatasource.saveOcrResult(result);
      return Right(saved.toEntity());
    } on OcrException catch (e) {
      return Left(OcrFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(OcrFailure.processingError());
    }
  }
}
