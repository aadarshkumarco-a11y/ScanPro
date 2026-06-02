import 'dart:io';

/// The broad category a file falls into based on its extension.
enum FileCategory {
  image,
  document,
  pdf,
  spreadsheet,
  presentation,
  audio,
  video,
  archive,
  text,
  unknown,
}

/// File system utility functions for ScanPro.
///
/// Provides helpers for file-size formatting, extension detection,
/// MIME-type mapping, and common file-system operations.
class FileUtils {
  FileUtils._();

  // ── File Size Formatting ────────────────────────────────────────

  /// Converts a byte count into a human-readable size string.
  ///
  /// Examples:
  /// - `formatBytes(0)` → "0 B"
  /// - `formatBytes(512)` → "512 B"
  /// - `formatBytes(1024)` → "1.00 KB"
  /// - `formatBytes(1536000)` → "1.46 MB"
  /// - `formatBytes(1073741824)` → "1.00 GB"
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes.bitLength - 1) ~/ 10; // log2(bytes) / 10 ≈ log1024(bytes)
    final index = i.clamp(0, suffixes.length - 1);

    final size = bytes / (1 << (index * 10));
    return '${size.toStringAsFixed(decimals)} ${suffixes[index]}';
  }

  /// Returns a short, human-readable file size string (no decimals).
  ///
  /// Examples: "1 MB", "256 KB", "2 GB"
  static String fileSizeShort(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    final index = i.clamp(0, suffixes.length - 1);

    final size = bytes / (1 << (index * 10));
    if (size == size.truncateToDouble()) {
      return '${size.truncate()} ${suffixes[index]}';
    }
    return '${size.toStringAsFixed(1)} ${suffixes[index]}';
  }

  /// Returns a human-readable size string from a [File] object.
  ///
  /// Returns "Unknown" if the file does not exist or the size
  /// cannot be determined.
  static Future<String> getFileSizeString(File file) async {
    try {
      if (await file.exists()) {
        final bytes = await file.length();
        return formatBytes(bytes);
      }
      return 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  /// Returns the file size in bytes, or 0 if the file cannot be read.
  static Future<int> getFileSize(File file) async {
    try {
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  // ── File Extension ──────────────────────────────────────────────

  /// Returns the lowercase extension of a file path (without the dot).
  ///
  /// ```dart
  /// getExtension('/path/to/document.pdf') // → 'pdf'
  /// getExtension('image.JPEG')            // → 'jpeg'
  /// getExtension('noext')                 // → ''
  /// ```
  static String getExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == path.length - 1) return '';
    return path.substring(dotIndex + 1).toLowerCase();
  }

  /// Returns the extension including the dot, e.g. ".pdf".
  static String getExtensionWithDot(String path) {
    final ext = getExtension(path);
    return ext.isEmpty ? '' : '.$ext';
  }

  /// Returns the file name without extension from a path.
  ///
  /// ```dart
  /// getBaseName('/path/to/document.pdf') // → 'document'
  /// ```
  static String getBaseName(String path) {
    final name = getFileName(path);
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0) return name;
    return name.substring(0, dotIndex);
  }

  /// Returns the file name (including extension) from a full path.
  static String getFileName(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  // ── MIME Type ───────────────────────────────────────────────────

  /// Returns a MIME type string for the given file extension.
  ///
  /// Defaults to `application/octet-stream` for unknown extensions.
  static String getMimeType(String extension) {
    const mimeMap = <String, String>{
      // Images
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'bmp': 'image/bmp',
      'svg': 'image/svg+xml',
      'tiff': 'image/tiff',
      'tif': 'image/tiff',
      'ico': 'image/x-icon',
      // Documents
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      // Text
      'txt': 'text/plain',
      'csv': 'text/csv',
      'rtf': 'application/rtf',
      'html': 'text/html',
      'xml': 'application/xml',
      'json': 'application/json',
      // Audio
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'ogg': 'audio/ogg',
      'm4a': 'audio/mp4',
      // Video
      'mp4': 'video/mp4',
      'avi': 'video/x-msvideo',
      'mov': 'video/quicktime',
      'mkv': 'video/x-matroska',
      'webm': 'video/webm',
      // Archives
      'zip': 'application/zip',
      'rar': 'application/vnd.rar',
      '7z': 'application/x-7z-compressed',
      'tar': 'application/x-tar',
      'gz': 'application/gzip',
    };

    return mimeMap[extension.toLowerCase()] ?? 'application/octet-stream';
  }

  /// Returns a MIME type from a file path (extracts the extension first).
  static String getMimeTypeFromPath(String path) {
    return getMimeType(getExtension(path));
  }

  // ── File Category ───────────────────────────────────────────────

  /// Returns the [FileCategory] for the given extension.
  static FileCategory getCategory(String extension) {
    const categoryMap = <String, FileCategory>{
      'jpg': FileCategory.image,
      'jpeg': FileCategory.image,
      'png': FileCategory.image,
      'gif': FileCategory.image,
      'webp': FileCategory.image,
      'bmp': FileCategory.image,
      'svg': FileCategory.image,
      'tiff': FileCategory.image,
      'tif': FileCategory.image,
      'pdf': FileCategory.pdf,
      'doc': FileCategory.document,
      'docx': FileCategory.document,
      'xls': FileCategory.spreadsheet,
      'xlsx': FileCategory.spreadsheet,
      'csv': FileCategory.spreadsheet,
      'ppt': FileCategory.presentation,
      'pptx': FileCategory.presentation,
      'txt': FileCategory.text,
      'rtf': FileCategory.text,
      'html': FileCategory.text,
      'json': FileCategory.text,
      'mp3': FileCategory.audio,
      'wav': FileCategory.audio,
      'ogg': FileCategory.audio,
      'm4a': FileCategory.audio,
      'mp4': FileCategory.video,
      'avi': FileCategory.video,
      'mov': FileCategory.video,
      'mkv': FileCategory.video,
      'webm': FileCategory.video,
      'zip': FileCategory.archive,
      'rar': FileCategory.archive,
      '7z': FileCategory.archive,
      'tar': FileCategory.archive,
      'gz': FileCategory.archive,
    };

    return categoryMap[extension.toLowerCase()] ?? FileCategory.unknown;
  }

  /// Returns the category from a full file path.
  static FileCategory getCategoryFromPath(String path) {
    return getCategory(getExtension(path));
  }

  // ── File Type Checks ────────────────────────────────────────────

  /// Whether the file at [path] is an image (jpg, png, gif, webp, bmp, tiff).
  static bool isImage(String path) =>
      getCategoryFromPath(path) == FileCategory.image;

  /// Whether the file at [path] is a PDF.
  static bool isPdf(String path) => getCategoryFromPath(path) == FileCategory.pdf;

  /// Whether the file at [path] is a supported document (pdf, doc, docx).
  static bool isDocument(String path) {
    final cat = getCategoryFromPath(path);
    return cat == FileCategory.pdf ||
        cat == FileCategory.document ||
        cat == FileCategory.spreadsheet ||
        cat == FileCategory.presentation;
  }

  /// Whether the given extension is supported for scanning / OCR.
  static bool isSupportedForOcr(String extension) {
    const supported = {'jpg', 'jpeg', 'png', 'webp', 'bmp', 'tiff', 'tif', 'pdf'};
    return supported.contains(extension.toLowerCase());
  }

  // ── File Name Sanitisation ──────────────────────────────────────

  /// Sanitises a file name by replacing illegal characters with [_].
  static String sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_').trim();
  }

  /// Generates a unique file name by appending a timestamp if needed.
  static String makeUniqueFileName(String basePath, {String? extension}) {
    final ext = extension ?? getExtensionWithDot(basePath);
    final base = getBaseName(basePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${base}_$timestamp$ext';
  }

  // ── Storage Helpers ─────────────────────────────────────────────

  /// Returns a percentage string for storage usage.
  ///
  /// ```dart
  /// storageUsagePercentage(512, 1024) // → "50.0%"
  /// ```
  static String storageUsagePercentage(int usedBytes, int totalBytes) {
    if (totalBytes <= 0) return '0%';
    final percentage = (usedBytes / totalBytes) * 100;
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Returns the storage usage as a double between 0.0 and 1.0.
  static double storageUsageRatio(int usedBytes, int totalBytes) {
    if (totalBytes <= 0) return 0.0;
    return (usedBytes / totalBytes).clamp(0.0, 1.0);
  }
}
