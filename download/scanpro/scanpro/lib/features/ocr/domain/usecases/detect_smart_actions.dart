import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';
import 'package:scanpro/features/ocr/domain/repositories/ocr_repository.dart';

/// Parameters for the detect smart actions use case.
class DetectSmartActionsParams extends Equatable {
  /// The text to analyze for smart actions.
  final String text;

  const DetectSmartActionsParams({required this.text});

  @override
  List<Object?> get props => [text];
}

/// Use case for detecting smart actions in OCR-extracted text.
///
/// Analyzes text content for actionable entities such as phone numbers,
/// email addresses, URLs, physical addresses, and dates.
class DetectSmartActions
    implements UseCase<OCRResult, DetectSmartActionsParams> {
  final OCRRepository _repository;

  DetectSmartActions(this._repository);

  @override
  Future<Either<Failure, OCRResult>> call(
    DetectSmartActionsParams params,
  ) async {
    if (params.text.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Text cannot be empty for smart action detection'),
      );
    }
    return _repository.detectSmartActions(params.text.trim());
  }
}
