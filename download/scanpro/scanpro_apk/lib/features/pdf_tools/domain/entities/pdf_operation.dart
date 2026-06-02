import 'package:equatable/equatable.dart';

/// Enum representing the different PDF operations available.
enum PdfOperation {
  merge,
  split,
  compress,
  create,
  watermark,
  password;

  /// Returns a human-readable display name for the operation.
  String get displayName {
    switch (this) {
      case PdfOperation.merge:
        return 'Merge PDFs';
      case PdfOperation.split:
        return 'Split PDF';
      case PdfOperation.compress:
        return 'Compress PDF';
      case PdfOperation.create:
        return 'Create PDF';
      case PdfOperation.watermark:
        return 'Add Watermark';
      case PdfOperation.password:
        return 'Protect PDF';
    }
  }

  /// Returns a description for the operation.
  String get description {
    switch (this) {
      case PdfOperation.merge:
        return 'Combine multiple PDFs into one';
      case PdfOperation.split:
        return 'Split a PDF into separate pages';
      case PdfOperation.compress:
        return 'Reduce PDF file size';
      case PdfOperation.create:
        return 'Create PDF from images';
      case PdfOperation.watermark:
        return 'Add text or image watermark';
      case PdfOperation.password:
        return 'Add password protection';
    }
  }

  /// Returns the icon for the operation.
  int get iconCode {
    switch (this) {
      case PdfOperation.merge:
        return 0xe666; // merge_type
      case PdfOperation.split:
        return 0xe0e3; // call_split
      case PdfOperation.compress:
        return 0xe3d2; // compress
      case PdfOperation.create:
        return 0xe24d; // note_add
      case PdfOperation.watermark:
        return 0xe44e; // branding_watermark
      case PdfOperation.password:
        return 0xe897; // lock
    }
  }
}

/// Domain entity representing the result of a PDF operation.
///
/// Contains information about the output file, operation type,
/// compression metrics, and whether the operation succeeded.
class PdfOperationResult extends Equatable {
  const PdfOperationResult({
    required this.id,
    required this.operation,
    required this.outputPath,
    required this.success,
    this.originalSize = 0,
    this.resultSize = 0,
    this.pageCount = 0,
    this.errorMessage,
    this.completedAt,
  });

  /// Unique identifier for this operation result.
  final String id;

  /// The type of PDF operation performed.
  final PdfOperation operation;

  /// Absolute file path to the output PDF.
  final String outputPath;

  /// Whether the operation completed successfully.
  final bool success;

  /// Original file size in bytes (before operation).
  final int originalSize;

  /// Result file size in bytes (after operation).
  final int resultSize;

  /// Number of pages in the output PDF.
  final int pageCount;

  /// Error message if the operation failed.
  final String? errorMessage;

  /// Timestamp when the operation completed.
  final DateTime? completedAt;

  /// Compression ratio (0.0 to 1.0), where 1.0 means no compression.
  double get compressionRatio =>
      originalSize > 0 ? resultSize / originalSize : 1.0;

  /// Percentage of size reduction (e.g. 45.5 means 45.5% smaller).
  double get compressionPercentage =>
      originalSize > 0 ? (1 - compressionRatio) * 100 : 0;

  /// Human-readable original size.
  String get originalSizeFormatted => _formatBytes(originalSize);

  /// Human-readable result size.
  String get resultSizeFormatted => _formatBytes(resultSize);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Creates a copy with optional field overrides.
  PdfOperationResult copyWith({
    String? id,
    PdfOperation? operation,
    String? outputPath,
    bool? success,
    int? originalSize,
    int? resultSize,
    int? pageCount,
    String? errorMessage,
    DateTime? completedAt,
  }) {
    return PdfOperationResult(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      outputPath: outputPath ?? this.outputPath,
      success: success ?? this.success,
      originalSize: originalSize ?? this.originalSize,
      resultSize: resultSize ?? this.resultSize,
      pageCount: pageCount ?? this.pageCount,
      errorMessage: errorMessage ?? this.errorMessage,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        operation,
        outputPath,
        success,
        originalSize,
        resultSize,
        pageCount,
        errorMessage,
        completedAt,
      ];
}
