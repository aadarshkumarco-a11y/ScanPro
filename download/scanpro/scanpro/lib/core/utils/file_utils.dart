/// File operation utilities for ScanPro.
///
/// Provides helpers for file size formatting, deletion, renaming,
/// moving, and copying with proper error handling.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Utility class for common file system operations.
class FileUtils {
  FileUtils._();

  /// Formats [bytes] into a human-readable file size string.
  ///
  /// Returns values like "1.5 MB", "320 KB", "42 B".
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Returns the file size in bytes, or 0 if the file does not exist.
  static Future<int> fileSize(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    return await file.length();
  }

  /// Deletes a file at [path] if it exists.
  ///
  /// Returns `true` if the file was deleted, `false` if it didn't exist.
  static Future<bool> deleteFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return false;
    try {
      await file.delete();
      return true;
    } catch (e) {
      throw CacheException(message: 'Failed to delete file: $path', originalError: e);
    }
  }

  /// Deletes a directory at [path] recursively if it exists.
  static Future<bool> deleteDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return false;
    try {
      await dir.delete(recursive: true);
      return true;
    } catch (e) {
      throw CacheException(message: 'Failed to delete directory: $path', originalError: e);
    }
  }

  /// Renames a file from [oldPath] to [newPath].
  ///
  /// Returns the new [File] after renaming.
  static Future<File> renameFile(String oldPath, String newPath) async {
    final file = File(oldPath);
    if (!await file.exists()) {
      throw CacheException(message: 'Source file not found: $oldPath');
    }
    try {
      return await file.rename(newPath);
    } catch (e) {
      throw CacheException(message: 'Failed to rename file', originalError: e);
    }
  }

  /// Copies a file from [sourcePath] to [destinationPath].
  ///
  /// Returns the new [File] at the destination.
  static Future<File> copyFile(String sourcePath, String destinationPath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw CacheException(message: 'Source file not found: $sourcePath');
    }
    try {
      await _ensureDirectoryExists(destinationPath);
      return await source.copy(destinationPath);
    } catch (e) {
      throw CacheException(message: 'Failed to copy file', originalError: e);
    }
  }

  /// Moves a file from [sourcePath] to [destinationPath].
  ///
  /// Attempts rename first (fast), falls back to copy+delete.
  static Future<File> moveFile(String sourcePath, String destinationPath) async {
    try {
      return await renameFile(sourcePath, destinationPath);
    } catch (_) {
      final copied = await copyFile(sourcePath, destinationPath);
      await deleteFile(sourcePath);
      return copied;
    }
  }

  /// Checks whether a file exists at [path].
  static Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  /// Checks whether a directory exists at [path].
  static Future<bool> directoryExists(String path) async {
    return Directory(path).exists();
  }

  /// Generates a unique file name by appending a counter suffix if needed.
  static Future<String> getUniqueFilePath(String directory, String fileName) async {
    final ext = p.extension(fileName);
    final baseName = p.basenameWithoutExtension(fileName);
    var candidate = p.join(directory, fileName);

    if (!await fileExists(candidate)) return candidate;

    var counter = 1;
    while (await fileExists(candidate)) {
      candidate = p.join(directory, '${baseName}_$counter$ext');
      counter++;
    }
    return candidate;
  }

  /// Returns the application documents directory path.
  static Future<String> getAppDocumentsPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Returns the temporary directory path.
  static Future<String> getTempPath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  /// Creates the parent directory for [filePath] if it doesn't exist.
  static Future<void> _ensureDirectoryExists(String filePath) async {
    final parentDir = p.dirname(filePath);
    final dir = Directory(parentDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Checks whether a file at [path] exceeds the maximum allowed size.
  static Future<bool> exceedsMaxSize(String path) async {
    final size = await fileSize(path);
    return size > AppConstants.maxFileSizeBytes;
  }

  /// Returns the file extension from [path] in lowercase.
  static String extension(String path) {
    return p.extension(path).toLowerCase();
  }

  /// Returns whether the file extension is a supported image format.
  static bool isSupportedImage(String path) {
    final ext = extension(path).replaceFirst('.', '');
    return AppConstants.supportedImageFormats.contains(ext);
  }

  /// Returns whether the file extension is a supported document format.
  static bool isSupportedDocument(String path) {
    final ext = extension(path).replaceFirst('.', '');
    return AppConstants.supportedDocumentFormats.contains(ext);
  }

  /// Clears all files in the temporary directory older than [maxAge].
  static Future<int> clearOldTempFiles({Duration maxAge = const Duration(days: 1)}) async {
    final tempPath = await getTempPath();
    final tempDir = Directory(tempPath);
    if (!await tempDir.exists()) return 0;

    var deleted = 0;
    final cutoff = DateTime.now().subtract(maxAge);
    await for (final entity in tempDir.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        if (stat.modified.isBefore(cutoff)) {
          try {
            await entity.delete();
            deleted++;
          } catch (_) {}
        }
      }
    }
    return deleted;
  }
}
