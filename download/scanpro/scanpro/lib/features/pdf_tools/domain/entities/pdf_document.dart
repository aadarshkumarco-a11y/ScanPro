import 'package:equatable/equatable.dart';

/// Entity representing a PDF document in the application.
///
/// Contains metadata about the PDF file including its path,
/// size, page count, and timestamps.
class PDFDocument extends Equatable {
  /// Unique identifier for the PDF document.
  final String id;

  /// Display title of the PDF document.
  final String title;

  /// Absolute file path to the PDF file.
  final String filePath;

  /// File size in bytes.
  final int fileSize;

  /// Number of pages in the PDF.
  final int pageCount;

  /// Timestamp when the PDF was created.
  final DateTime createdAt;

  /// Timestamp when the PDF was last modified.
  final DateTime updatedAt;

  const PDFDocument({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileSize,
    this.pageCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// File size formatted as a human-readable string (e.g., '2.4 MB').
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Creates a copy with optional field overrides.
  PDFDocument copyWith({
    String? id,
    String? title,
    String? filePath,
    int? fileSize,
    int? pageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PDFDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      pageCount: pageCount ?? this.pageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        filePath,
        fileSize,
        pageCount,
        createdAt,
        updatedAt,
      ];
}
