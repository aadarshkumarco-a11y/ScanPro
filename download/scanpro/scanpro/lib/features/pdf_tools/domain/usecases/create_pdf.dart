import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_document.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';

/// Parameters for the create PDF use case.
class CreatePDFParams extends Equatable {
  /// List of absolute image paths to include in the PDF.
  final List<String> imagePaths;

  /// Display title for the PDF document.
  final String? title;

  /// Quality setting for image compression in the PDF (0-100).
  final int quality;

  const CreatePDFParams({
    required this.imagePaths,
    this.title,
    this.quality = 85,
  });

  @override
  List<Object?> get props => [imagePaths, title, quality];
}

/// Use case for creating a new PDF document from scanned images.
///
/// Takes a list of image paths and generates a single PDF document
/// with configurable quality settings and an optional title.
class CreatePDF implements UseCase<PDFDocument, CreatePDFParams> {
  final PDFRepository _repository;

  CreatePDF(this._repository);

  @override
  Future<Either<Failure, PDFDocument>> call(CreatePDFParams params) async {
    if (params.imagePaths.isEmpty) {
      return const Left(
        ValidationFailure(message: 'At least one image is required'),
      );
    }
    if (params.quality < 0 || params.quality > 100) {
      return const Left(
        ValidationFailure(message: 'Quality must be between 0 and 100'),
      );
    }
    return _repository.createPDF(
      params.imagePaths,
      title: params.title,
    );
  }
}
