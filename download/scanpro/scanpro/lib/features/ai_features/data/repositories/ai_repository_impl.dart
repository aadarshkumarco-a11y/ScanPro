import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_summary.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_extraction.dart';
import 'package:scanpro/features/ai_features/domain/repositories/ai_repository.dart';
import 'package:scanpro/features/ai_features/data/models/ai_summary_model.dart';
import 'package:scanpro/features/ai_features/data/services/gemini_service.dart';
import 'package:hive/hive.dart';

/// Implementation of [AIRepository] using the Gemini AI service.
///
/// Delegates all AI operations to the [GeminiService], converting
/// between domain entities and the service's data formats.
class AIRepositoryImpl implements AIRepository {
  final GeminiService _geminiService;
  final Box<AISummaryModel> _summaryBox;

  AIRepositoryImpl({
    required GeminiService geminiService,
    required Box<AISummaryModel> summaryBox,
  })  : _geminiService = geminiService,
        _summaryBox = summaryBox;

  @override
  Future<Either<Failure, AISummary>> summarizeDocument(
    ScanDocument document,
  ) async {
    try {
      final text = document.ocrText ?? '';
      if (text.isEmpty) {
        return const Left(
          ValidationFailure(message: 'Document has no OCR text to summarize'),
        );
      }

      final response = await _geminiService.generateContent(
        prompt: 'Summarize the following document concisely. '
            'Also extract 3-5 key points and suggest a category and tags.\n\n'
            'Document text:\n$text',
      );

      final summary = AISummary(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        documentId: document.id,
        summary: response['summary'] as String? ?? '',
        keyPoints: (response['keyPoints'] as List<dynamic>?)
                ?.cast<String>() ??
            [],
        category: response['category'] as String? ?? 'uncategorized',
        suggestedTags: (response['suggestedTags'] as List<dynamic>?)
                ?.cast<String>() ??
            [],
        confidence: (response['confidence'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.now(),
      );

      final model = AISummaryModel.fromEntity(summary);
      await _summaryBox.put(document.id, model);

      return Right(summary);
    } on GeminiException catch (e) {
      return Left(AIFailure(message: e.message));
    } catch (e) {
      return Left(AIFailure(message: 'Failed to summarize document: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> extractKeyPoints(
    ScanDocument document,
  ) async {
    try {
      final text = document.ocrText ?? '';
      if (text.isEmpty) {
        return const Left(
          ValidationFailure(
            message: 'Document has no OCR text for key point extraction',
          ),
        );
      }

      final response = await _geminiService.generateContent(
        prompt: 'Extract the 5 most important key points from this document. '
            'Return as a JSON list of strings.\n\n$text',
      );

      final keyPoints = (response['keyPoints'] as List<dynamic>?)
              ?.cast<String>() ??
          [];

      return Right(keyPoints);
    } on GeminiException catch (e) {
      return Left(AIFailure(message: e.message));
    } catch (e) {
      return Left(
        AIFailure(message: 'Failed to extract key points: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> smartRename(ScanDocument document) async {
    try {
      final text = document.ocrText ?? '';
      final response = await _geminiService.generateContent(
        prompt: 'Generate a short, descriptive filename for a document '
            'with the following content. Use underscores instead of spaces. '
            'Maximum 50 characters.\n\n$text',
      );

      final name = response['name'] as String? ?? document.title;
      return Right(name);
    } on GeminiException catch (e) {
      return Left(AIFailure(message: e.message));
    } catch (e) {
      return Left(AIFailure(message: 'Failed to smart rename: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> autoCategorize(
    ScanDocument document,
  ) async {
    try {
      final text = document.ocrText ?? '';
      if (text.isEmpty) {
        return const Right('uncategorized');
      }

      final response = await _geminiService.generateContent(
        prompt: 'Categorize this document into one of these categories: '
            'invoice, receipt, contract, id_card, letter, report, '
            'certificate, form, other. Return only the category name.\n\n$text',
      );

      final category = response['category'] as String? ?? 'other';
      return Right(category);
    } on GeminiException catch (e) {
      return Left(AIFailure(message: e.message));
    } catch (e) {
      return Left(AIFailure(message: 'Failed to auto-categorize: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> generateTags(
    ScanDocument document,
  ) async {
    try {
      final text = document.ocrText ?? '';
      if (text.isEmpty) {
        return const Right([]);
      }

      final response = await _geminiService.generateContent(
        prompt: 'Generate 3-5 relevant tags for this document. '
            'Return as a JSON list of lowercase strings.\n\n$text',
      );

      final tags = (response['tags'] as List<dynamic>?)
              ?.cast<String>() ??
          [];

      return Right(tags);
    } on GeminiException catch (e) {
      return Left(AIFailure(message: e.message));
    } catch (e) {
      return Left(AIFailure(message: 'Failed to generate tags: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> translateDocument(
    ScanDocument document,
    String targetLanguage,
  ) async {
    try {
      final text = document.ocrText ?? '';
      if (text.isEmpty) {
        return const Left(
          ValidationFailure(
            message: 'Document has no OCR text to translate',
          ),
        );
      }

      final response = await _geminiService.generateContent(
        prompt: 'Translate the following text to $targetLanguage. '
            'Return only the translated text.\n\n$text',
      );

      final translatedText = response['translation'] as String? ?? '';
      return Right(translatedText);
    } on GeminiException catch (e) {
      return Left(AIFailure(message: e.message));
    } catch (e) {
      return Left(
        AIFailure(message: 'Failed to translate document: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AIExtraction>> extractData(
    ScanDocument document,
  ) async {
    try {
      final text = document.ocrText ?? '';
      if (text.isEmpty) {
        return const Left(
          ValidationFailure(
            message: 'Document has no OCR text for data extraction',
          ),
        );
      }

      final response = await _geminiService.generateContent(
        prompt: 'Extract structured data from this document. '
            'Identify the document type and extract all relevant fields. '
            'Return as JSON with "documentType", "fields", and "confidence".\n\n$text',
      );

      final extraction = AIExtraction(
        id: 'ext_${DateTime.now().millisecondsSinceEpoch}',
        documentId: document.id,
        documentType: response['documentType'] as String? ?? 'unknown',
        extractedFields: Map<String, dynamic>.from(
          response['fields'] as Map? ?? {},
        ),
        confidence: (response['confidence'] as num?)?.toDouble() ?? 0.0,
      );

      return Right(extraction);
    } on GeminiException catch (e) {
      return Left(AIFailure(message: e.message));
    } catch (e) {
      return Left(AIFailure(message: 'Failed to extract data: $e'));
    }
  }
}
