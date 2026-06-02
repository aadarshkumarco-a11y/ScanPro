import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';

/// Use case for scanning a single document page.
///
/// Invokes [ScannerRepository.scanDocument] and returns the result
/// as [Either<Failure, ScannedDocument>].
class ScanDocumentUseCase {
  const ScanDocumentUseCase(this._repository);

  final ScannerRepository _repository;

  /// Captures a document from the camera.
  ///
  /// Returns a [ScannerFailure] if the camera is unavailable
  /// or permission is denied.
  Future<Either<Failure, ScannedDocument>> call() async {
    return _repository.scanDocument();
  }
}
