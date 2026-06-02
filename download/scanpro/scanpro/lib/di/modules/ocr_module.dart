/// OCR feature module — provides all Riverpod providers related to
/// optical character recognition powered by Google ML Kit.
///
/// Exposes services for on-device and cloud text recognition, the OCR
/// repository for persisting recognition results, and use cases that
/// compose scanning with OCR into single business operations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/ocr_repository.dart';
import '../../domain/usecases/ocr/recognize_text_usecase.dart';
import '../../domain/usecases/ocr/recognize_text_batch_usecase.dart';
import '../../domain/usecases/ocr/export_ocr_result_usecase.dart';
import '../../data/datasources/ocr_local_data_source.dart';
import '../../data/repositories/ocr_repository_impl.dart';
import '../injection.dart';

// ---------------------------------------------------------------------------
// Data Sources
// ---------------------------------------------------------------------------

/// Local data source that persists OCR results and recognized text
/// documents to Hive storage.
final ocrLocalDataSourceProvider = Provider<OCRLocalDataSource>((ref) {
  final box = ref.watch(hiveBoxProvider);
  return OCRLocalDataSource(box: box);
});

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

/// OCR service backed by Google ML Kit Text Recognition v2.
///
/// Supports both on-device (Latin, CJK, Devanagari) and cloud-based
/// recognition modes. Cloud mode requires an active network connection
/// and a Firebase project with the ML Kit API enabled.
final ocrServiceProvider = Provider<OCRService>((ref) {
  final connectivity = ref.watch(isOnlineProvider);
  return OCRService(preferCloud: connectivity);
});

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Primary [OCRRepository] implementation backed by local Hive storage
/// and the ML Kit OCR service.
final ocrRepositoryProvider = Provider<OCRRepository>((ref) {
  final localDataSource = ref.watch(ocrLocalDataSourceProvider);
  final ocrService = ref.watch(ocrServiceProvider);
  return OCRRepositoryImpl(
    localDataSource: localDataSource,
    ocrService: ocrService,
  );
});

// ---------------------------------------------------------------------------
// Use Cases
// ---------------------------------------------------------------------------

/// Recognizes text from a single image using ML Kit and persists
/// the structured result (blocks, paragraphs, lines) to local storage.
final recognizeTextUseCaseProvider = Provider<RecognizeTextUseCase>((ref) {
  final repository = ref.watch(ocrRepositoryProvider);
  return RecognizeTextUseCase(repository: repository);
});

/// Processes a batch of images in sequence, aggregating all recognized
/// text into a single OCR result document with per-page segmentation.
final recognizeTextBatchUseCaseProvider =
    Provider<RecognizeTextBatchUseCase>((ref) {
  final repository = ref.watch(ocrRepositoryProvider);
  return RecognizeTextBatchUseCase(repository: repository);
});

/// Exports an OCR result to a user-selected format (plain text, JSON,
/// or searchable PDF) and returns the output file path.
final exportOCRResultUseCaseProvider = Provider<ExportOCRResultUseCase>((ref) {
  final repository = ref.watch(ocrRepositoryProvider);
  return ExportOCRResultUseCase(repository: repository);
});

// ---------------------------------------------------------------------------
// Service Class (inline for DI wiring)
// ---------------------------------------------------------------------------

/// Wraps Google ML Kit Text Recognition for on-device and cloud OCR.
class OCRService {
  OCRService({this.preferCloud = false});

  /// When `true`, cloud-based recognition is attempted first with a
  /// fallback to on-device. When `false`, only on-device is used.
  final bool preferCloud;

  /// Recognizes text in the image at [imagePath] and returns a structured
  /// [OCRResult] containing the full text and per-block breakdown.
  Future<OCRResult> recognizeText(String imagePath) async {
    throw UnimplementedError('OCRService.recognizeText must be implemented');
  }

  /// Recognizes text across multiple images, returning one [OCRResult]
  /// with per-page text segments.
  Future<OCRResult> recognizeTextBatch(List<String> imagePaths) async {
    throw UnimplementedError(
      'OCRService.recognizeTextBatch must be implemented',
    );
  }
}

/// Structured result from text recognition containing the full extracted
/// text and metadata about recognized blocks and language.
class OCRResult {
  const OCRResult({
    required this.id,
    required this.fullText,
    required this.blocks,
    required this.language,
    required this.confidence,
    required this.createdAt,
  });

  /// Unique identifier for this OCR result.
  final String id;

  /// The complete recognized text from all blocks.
  final String fullText;

  /// Individual text blocks with bounding box information.
  final List<OCRBlock> blocks;

  /// Detected primary language code (e.g., 'en', 'zh', 'ja').
  final String language;

  /// Average confidence score across all blocks (0.0–1.0).
  final double confidence;

  /// Timestamp when the recognition was performed.
  final DateTime createdAt;
}

/// A single recognized text block with position and confidence data.
class OCRBlock {
  const OCRBlock({
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });

  /// The text content of this block.
  final String text;

  /// Confidence score for this block (0.0–1.0).
  final double confidence;

  /// Bounding box as [left, top, right, bottom] in normalized coords.
  final List<double> boundingBox;
}
