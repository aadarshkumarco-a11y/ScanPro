import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/ocr_result.dart';

/// Stub ML Kit text recognition data source.
///
/// Replaces the Google ML Kit Text Recognition API with a stub
/// implementation that returns mock OCR results. All methods throw
/// [OcrException] on failure.
class OcrMlDatasource {
  OcrMlDatasource();

  static const _uuid = Uuid();

  /// Recognizes text from an image at the given [imagePath].
  ///
  /// Stub implementation that returns a placeholder result.
  /// Throws [OcrException] if no image file is found.
  Future<OcrResult> recognizeText({
    required String imagePath,
    required String documentId,
    String language = 'en',
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw OcrException(
          message: 'Image file not found: $imagePath',
          code: 3004,
        );
      }

      // Stub: return a placeholder result indicating OCR is not available.
      final blocks = <TextBlock>[
        TextBlock(
          text: '[OCR stub: Text recognition is not available in this build]',
          boundingBox: [0.0, 0.0, 100.0, 100.0],
          confidence: 0.0,
          blockType: 'paragraph',
        ),
      ];

      return OcrResult(
        id: _uuid.v4(),
        documentId: documentId,
        text: '[OCR stub: Text recognition is not available in this build]',
        blocks: blocks,
        language: language,
        confidence: 0.0,
        createdAt: DateTime.now(),
      );
    } on OcrException {
      rethrow;
    } catch (e) {
      throw OcrException(
        message: 'OCR processing failed: ${e.toString()}',
        code: 3004,
      );
    }
  }

  /// Extracts text regions with detailed block information.
  ///
  /// Stub implementation that returns a placeholder result.
  Future<OcrResult> extractTextRegions({
    required String imagePath,
    required String documentId,
    String language = 'en',
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw OcrException(
          message: 'Image file not found: $imagePath',
          code: 3004,
        );
      }

      // Stub: return a placeholder result indicating OCR is not available.
      final blocks = <TextBlock>[
        TextBlock(
          text: '[OCR stub: Text region extraction is not available in this build]',
          boundingBox: [0.0, 0.0, 100.0, 100.0],
          confidence: 0.0,
          blockType: 'paragraph',
        ),
      ];

      return OcrResult(
        id: _uuid.v4(),
        documentId: documentId,
        text: '[OCR stub: Text region extraction is not available in this build]',
        blocks: blocks,
        language: language,
        confidence: 0.0,
        createdAt: DateTime.now(),
      );
    } on OcrException {
      rethrow;
    } catch (e) {
      throw OcrException(
        message: 'Text region extraction failed: ${e.toString()}',
        code: 3004,
      );
    }
  }

  /// Disposes resources (stub – no-op).
  void dispose() {
    // No-op: nothing to dispose in stub implementation.
  }
}
