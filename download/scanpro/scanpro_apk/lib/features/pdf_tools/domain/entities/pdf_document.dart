import 'package:equatable/equatable.dart';

/// Domain entity representing a PDF document with metadata.
///
/// Contains file information, page count, size, encryption status,
/// and optional metadata fields for comprehensive PDF management.
class PdfDocument extends Equatable {
  const PdfDocument({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.pageCount,
    required this.fileSize,
    required this.createdAt,
    this.isEncrypted = false,
    this.metadata = const PdfDocumentMetadata(),
  });

  /// Unique identifier for this PDF document.
  final String id;

  /// Absolute file path to the PDF file.
  final String filePath;

  /// Display name of the PDF file.
  final String fileName;

  /// Number of pages in the PDF.
  final int pageCount;

  /// File size in bytes.
  final int fileSize;

  /// Timestamp when this PDF was created / added.
  final DateTime createdAt;

  /// Whether the PDF is password-protected.
  final bool isEncrypted;

  /// Optional PDF metadata (title, author, etc.).
  final PdfDocumentMetadata metadata;

  /// Human-readable file size string.
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Creates a copy with optional field overrides.
  PdfDocument copyWith({
    String? id,
    String? filePath,
    String? fileName,
    int? pageCount,
    int? fileSize,
    DateTime? createdAt,
    bool? isEncrypted,
    PdfDocumentMetadata? metadata,
  }) {
    return PdfDocument(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      pageCount: pageCount ?? this.pageCount,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        filePath,
        fileName,
        pageCount,
        fileSize,
        createdAt,
        isEncrypted,
        metadata,
      ];
}

/// Metadata associated with a PDF document.
class PdfDocumentMetadata extends Equatable {
  const PdfDocumentMetadata({
    this.title,
    this.author,
    this.subject,
    this.keywords,
    this.creator,
    this.producer,
    this.creationDate,
    this.modificationDate,
  });

  /// Document title.
  final String? title;

  /// Document author.
  final String? author;

  /// Document subject.
  final String? subject;

  /// Keywords associated with the document.
  final String? keywords;

  /// Application that created the original document.
  final String? creator;

  /// Application that produced the PDF.
  final String? producer;

  /// Date the document was created.
  final DateTime? creationDate;

  /// Date the document was last modified.
  final DateTime? modificationDate;

  /// Creates a copy with optional field overrides.
  PdfDocumentMetadata copyWith({
    String? title,
    String? author,
    String? subject,
    String? keywords,
    String? creator,
    String? producer,
    DateTime? creationDate,
    DateTime? modificationDate,
  }) {
    return PdfDocumentMetadata(
      title: title ?? this.title,
      author: author ?? this.author,
      subject: subject ?? this.subject,
      keywords: keywords ?? this.keywords,
      creator: creator ?? this.creator,
      producer: producer ?? this.producer,
      creationDate: creationDate ?? this.creationDate,
      modificationDate: modificationDate ?? this.modificationDate,
    );
  }

  @override
  List<Object?> get props => [
        title,
        author,
        subject,
        keywords,
        creator,
        producer,
        creationDate,
        modificationDate,
      ];
}
