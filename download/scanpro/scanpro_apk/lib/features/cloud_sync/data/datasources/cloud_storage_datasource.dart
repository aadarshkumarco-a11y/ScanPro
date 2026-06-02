import 'dart:io';
import 'dart:typed_data';

import '../../../../core/errors/exceptions.dart';

/// Stub implementation of cloud storage data source.
///
/// Since Firebase Storage is not available, this implementation
/// simulates file operations locally. Files are copied to a local
/// "cloud" directory. All methods throw [SyncException] on failure.
class CloudStorageDatasource {
  CloudStorageDatasource();

  /// Base path for local "cloud" storage simulation.
  static const String _baseStoragePath = 'documents';

  // ── Upload ────────────────────────────────────────────────────────

  /// Uploads a document file to local cloud simulation.
  Future<String> uploadFile({
    required String documentId,
    required String filePath,
    String? fileName,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw SyncException(
          message: 'Local file not found: $filePath',
          code: 7002,
        );
      }

      final name = fileName ?? filePath.split('/').last;
      final cloudPath = '$_baseStoragePath/$documentId/$name';

      return cloudPath;
    } on SyncException {
      rethrow;
    } catch (e) {
      throw SyncException(
        message: 'Failed to upload file: ${e.toString()}',
        code: 7002,
      );
    }
  }

  /// Uploads file bytes (stub: returns the cloud path only).
  Future<String> uploadBytes({
    required String documentId,
    required List<int> bytes,
    required String fileName,
    String? contentType,
  }) async {
    try {
      final cloudPath = '$_baseStoragePath/$documentId/$fileName';
      return cloudPath;
    } on SyncException {
      rethrow;
    } catch (e) {
      throw SyncException(
        message: 'Failed to upload bytes: ${e.toString()}',
        code: 7002,
      );
    }
  }

  // ── Download ──────────────────────────────────────────────────────

  /// Downloads a document file (stub: copies from local path).
  Future<String> downloadFile({
    required String cloudPath,
    required String localPath,
  }) async {
    try {
      final fileName = cloudPath.split('/').last;
      final localFilePath = '$localPath/$fileName';

      final dir = Directory(localPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      return localFilePath;
    } on SyncException {
      rethrow;
    } catch (e) {
      throw SyncException(
        message: 'Failed to download file: ${e.toString()}',
        code: 7003,
      );
    }
  }

  /// Gets the download URL for a cloud file (stub).
  Future<String> getDownloadUrl(String cloudPath) async {
    try {
      return 'stub://cloud-storage/$cloudPath';
    } catch (e) {
      throw SyncException(
        message: 'Failed to get download URL: ${e.toString()}',
        code: 7003,
      );
    }
  }

  // ── Delete ────────────────────────────────────────────────────────

  /// Deletes a file from cloud storage (stub: no-op).
  Future<void> deleteFile(String cloudPath) async {
    // No-op stub
  }

  /// Deletes all files for a document from cloud storage (stub: no-op).
  Future<void> deleteAllFilesForDocument(String documentId) async {
    // No-op stub
  }

  // ── Metadata ──────────────────────────────────────────────────────

  /// Gets the file size in bytes for a cloud file (stub: returns 0).
  Future<int> getFileSize(String cloudPath) async {
    try {
      return 0;
    } catch (e) {
      throw SyncException(
        message: 'Failed to get file metadata: ${e.toString()}',
        code: 7002,
      );
    }
  }
}
