import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/exceptions.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/qr_scanner/data/datasources/qr_local_datasource.dart';
import 'package:scanpro/features/qr_scanner/domain/entities/qr_result.dart';
import 'package:scanpro/features/qr_scanner/domain/repositories/qr_repository.dart';

/// Concrete implementation of [QrRepository].
///
/// Delegates local persistence to [QrLocalDatasource] and
/// converts all exceptions to appropriate [Failure] subclasses.
class QrRepositoryImpl implements QrRepository {
  QrRepositoryImpl({
    required QrLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  final QrLocalDatasource _localDatasource;

  @override
  Future<Either<Failure, QrResult>> scanQr(QrResult result) async {
    try {
      final model = await _localDatasource.saveQrResult(result);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to save QR result: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, List<QrResult>>> getQrHistory() async {
    try {
      final models = _localDatasource.getQrHistory();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get QR history: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteQrResult(String id) async {
    try {
      await _localDatasource.deleteQrResult(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to delete QR result: ${e.toString()}',
        code: 1002,
      ));
    }
  }
}
