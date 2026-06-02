import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_operation.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';

/// Parameters for the split PDF use case.
class SplitPDFParams extends Equatable {
  /// Absolute path to the source PDF file.
  final String pdfPath;

  /// List of page range strings (e.g., ['1-3', '4-6', '7-10']).
  final List<String> ranges;

  const SplitPDFParams({
    required this.pdfPath,
    required this.ranges,
  });

  @override
  List<Object?> get props => [pdfPath, ranges];
}

/// Use case for splitting a PDF into multiple documents.
///
/// Takes a PDF path and page ranges, producing separate PDF files
/// for each range specification.
class SplitPDF implements UseCase<PDFOperationResult, SplitPDFParams> {
  final PDFRepository _repository;

  SplitPDF(this._repository);

  @override
  Future<Either<Failure, PDFOperationResult>> call(
    SplitPDFParams params,
  ) async {
    if (params.pdfPath.isEmpty) {
      return const Left(
        ValidationFailure(message: 'PDF path cannot be empty'),
      );
    }
    if (params.ranges.isEmpty) {
      return const Left(
        ValidationFailure(message: 'At least one page range is required'),
      );
    }
    return _repository.splitPDF(params.pdfPath, params.ranges);
  }
}
