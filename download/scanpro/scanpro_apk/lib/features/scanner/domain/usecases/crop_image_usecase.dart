import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';

/// Use case for cropping a scanned image.
///
/// Accepts a [filePath], a [cropArea] (normalised rectangle), and the
/// parent [ScannedDocument]. Returns the updated document with the
/// cropped image path.
class CropImageUseCase {
  const CropImageUseCase(this._repository);

  final ScannerRepository _repository;

  /// Crops the image at [filePath] to the given [cropArea].
  ///
  /// [cropArea] must contain exactly four doubles in the range 0.0–1.0:
  /// `[left, top, right, bottom]`.
  ///
  /// Returns a [ValidationFailure] if [cropArea] is malformed,
  /// or a [ScannerFailure] if the image cannot be processed.
  Future<Either<Failure, ScannedDocument>> call({
    required String filePath,
    required List<double> cropArea,
    required ScannedDocument document,
  }) async {
    // Validate crop area
    if (cropArea.length != 4) {
      return Left(ValidationFailure.invalidFormat('cropArea'));
    }
    for (final v in cropArea) {
      if (v < 0.0 || v > 1.0) {
        return Left(ValidationFailure.outOfRange('cropArea'));
      }
    }
    if (cropArea[0] >= cropArea[2] || cropArea[1] >= cropArea[3]) {
      return Left(ValidationFailure.invalidFormat('cropArea'));
    }
    if (filePath.isEmpty) {
      return Left(ValidationFailure.emptyField('filePath'));
    }

    return _repository.cropImage(
      filePath: filePath,
      cropArea: cropArea,
      document: document,
    );
  }
}
