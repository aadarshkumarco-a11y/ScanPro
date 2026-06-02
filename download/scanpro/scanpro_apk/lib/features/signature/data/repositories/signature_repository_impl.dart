import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/signature.dart';
import '../../domain/repositories/signature_repository.dart';
import '../datasources/signature_local_datasource.dart';
import '../models/signature_model.dart';

/// Concrete implementation of [SignatureRepository].
///
/// Delegates local persistence to [SignatureLocalDatasource].
/// All exceptions are caught and converted to the appropriate
/// [Failure] subclass.
class SignatureRepositoryImpl implements SignatureRepository {
  SignatureRepositoryImpl({
    required SignatureLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  final SignatureLocalDatasource _localDatasource;

  // ── Save ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Signature>> saveSignature(
    Signature signature,
  ) async {
    try {
      final saved = await _localDatasource.saveSignature(signature);
      return Right(saved.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to save signature: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  // ── Get All ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Signature>>> getSignatures() async {
    try {
      final models = _localDatasource.getSignatures();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get signatures: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  // ── Delete ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> deleteSignature(String signatureId) async {
    try {
      await _localDatasource.deleteSignature(signatureId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to delete signature: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  // ── Set Default ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Signature>> setDefaultSignature(
    String signatureId,
  ) async {
    try {
      final updated = await _localDatasource.setDefaultSignature(signatureId);
      return Right(updated.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to set default signature: ${e.toString()}',
        code: 1002,
      ));
    }
  }
}
