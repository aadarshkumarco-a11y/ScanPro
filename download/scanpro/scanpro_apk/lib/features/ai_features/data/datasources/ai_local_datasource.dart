import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/ai_result.dart';
import '../models/ai_result_model.dart';

/// Local data source for caching AI results using Hive.
///
/// Provides CRUD operations on cached AI results so that
/// repeated requests can be served from local storage.
class AiLocalDatasource {
  AiLocalDatasource({
    required Box<dynamic> cacheBox,
  }) : _box = cacheBox;

  final Box<dynamic> _box;

  // ── Save ────────────────────────────────────────────────────────────

  /// Caches an [AiResultModel] to the Hive box.
  Future<void> saveResult(AiResultModel result) async {
    try {
      await _box.put(result.id, result.toHive());
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache AI result: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Read ────────────────────────────────────────────────────────────

  /// Retrieves all cached AI results.
  ///
  /// Optionally filters by [type]. Returns results sorted
  /// by most recent first.
  List<AiResultModel> getResults({AiFeatureType? type}) {
    try {
      final results = <AiResultModel>[];

      for (final key in _box.keys) {
        final value = _box.get(key);
        if (value is Map) {
          final model = AiResultModel.fromHive(
            Map<dynamic, dynamic>.from(value),
          );

          if (type == null || model.type == type) {
            results.add(model);
          }
        }
      }

      // Sort by most recent first.
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return results;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read AI results: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Retrieves a single cached result by [id].
  ///
  /// Throws [CacheException] if not found.
  AiResultModel getResultById(String id) {
    try {
      final value = _box.get(id);
      if (value == null) {
        throw CacheException(
          message: 'AI result with id "$id" not found.',
          code: 1001,
        );
      }
      if (value is Map) {
        return AiResultModel.fromHive(Map<dynamic, dynamic>.from(value));
      }
      throw CacheException(
        message: 'Corrupted data for AI result "$id".',
        code: 1004,
      );
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read AI result: ${e.toString()}',
        code: 1003,
      );
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────

  /// Deletes a cached AI result by [id].
  Future<void> deleteResult(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete AI result: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Clears all cached AI results.
  Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear AI cache: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Cache Check ─────────────────────────────────────────────────────

  /// Checks whether a cached result exists for the given parameters.
  ///
  /// This enables cache-first strategies in the repository.
  AiResultModel? findCachedResult({
    required AiFeatureType type,
    required String inputText,
  }) {
    try {
      final results = getResults(type: type);
      for (final result in results) {
        if (result.inputText == inputText) {
          return result;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns the count of cached results, optionally by [type].
  int getResultCount({AiFeatureType? type}) {
    try {
      return getResults(type: type).length;
    } catch (_) {
      return 0;
    }
  }
}
