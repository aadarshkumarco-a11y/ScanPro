import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/qr_scanner/domain/entities/qr_result.dart';

/// Abstract repository contract for QR code scanning operations.
///
/// Defines the domain-level API for scanning QR codes, retrieving
/// scan history, and deleting results. Implementations must convert
/// data-layer exceptions into [Failure]s.
abstract class QrRepository {
  /// Saves a newly scanned QR code result.
  Future<Either<Failure, QrResult>> scanQr(QrResult result);

  /// Retrieves the full QR scan history, most recent first.
  Future<Either<Failure, List<QrResult>>> getQrHistory();

  /// Deletes a QR scan result by [id].
  Future<Either<Failure, Unit>> deleteQrResult(String id);
}
