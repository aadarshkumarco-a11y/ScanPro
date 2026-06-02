import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';
import 'package:scanpro/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:scanpro/features/ocr/data/models/ocr_result_model.dart';
import 'package:scanpro/features/ocr/data/services/ml_kit_service.dart';

/// Implementation of [OCRRepository] using Google ML Kit and Hive.
///
/// Uses ML Kit for on-device text recognition and smart action detection,
/// with Hive for caching OCR results locally.
class OCRRepositoryImpl implements OCRRepository {
  final MLKitService _mlKitService;
  final Box<OCRResultModel> _localBox;

  /// Collection name for storing OCR results in Hive.
  static const String _boxName = 'ocr_results';

  OCRRepositoryImpl({
    required MLKitService mlKitService,
    required Box<OCRResultModel> localBox,
  })  : _mlKitService = mlKitService,
        _localBox = localBox;

  @override
  Future<Either<Failure, OCRResult>> extractText(
    ScanDocument document,
  ) async {
    try {
      final imagePath = document.pdfPath ?? document.filePath;
      final recognizedText = await _mlKitService.recognizeText(imagePath);

      if (recognizedText.isEmpty) {
        return Right(OCRResult(
          id: _generateId(),
          documentId: document.id,
          text: '',
          confidence: 0.0,
          createdAt: DateTime.now(),
        ));
      }

      final paragraphs = _mlKitService.extractParagraphs(recognizedText);
      final language = _mlKitService.detectLanguage(recognizedText);
      final confidence = _mlKitService.getConfidenceScore(recognizedText);

      final ocrResult = OCRResult(
        id: _generateId(),
        documentId: document.id,
        text: recognizedText,
        language: language,
        confidence: confidence,
        paragraphs: paragraphs,
        createdAt: DateTime.now(),
      );

      final model = OCRResultModel.fromEntity(ocrResult);
      await _localBox.put(document.id, model);

      return Right(ocrResult);
    } on MLKitException catch (e) {
      return Left(OCRFailure(message: e.message));
    } catch (e) {
      return Left(OCRFailure(message: 'Failed to extract text: $e'));
    }
  }

  @override
  Future<Either<Failure, OCRResult>> getOCRResult(String documentId) async {
    try {
      final model = _localBox.get(documentId);
      if (model == null) {
        return Left(
          NotFoundFailure(message: 'OCR result not found for document: $documentId'),
        );
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to get OCR result: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<OCRResult>>> getOCRHistories() async {
    try {
      final results = _localBox.values
          .map((model) => model.toEntity())
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(results);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to get OCR histories: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, OCRResult>> detectSmartActions(String text) async {
    try {
      final smartActions = _mlKitService.detectSmartActions(text);

      final ocrResult = OCRResult(
        id: _generateId(),
        documentId: '',
        text: text,
        smartActions: smartActions,
        createdAt: DateTime.now(),
      );

      return Right(ocrResult);
    } on MLKitException catch (e) {
      return Left(OCRFailure(message: e.message));
    } catch (e) {
      return Left(
        OCRFailure(message: 'Failed to detect smart actions: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> translateText(
    String text,
    String targetLanguage,
  ) async {
    try {
      final translated = await _mlKitService.translateText(
        text,
        targetLanguage,
      );
      return Right(translated);
    } on MLKitException catch (e) {
      return Left(OCRFailure(message: e.message));
    } catch (e) {
      return Left(OCRFailure(message: 'Failed to translate text: $e'));
    }
  }

  /// Generates a unique ID for OCR results.
  String _generateId() {
    return 'ocr_${DateTime.now().millisecondsSinceEpoch}';
  }
}
