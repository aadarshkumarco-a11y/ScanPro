import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/document_folder.dart';
import '../../domain/entities/document_tag.dart';
import '../models/document_folder_model.dart';
import '../models/document_tag_model.dart';

/// Local data source for documents, folders, and tags using Hive.
///
/// Provides CRUD operations on all three Hive boxes. All methods throw
/// [CacheException] on failure so that the repository implementation
/// can convert them to [Failure]s.
class DocumentLocalDatasource {
  DocumentLocalDatasource({
    required Box<dynamic> documentsBox,
    required Box<dynamic> foldersBox,
    required Box<dynamic> tagsBox,
  })  : _documentsBox = documentsBox,
        _foldersBox = foldersBox,
        _tagsBox = tagsBox;

  final Box<dynamic> _documentsBox;
  final Box<dynamic> _foldersBox;
  final Box<dynamic> _tagsBox;
  static const _uuid = Uuid();

  // ═══════════════════════════════════════════════════════════════════
  //  Documents
  // ═══════════════════════════════════════════════════════════════════

  /// Key used to mark a document as trashed.
  static const String trashKey = 'isTrashed';
  static const String trashDateKey = 'trashedAt';

  /// Retrieves all non-trashed documents from the documents Hive box.
  List<Map<String, dynamic>> getDocuments({
    String? folderId,
    String? tag,
    bool includeDeleted = false,
  }) {
    try {
      final results = <Map<String, dynamic>>[];

      for (final key in _documentsBox.keys) {
        final value = _documentsBox.get(key);
        if (value is! Map) continue;

        final map = Map<String, dynamic>.from(value);

        // Skip trashed documents unless explicitly included.
        final isTrashed = map[trashKey] as bool? ?? false;
        if (!includeDeleted && isTrashed) continue;

        // Filter by folder.
        if (folderId != null && map['folderId'] != folderId) continue;

        // Filter by tag.
        if (tag != null) {
          final tags = (map['tags'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [];
          if (!tags.contains(tag)) continue;
        }

        results.add(map);
      }

      // Sort by most recently updated.
      results.sort((a, b) {
        final dateA = _parseDate(a['updatedAt']);
        final dateB = _parseDate(b['updatedAt']);
        return dateB.compareTo(dateA);
      });

      return results;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read documents: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Retrieves a single document by [documentId].
  Map<String, dynamic> getDocumentById(String documentId) {
    try {
      final value = _documentsBox.get(documentId);
      if (value == null) {
        throw CacheException(
          message: 'Document not found.',
          code: 1001,
        );
      }
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      throw CacheException(
        message: 'Corrupted document data.',
        code: 1004,
      );
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read document: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Saves or updates a document map in the Hive box.
  Future<void> saveDocument(String documentId, Map<String, dynamic> data) async {
    try {
      await _documentsBox.put(documentId, data);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save document: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Marks a document as trashed.
  Future<void> markAsTrashed(String documentId) async {
    try {
      final data = getDocumentById(documentId);
      data[trashKey] = true;
      data[trashDateKey] = DateTime.now().toIso8601String();
      await _documentsBox.put(documentId, data);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to trash document: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Restores a document from the trash.
  Future<void> restoreFromTrash(String documentId) async {
    try {
      final data = getDocumentById(documentId);
      data[trashKey] = false;
      data.remove(trashDateKey);
      await _documentsBox.put(documentId, data);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to restore document: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Permanently deletes a document from the Hive box.
  Future<void> permanentDeleteDocument(String documentId) async {
    try {
      await _documentsBox.delete(documentId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete document: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Empties the trash by permanently deleting all trashed documents.
  Future<void> emptyTrash() async {
    try {
      final trashIds = <dynamic>[];
      for (final key in _documentsBox.keys) {
        final value = _documentsBox.get(key);
        if (value is Map) {
          final map = Map<dynamic, dynamic>.from(value);
          if (map[trashKey] as bool? ?? false) {
            trashIds.add(key);
          }
        }
      }
      for (final id in trashIds) {
        await _documentsBox.delete(id);
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to empty trash: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Folders
  // ═══════════════════════════════════════════════════════════════════

  /// Retrieves all folders from the folders Hive box.
  List<DocumentFolderModel> getFolders() {
    try {
      final folders = <DocumentFolderModel>[];
      for (final key in _foldersBox.keys) {
        final value = _foldersBox.get(key);
        if (value is Map) {
          folders.add(
            DocumentFolderModel.fromHive(Map<dynamic, dynamic>.from(value)),
          );
        }
      }
      folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return folders;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read folders: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Creates a new folder in the Hive box.
  Future<DocumentFolderModel> createFolder({
    required String name,
    String? color,
    String? icon,
    String? parentFolderId,
  }) async {
    try {
      final id = _uuid.v4();
      final now = DateTime.now();
      final model = DocumentFolderModel(
        id: id,
        name: name,
        createdAt: now,
        color: color,
        icon: icon,
        parentFolderId: parentFolderId,
      );
      await _foldersBox.put(id, model.toHive());
      return model;
    } catch (e) {
      throw CacheException(
        message: 'Failed to create folder: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Renames a folder in the Hive box.
  Future<DocumentFolderModel> renameFolder({
    required String folderId,
    required String newName,
  }) async {
    try {
      final value = _foldersBox.get(folderId);
      if (value == null) {
        throw CacheException(
          message: 'Folder not found.',
          code: 1001,
        );
      }
      final map = Map<dynamic, dynamic>.from(value as Map);
      map['name'] = newName;
      await _foldersBox.put(folderId, map);
      return DocumentFolderModel.fromHive(map);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to rename folder: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Deletes a folder from the Hive box.
  Future<void> deleteFolder(String folderId) async {
    try {
      await _foldersBox.delete(folderId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete folder: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Tags
  // ═══════════════════════════════════════════════════════════════════

  /// Retrieves all tags from the tags Hive box.
  List<DocumentTagModel> getTags() {
    try {
      final tags = <DocumentTagModel>[];
      for (final key in _tagsBox.keys) {
        final value = _tagsBox.get(key);
        if (value is Map) {
          tags.add(
            DocumentTagModel.fromHive(Map<dynamic, dynamic>.from(value)),
          );
        }
      }
      tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return tags;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read tags: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Creates a new tag in the Hive box.
  Future<DocumentTagModel> createTag({
    required String name,
    String? color,
  }) async {
    try {
      final id = _uuid.v4();
      final model = DocumentTagModel(
        id: id,
        name: name,
        color: color,
        createdAt: DateTime.now(),
      );
      await _tagsBox.put(id, model.toHive());
      return model;
    } catch (e) {
      throw CacheException(
        message: 'Failed to create tag: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Deletes a tag from the Hive box.
  Future<void> deleteTag(String tagId) async {
    try {
      await _tagsBox.delete(tagId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete tag: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Helpers
  // ═══════════════════════════════════════════════════════════════════

  DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}
