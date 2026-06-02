import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_document.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';

/// Use case for splitting a PDF by page ranges.
///
/// Validates that page ranges are provided and delegates to
/// [PdfRepository] for the actual split operation.
class SplitPdfUseCase {
  const SplitPdfUseCase(this._repository);

  final PdfRepository _repository;

  /// Executes PDF split on the file at [pdfPath].
  ///
  /// [pageRanges] is a list of page range strings (e.g. ['1-3', '5']).
  /// Returns a [ValidationFailure] if no page ranges are provided
  /// or the path is empty.
  Future<Either<Failure, List<PdfDocument>>> call({
    required String pdfPath,
    required List<String> pageRanges,
  }) async {
    if (pdfPath.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('PDF file path'));
    }

    if (pageRanges.isEmpty) {
      return Left(ValidationFailure.emptyField('Page ranges'));
    }

    return _repository.splitPdf(
      pdfPath: pdfPath,
      pageRanges: pageRanges,
    );
  }
}
