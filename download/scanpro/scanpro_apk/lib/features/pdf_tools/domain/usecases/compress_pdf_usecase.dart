import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/core/constants/app_constants.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_operation.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';

/// Use case for compressing a PDF file.
///
/// Validates the quality parameter is within acceptable range
/// and delegates to [PdfRepository] for the actual compression.
class CompressPdfUseCase {
  const CompressPdfUseCase(this._repository);

  final PdfRepository _repository;

  /// Executes PDF compression on the file at [pdfPath].
  ///
  /// [quality] is the compression quality (0.0 to 1.0).
  /// Returns a [ValidationFailure] if the path is empty or
  /// the quality is out of the 0.0–1.0 range.
  Future<Either<Failure, PdfOperationResult>> call({
    required String pdfPath,
    required double quality,
  }) async {
    if (pdfPath.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('PDF file path'));
    }

    if (quality < 0.0 || quality > 1.0) {
      return Left(ValidationFailure.outOfRange('Quality'));
    }

    return _repository.compressPdf(
      pdfPath: pdfPath,
      quality: quality,
    );
  }
}
