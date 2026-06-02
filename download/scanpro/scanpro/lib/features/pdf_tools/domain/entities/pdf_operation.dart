import 'package:equatable/equatable.dart';

/// Enumeration of supported PDF operations.
enum PDFOperation {
  /// Create a new PDF from images.
  create,

  /// Merge multiple PDFs into one.
  merge,

  /// Split a PDF into multiple documents.
  split,

  /// Compress a PDF to reduce file size.
  compress,

  /// Rearrange page order.
  rearrange,

  /// Rotate one or more pages.
  rotate,

  /// Insert a page at a specific position.
  insert,

  /// Delete pages from the PDF.
  delete,

  /// Replace a page with another.
  replace,

  /// Add watermark to the PDF.
  watermark,
}

/// Represents the result of a PDF operation.
///
/// Contains the output file path(s), operation type performed,
/// and metrics about the operation such as compression ratio.
class PDFOperationResult extends Equatable {
  /// The type of operation that was performed.
  final PDFOperation operation;

  /// Path(s) to the output file(s).
  /// Single path for most operations, multiple for split.
  final List<String> outputPaths;

  /// Original file size in bytes before the operation.
  final int originalSize;

  /// Resulting file size in bytes after the operation.
  final int resultSize;

  /// Additional metadata about the operation (e.g., pages affected).
  final Map<String, dynamic> metadata;

  const PDFOperationResult({
    required this.operation,
    required this.outputPaths,
    this.originalSize = 0,
    this.resultSize = 0,
    this.metadata = const {},
  });

  /// Compression ratio (0.0–1.0) for compress operations.
  /// Returns 1.0 if original size is 0.
  double get compressionRatio =>
      originalSize > 0 ? resultSize / originalSize : 1.0;

  /// Percentage of space saved by compression.
  double get spaceSavedPercent => (1.0 - compressionRatio) * 100;

  /// Whether the operation resulted in size reduction.
  bool get wasCompressed => resultSize < originalSize;

  /// Single output path (convenience for non-split operations).
  String get outputPath =>
      outputPaths.isNotEmpty ? outputPaths.first : '';

  @override
  List<Object?> get props => [
        operation,
        outputPaths,
        originalSize,
        resultSize,
        metadata,
      ];
}
