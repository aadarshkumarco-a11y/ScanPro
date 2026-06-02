import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/ocr/domain/repositories/ocr_repository.dart';

/// Parameters for the extract text use case.
class ExtractTextParams extends Equatable {
  /// The document to extract text from.
  final ScanDocument document;

  /// Whether to detect smart actions in the extracted text.
  final bool detectActions;

  const ExtractTextParams({
    required this.document,
    this.detectActions = true,
  });

  @override
  List<Object?> get props => [document, detectActions];
}

/// Use case for extracting text from a scanned document using OCR.
///
/// Performs OCR on the document image and optionally detects
/// smart actions (phone numbers, emails, URLs, etc.) in the result.
class ExtractText implements UseCase<OCRResult, ExtractTextParams> {
  final OCRRepository _repository;

  ExtractText(this._repository);

  @override
  Future<Either<Failure, OCRResult>> call(ExtractTextParams params) async {
    if (params.document.filePath.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Document file path cannot be empty'),
      );
    }

    final result = await _repository.extractText(params.document);

    if (params.detectActions) {
      return result.fold(
        (failure) => Left(failure),
        (ocrResult) async {
          if (ocrResult.text.isEmpty) return Right(ocrResult);
          return _repository.detectSmartActions(ocrResult.text);
        },
      );
    }

    return result;
  }
}
