import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_summary.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_extraction.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';

/// Abstract repository defining the contract for AI-powered features.
///
/// Provides document intelligence capabilities including summarization,
/// categorization, tagging, translation, and data extraction using Gemini.
abstract class AIRepository {
  /// Generates a summary of the document content.
  ///
  /// [document] is the source document to summarize.
  /// Returns an [AISummary] with the generated summary and key points.
  Future<Either<Failure, AISummary>> summarizeDocument(
    ScanDocument document,
  );

  /// Extracts key points from a document.
  ///
  /// [document] is the source document.
  /// Returns a list of key point strings.
  Future<Either<Failure, List<String>>> extractKeyPoints(
    ScanDocument document,
  );

  /// Generates a smart name for the document based on its content.
  ///
  /// [document] is the source document.
  /// Returns the suggested name string.
  Future<Either<Failure, String>> smartRename(ScanDocument document);

  /// Automatically categorizes a document.
  ///
  /// [document] is the source document.
  /// Returns the category string (e.g., 'invoice', 'receipt', 'contract').
  Future<Either<Failure, String>> autoCategorize(ScanDocument document);

  /// Generates tags for a document based on its content.
  ///
  /// [document] is the source document.
  /// Returns a list of suggested tag strings.
  Future<Either<Failure, List<String>>> generateTags(ScanDocument document);

  /// Translates the full document text to the target language.
  ///
  /// [document] is the source document.
  /// [targetLanguage] is the ISO 639-1 language code.
  /// Returns the translated text string.
  Future<Either<Failure, String>> translateDocument(
    ScanDocument document,
    String targetLanguage,
  );

  /// Extracts structured data from a document.
  ///
  /// [document] is the source document.
  /// Returns an [AIExtraction] with detected type and fields.
  Future<Either<Failure, AIExtraction>> extractData(ScanDocument document);
}
