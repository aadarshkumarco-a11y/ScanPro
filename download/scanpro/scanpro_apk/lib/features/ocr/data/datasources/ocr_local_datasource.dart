import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/ocr_result.dart';
import '../models/ocr_result_model.dart';

/// Local data source for OCR results using Hive for persistence.
///
/// Handles CRUD operations on OCR results stored in a Hive box.
/// All methods throw [CacheException] on failure so that the repository
/// implementation can convert them to [Failure]s.
class OcrLocalDatasource {
  OcrLocalDatasource({
    required Box<dynamic> cacheBox,
  }) : _box = cacheBox;

  final Box<dynamic> _box;
  static const _uuid = Uuid();

  /// Hive key prefix for OCR results to avoid collisions.
  static const _keyPrefix = 'ocr_';

  // ── Create ────────────────────────────────────────────────────────

  /// Saves an [OcrResult] to the Hive box.
  ///
  /// If the result has no ID, a new one is generated.
  /// Returns the saved [OcrResultModel] with updated timestamps.
  Future<OcrResultModel> saveOcrResult(OcrResult result) async {
    try {
      final id = result.id.isEmpty ? '${_keyPrefix}${_uuid.v4()}' : result.id;

      final model = OcrResultModel(
        id: id,
        documentId: result.documentId,
        text: result.text,
        blocks: result.blocks,
        language: result.language,
        confidence: result.confidence,
        createdAt: result.createdAt,
      );

      await _box.put(id, model.toHive());
      return model;
    } catch (e) {
      throw CacheException(
        message: 'Failed to save OCR result: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Read ──────────────────────────────────────────────────────────

  /// Retrieves all OCR results from the Hive box.
  ///
  /// Returns an empty list if no results are found.
  List<OcrResultModel> getOcrResults() {
    try {
      final results = <OcrResultModel>[];

      for (final key in _box.keys) {
        if (key is String && key.startsWith(_keyPrefix)) {
          final value = _box.get(key);
          if (value is Map) {
            results.add(
              OcrResultModel.fromHive(Map<dynamic, dynamic>.from(value)),
            );
          }
        }
      }

      // Sort by most recently created first.
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return results;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read OCR results: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Retrieves a single OCR result by its [ocrResultId].
  ///
  /// Throws [CacheException] if the result is not found.
  OcrResultModel getOcrResultById(String ocrResultId) {
    try {
      final key = ocrResultId.startsWith(_keyPrefix)
          ? ocrResultId
          : '$_keyPrefix$ocrResultId';
      final value = _box.get(key);
      if (value == null) {
        throw CacheException(
          message: 'OCR result with id "$ocrResultId" not found.',
          code: 1001,
        );
      }
      if (value is Map) {
        return OcrResultModel.fromHive(Map<dynamic, dynamic>.from(value));
      }
      throw CacheException(
        message: 'Corrupted data for OCR result "$ocrResultId".',
        code: 1004,
      );
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read OCR result: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Retrieves the OCR result associated with a [documentId].
  ///
  /// Returns null if no OCR result exists for the document.
  OcrResultModel? getOcrResultByDocumentId(String documentId) {
    try {
      final results = getOcrResults();
      for (final result in results) {
        if (result.documentId == documentId) {
          return result;
        }
      }
      return null;
    } catch (e) {
      throw CacheException(
        message: 'Failed to find OCR result for document: ${e.toString()}',
        code: 1003,
      );
    }
  }

  // ── Delete ────────────────────────────────────────────────────────

  /// Deletes an OCR result by [ocrResultId].
  ///
  /// Throws [CacheException] if the result cannot be deleted.
  Future<void> deleteOcrResult(String ocrResultId) async {
    try {
      final key = ocrResultId.startsWith(_keyPrefix)
          ? ocrResultId
          : '$_keyPrefix$ocrResultId';
      await _box.delete(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete OCR result: ${e.toString()}',
        code: 1002,
      );
    }
  }
}
