import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/annotation.dart';
import '../models/annotation_model.dart';

/// Local data source for annotations using Hive for persistence.
///
/// Handles CRUD operations on annotations stored in a Hive box.
/// All methods throw [CacheException] on failure so that the
/// repository implementation can convert them to [Failure]s.
class AnnotationLocalDatasource {
  AnnotationLocalDatasource({
    required Box<dynamic> annotationsBox,
  }) : _box = annotationsBox;

  final Box<dynamic> _box;
  static const _uuid = Uuid();

  // ── Create ────────────────────────────────────────────────────────

  /// Saves an [Annotation] to the Hive box.
  ///
  /// If the annotation has no ID, a new one is generated.
  /// Sets [createdAt] and [updatedAt] to now for new annotations.
  Future<AnnotationModel> addAnnotation(Annotation annotation) async {
    try {
      final id = annotation.id.isEmpty ? _uuid.v4() : annotation.id;
      final now = DateTime.now();

      final model = AnnotationModel(
        id: id,
        documentId: annotation.documentId,
        page: annotation.page,
        type: annotation.type,
        data: annotation.data,
        createdAt: now,
        updatedAt: now,
      );

      await _box.put(id, model.toHive());
      return model;
    } catch (e) {
      throw CacheException(
        message: 'Failed to add annotation: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Update ────────────────────────────────────────────────────────

  /// Updates an existing annotation in the Hive box.
  ///
  /// Throws [CacheException] if the annotation does not exist.
  Future<AnnotationModel> updateAnnotation(Annotation annotation) async {
    try {
      final existing = _box.get(annotation.id);
      if (existing == null) {
        throw CacheException(
          message: 'Annotation with id "${annotation.id}" not found.',
          code: 1001,
        );
      }

      final model = AnnotationModel(
        id: annotation.id,
        documentId: annotation.documentId,
        page: annotation.page,
        type: annotation.type,
        data: annotation.data,
        createdAt: annotation.createdAt,
        updatedAt: DateTime.now(),
      );

      await _box.put(annotation.id, model.toHive());
      return model;
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to update annotation: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Delete ────────────────────────────────────────────────────────

  /// Deletes an annotation by [id].
  Future<void> deleteAnnotation(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete annotation: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Read ──────────────────────────────────────────────────────────

  /// Retrieves all annotations for a given [documentId].
  ///
  /// Returns annotations ordered by page, then creation time.
  List<AnnotationModel> getAnnotationsByDocument(String documentId) {
    try {
      final annotations = <AnnotationModel>[];

      for (final key in _box.keys) {
        final value = _box.get(key);
        if (value is Map) {
          final map = Map<dynamic, dynamic>.from(value);
          if (map['documentId'] == documentId) {
            annotations.add(AnnotationModel.fromHive(map));
          }
        }
      }

      // Sort by page ascending, then by creation time ascending.
      annotations.sort((a, b) {
        final pageCompare = a.page.compareTo(b.page);
        if (pageCompare != 0) return pageCompare;
        return a.createdAt.compareTo(b.createdAt);
      });

      return annotations;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get annotations: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Retrieves annotations for a specific [documentId] and [page].
  ///
  /// Returns annotations for that page ordered by creation time.
  List<AnnotationModel> getAnnotationsByPage(String documentId, int page) {
    try {
      final annotations = <AnnotationModel>[];

      for (final key in _box.keys) {
        final value = _box.get(key);
        if (value is Map) {
          final map = Map<dynamic, dynamic>.from(value);
          if (map['documentId'] == documentId && map['page'] == page) {
            annotations.add(AnnotationModel.fromHive(map));
          }
        }
      }

      // Sort by creation time ascending.
      annotations.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return annotations;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get annotations for page: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Retrieves a single annotation by [id].
  ///
  /// Throws [CacheException] if not found.
  AnnotationModel getAnnotationById(String id) {
    try {
      final value = _box.get(id);
      if (value == null) {
        throw CacheException(
          message: 'Annotation with id "$id" not found.',
          code: 1001,
        );
      }
      if (value is Map) {
        return AnnotationModel.fromHive(Map<dynamic, dynamic>.from(value));
      }
      throw CacheException(
        message: 'Corrupted data for annotation "$id".',
        code: 1004,
      );
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read annotation: ${e.toString()}',
        code: 1003,
      );
    }
  }
}
