import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';

/// Use case for enhancing a scanned image.
///
/// Applies automatic brightness, contrast, and sharpness adjustments
/// to improve document readability.
class EnhanceImageUseCase {
  const EnhanceImageUseCase(this._repository);

  final ScannerRepository _repository;

  /// Enhances the image at [filePath] belonging to [document].
  ///
  /// Returns the updated [ScannedDocument] with the enhanced image path,
  /// or a [ScannerFailure] if the image cannot be processed.
  Future<Either<Failure, ScannedDocument>> call({
    required String filePath,
    required ScannedDocument document,
  }) async {
    if (filePath.isEmpty) {
      return Left(ValidationFailure.emptyField('filePath'));
    }

    return _repository.enhanceImage(
      filePath: filePath,
      document: document,
    );
  }
}
