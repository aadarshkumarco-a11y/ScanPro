import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/scanned_document.dart';
import '../models/scanned_document_model.dart';

/// Local data source for scanned documents using Hive for persistence.
///
/// Handles CRUD operations on scanned documents stored in a Hive box.
/// All methods throw [CacheException] on failure so that the repository
/// implementation can convert them to [Failure]s.
class ScannerLocalDatasource {
  ScannerLocalDatasource({
    required Box<dynamic> documentsBox,
  }) : _box = documentsBox;

  final Box<dynamic> _box;
  static const _uuid = Uuid();

  // ── Create ────────────────────────────────────────────────────────

  /// Saves a [ScannedDocument] to the Hive box.
  ///
  /// If the document has no ID, a new one is generated.
  /// Returns the saved [ScannedDocumentModel] with updated timestamps.
  Future<ScannedDocumentModel> saveDocument(ScannedDocument document) async {
    try {
      final now = DateTime.now();
      final id = document.id.isEmpty ? _uuid.v4() : document.id;

      final model = ScannedDocumentModel(
        id: id,
        filePath: document.filePath,
        thumbnailPath: document.thumbnailPath,
        pages: document.pages,
        createdAt: document.createdAt,
        updatedAt: now,
        name: document.name,
        tags: document.tags,
        isFavorite: document.isFavorite,
        folderId: document.folderId,
        fileSize: document.fileSize,
        ocrText: document.ocrText,
        pdfPath: document.pdfPath,
        isSynced: document.isSynced,
        isLocked: document.isLocked,
      );

      await _box.put(id, model.toHive());
      return model;
    } catch (e) {
      throw CacheException(
        message: 'Failed to save document: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Read ──────────────────────────────────────────────────────────

  /// Retrieves all scanned documents from the Hive box.
  ///
  /// Returns an empty list if no documents are found.
  List<ScannedDocumentModel> getDocuments() {
    try {
      final documents = <ScannedDocumentModel>[];

      for (final key in _box.keys) {
        final value = _box.get(key);
        if (value is Map) {
          documents.add(
            ScannedDocumentModel.fromHive(Map<dynamic, dynamic>.from(value)),
          );
        }
      }

      // Sort by most recently updated first.
      documents.sort(
        (a, b) => b.updatedAt.compareTo(a.updatedAt),
      );

      return documents;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read documents: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Retrieves a single scanned document by [documentId].
  ///
  /// Throws [CacheException] if the document is not found.
  ScannedDocumentModel getDocumentById(String documentId) {
    try {
      final value = _box.get(documentId);
      if (value == null) {
        throw CacheException(
          message: 'Document with id "$documentId" not found.',
          code: 1001,
        );
      }
      if (value is Map) {
        return ScannedDocumentModel.fromHive(
          Map<dynamic, dynamic>.from(value),
        );
      }
      throw CacheException(
        message: 'Corrupted data for document "$documentId".',
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

  // ── Delete ────────────────────────────────────────────────────────

  /// Deletes a scanned document by [documentId].
  ///
  /// Also attempts to delete the associated file on disk.
  /// Throws [CacheException] if the document cannot be deleted.
  Future<void> deleteDocument(String documentId) async {
    try {
      // Attempt to clean up the file on disk.
      final value = _box.get(documentId);
      if (value is Map) {
        final model = ScannedDocumentModel.fromHive(
          Map<dynamic, dynamic>.from(value),
        );
        await _deleteFileIfExists(model.filePath);
        if (model.thumbnailPath != null) {
          await _deleteFileIfExists(model.thumbnailPath!);
        }
        if (model.pdfPath != null) {
          await _deleteFileIfExists(model.pdfPath!);
        }
        for (final page in model.pages) {
          await _deleteFileIfExists(page.filePath);
        }
      }

      await _box.delete(documentId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete document: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────

  /// Safely deletes a file at [path] if it exists.
  Future<void> _deleteFileIfExists(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Silently ignore file deletion failures during document cleanup.
    }
  }

  /// Generates a unique file name for a scanned image.
  static String generateScanFileName() {
    final now = DateTime.now();
    final timestamp =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
    return 'ScanPro_$timestamp.jpg';
  }

  /// Returns the directory where scanned images are stored.
  static Future<Directory> getScanDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final scanDir = Directory('${appDir.path}/scans');
    if (!await scanDir.exists()) {
      await scanDir.create(recursive: true);
    }
    return scanDir;
  }
}
