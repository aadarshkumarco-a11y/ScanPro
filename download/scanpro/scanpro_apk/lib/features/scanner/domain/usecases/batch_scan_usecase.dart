import 'package:dartz/dartz.dart';
import 'package:scanpro/core/constants/app_constants.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';

/// Use case for batch scanning multiple document pages.
///
/// Captures [pageCount] pages sequentially and returns a single
/// [ScannedDocument] containing all pages.
class BatchScanUseCase {
  const BatchScanUseCase(this._repository);

  final ScannerRepository _repository;

  /// Initiates a batch scan for [pageCount] pages.
  ///
  /// Returns a [ValidationFailure] if [pageCount] is out of range,
  /// or a [ScannerFailure] if the camera fails during capture.
  Future<Either<Failure, ScannedDocument>> call({
    required int pageCount,
  }) async {
    if (pageCount <= 0) {
      return Left(ValidationFailure.outOfRange('pageCount'));
    }
    if (pageCount > AppConstants.maxBatchScanPages) {
      return Left(ValidationFailure.outOfRange('pageCount'));
    }

    return _repository.batchScan(pageCount: pageCount);
  }
}
