import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';

/// Abstract repository defining the contract for OCR operations.
///
/// Provides text extraction, smart action detection, and translation
/// capabilities powered by ML Kit and cloud services.
abstract class OCRRepository {
  /// Extracts text from a scanned document.
  ///
  /// [document] is the source document to process.
  /// Returns an [OCRResult] with the extracted text and metadata.
  Future<Either<Failure, OCRResult>> extractText(ScanDocument document);

  /// Retrieves a previously stored OCR result.
  ///
  /// [documentId] is the document identifier.
  /// Returns the [OCRResult] if available, or a [NotFoundFailure].
  Future<Either<Failure, OCRResult>> getOCRResult(String documentId);

  /// Retrieves OCR history for all processed documents.
  ///
  /// Returns a list of [OCRResult] ordered by creation date.
  Future<Either<Failure, List<OCRResult>>> getOCRHistories();

  /// Detects smart actions (phone, email, URL, address, date) in text.
  ///
  /// [text] is the source text to analyze.
  /// Returns the [OCRResult] updated with detected smart actions.
  Future<Either<Failure, OCRResult>> detectSmartActions(String text);

  /// Translates text to the specified target language.
  ///
  /// [text] is the source text.
  /// [targetLanguage] is the ISO 639-1 language code (e.g., 'es', 'fr').
  /// Returns the translated text string.
  Future<Either<Failure, String>> translateText(
    String text,
    String targetLanguage,
  );
}
