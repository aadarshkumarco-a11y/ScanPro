import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_document.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';

/// Use case for creating a PDF from images.
///
/// Validates the input image list and delegates to [PdfRepository]
/// for the actual PDF creation. Returns [PdfDocument] on success
/// or a [Failure] on error.
class CreatePdfUseCase {
  const CreatePdfUseCase(this._repository);

  final PdfRepository _repository;

  /// Executes PDF creation from the given [imagePaths].
  ///
  /// [fileName] optionally specifies the output file name.
  /// Returns a [ValidationFailure] if the image list is empty,
  /// or delegates to the repository for processing.
  Future<Either<Failure, PdfDocument>> call({
    required List<String> imagePaths,
    String fileName = 'ScanPro_Document',
  }) async {
    if (imagePaths.isEmpty) {
      return Left(ValidationFailure.emptyField('Image list'));
    }

    return _repository.createPdf(
      imagePaths: imagePaths,
      fileName: fileName,
    );
  }
}
