import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/ocr/domain/repositories/ocr_repository.dart';

/// Parameters for the translate text use case.
class TranslateTextParams extends Equatable {
  /// Source text to translate.
  final String text;

  /// Target language code (ISO 639-1, e.g., 'es', 'fr', 'de').
  final String targetLanguage;

  /// Source language code. If null, the language will be auto-detected.
  final String? sourceLanguage;

  const TranslateTextParams({
    required this.text,
    required this.targetLanguage,
    this.sourceLanguage,
  });

  @override
  List<Object?> get props => [text, targetLanguage, sourceLanguage];
}

/// Use case for translating OCR-extracted text to another language.
///
/// Supports auto-detection of the source language and translation
/// to any supported target language.
class TranslateText implements UseCase<String, TranslateTextParams> {
  final OCRRepository _repository;

  TranslateText(this._repository);

  @override
  Future<Either<Failure, String>> call(TranslateTextParams params) async {
    if (params.text.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Text cannot be empty for translation'),
      );
    }
    if (params.targetLanguage.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Target language code is required'),
      );
    }
    if (params.targetLanguage.trim().length != 2) {
      return const Left(
        ValidationFailure(
          message: 'Target language must be a valid ISO 639-1 code',
        ),
      );
    }
    return _repository.translateText(
      params.text.trim(),
      params.targetLanguage.trim(),
    );
  }
}
