import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_operation.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';

/// Parameters for the compress PDF use case.
class CompressPDFParams extends Equatable {
  /// Absolute path to the source PDF file.
  final String pdfPath;

  /// Compression quality (0-100, where 100 is lossless and lower means more compression).
  final int quality;

  /// Whether to also compress images within the PDF.
  final bool compressImages;

  const CompressPDFParams({
    required this.pdfPath,
    this.quality = 75,
    this.compressImages = true,
  });

  @override
  List<Object?> get props => [pdfPath, quality, compressImages];
}

/// Use case for compressing a PDF to reduce file size.
///
/// Applies image recompression and stream optimization to reduce
/// the overall PDF file size while maintaining acceptable quality.
class CompressPDF implements UseCase<PDFOperationResult, CompressPDFParams> {
  final PDFRepository _repository;

  CompressPDF(this._repository);

  @override
  Future<Either<Failure, PDFOperationResult>> call(
    CompressPDFParams params,
  ) async {
    if (params.pdfPath.isEmpty) {
      return const Left(
        ValidationFailure(message: 'PDF path cannot be empty'),
      );
    }
    if (params.quality < 0 || params.quality > 100) {
      return const Left(
        ValidationFailure(message: 'Quality must be between 0 and 100'),
      );
    }
    return _repository.compressPDF(
      params.pdfPath,
      quality: params.quality,
    );
  }
}
