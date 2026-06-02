import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/core/constants/app_constants.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_document.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';

/// Use case for merging multiple PDF files into one.
///
/// Validates that at least two PDFs are provided and that the
/// list does not exceed the maximum merge limit.
class MergePdfUseCase {
  const MergePdfUseCase(this._repository);

  final PdfRepository _repository;

  /// Executes PDF merge on the given [pdfPaths].
  ///
  /// [outputFileName] optionally specifies the output file name.
  /// Returns a [ValidationFailure] if fewer than two PDFs are
  /// provided or the maximum limit is exceeded.
  Future<Either<Failure, PdfDocument>> call({
    required List<String> pdfPaths,
    String outputFileName = 'ScanPro_Merged',
  }) async {
    if (pdfPaths.isEmpty) {
      return Left(ValidationFailure.emptyField('PDF list'));
    }

    if (pdfPaths.length < 2) {
      return const Left(ValidationFailure(
        message: 'At least two PDFs are required for merging.',
        code: 10001,
      ));
    }

    if (pdfPaths.length > AppConstants.pdfMaxMergeFiles) {
      return Left(ValidationFailure.outOfRange('PDF list'));
    }

    return _repository.mergePdfs(
      pdfPaths: pdfPaths,
      outputFileName: outputFileName,
    );
  }
}
