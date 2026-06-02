import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_operation.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';

/// Parameters for the merge PDFs use case.
class MergePDFsParams extends Equatable {
  /// List of absolute PDF file paths to merge.
  final List<String> pdfPaths;

  /// Display title for the merged PDF.
  final String? outputTitle;

  const MergePDFsParams({
    required this.pdfPaths,
    this.outputTitle,
  });

  @override
  List<Object?> get props => [pdfPaths, outputTitle];
}

/// Use case for merging multiple PDF files into a single document.
///
/// Takes two or more PDF file paths and combines them in the
/// specified order into a single output PDF.
class MergePDFs implements UseCase<PDFOperationResult, MergePDFsParams> {
  final PDFRepository _repository;

  MergePDFs(this._repository);

  @override
  Future<Either<Failure, PDFOperationResult>> call(
    MergePDFsParams params,
  ) async {
    if (params.pdfPaths.length < 2) {
      return const Left(
        ValidationFailure(message: 'At least two PDF files are required to merge'),
      );
    }
    return _repository.mergePDFs(
      params.pdfPaths,
      outputTitle: params.outputTitle,
    );
  }
}
