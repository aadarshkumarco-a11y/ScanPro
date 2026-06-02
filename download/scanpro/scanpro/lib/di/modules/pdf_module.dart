/// PDF feature module — provides all Riverpod providers related to
/// PDF creation, manipulation, and rendering via Syncfusion PDF.
///
/// Supports merging, splitting, compression, page editing, annotation
/// management, and interactive PDF viewing.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/pdf_repository.dart';
import '../../domain/usecases/pdf/create_pdf_usecase.dart';
import '../../domain/usecases/pdf/merge_pdf_usecase.dart';
import '../../domain/usecases/pdf/split_pdf_usecase.dart';
import '../../domain/usecases/pdf/compress_pdf_usecase.dart';
import '../../domain/usecases/pdf/annotate_pdf_usecase.dart';
import '../../data/datasources/pdf_local_data_source.dart';
import '../../data/repositories/pdf_repository_impl.dart';
import '../injection.dart';

// ---------------------------------------------------------------------------
// Data Sources
// ---------------------------------------------------------------------------

/// Local data source that manages PDF file I/O and metadata persistence.
final pdfLocalDataSourceProvider = Provider<PDFLocalDataSource>((ref) {
  final box = ref.watch(hiveBoxProvider);
  return PDFLocalDataSource(box: box);
});

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

/// Core PDF service backed by Syncfusion Flutter PDF.
///
/// Provides low-level operations: create, load, save, and render PDF
/// documents. Higher-level business logic lives in use cases.
final pdfServiceProvider = Provider<PDFService>((ref) {
  return PDFService();
});

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Primary [PDFRepository] implementation backed by the Syncfusion
/// PDF service and local file storage.
final pdfRepositoryProvider = Provider<PDFRepository>((ref) {
  final localDataSource = ref.watch(pdfLocalDataSourceProvider);
  final pdfService = ref.watch(pdfServiceProvider);
  return PDFRepositoryImpl(
    localDataSource: localDataSource,
    pdfService: pdfService,
  );
});

// ---------------------------------------------------------------------------
// Use Cases
// ---------------------------------------------------------------------------

/// Creates a new PDF document from a list of scanned image paths,
/// applying the specified page size and orientation.
final createPdfUseCaseProvider = Provider<CreatePdfUseCase>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return CreatePdfUseCase(repository: repository);
});

/// Merges multiple PDF files into a single document, preserving
/// page order and embedded annotations.
final mergePdfUseCaseProvider = Provider<MergePdfUseCase>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return MergePdfUseCase(repository: repository);
});

/// Splits a PDF into one or more smaller documents based on page ranges
/// or bookmark sections.
final splitPdfUseCaseProvider = Provider<SplitPdfUseCase>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return SplitPdfUseCase(repository: repository);
});

/// Reduces PDF file size by compressing images, downsampling, and
/// removing redundant font data. Quality level: [0.0 (max compression)
/// to 1.0 (lossless)].
final compressPdfUseCaseProvider = Provider<CompressPdfUseCase>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return CompressPdfUseCase(repository: repository);
});

/// Adds, updates, or removes annotations (highlights, notes, shapes,
/// signatures) on specific PDF pages.
final annotatePdfUseCaseProvider = Provider<AnnotatePdfUseCase>((ref) {
  final repository = ref.watch(pdfRepositoryProvider);
  return AnnotatePdfUseCase(repository: repository);
});

// ---------------------------------------------------------------------------
// Service Class (inline for DI wiring)
// ---------------------------------------------------------------------------

/// Wraps Syncfusion PDF for document creation and manipulation.
class PDFService {
  /// Creates a PDF from the given [imagePaths] and returns the output
  /// file path. [pageSize] defaults to A4, [orientation] to portrait.
  Future<String> createFromImages(
    List<String> imagePaths, {
    String pageSize = 'A4',
    String orientation = 'portrait',
  }) async {
    throw UnimplementedError(
      'PDFService.createFromImages must be implemented',
    );
  }

  /// Loads an existing PDF from [filePath] and returns a structured
  /// representation with page count and metadata.
  Future<PDFDocumentInfo> loadDocument(String filePath) async {
    throw UnimplementedError('PDFService.loadDocument must be implemented');
  }

  /// Merges the PDF files at [filePaths] into a single document saved
  /// at [outputPath].
  Future<String> mergeDocuments(
    List<String> filePaths,
    String outputPath,
  ) async {
    throw UnimplementedError(
      'PDFService.mergeDocuments must be implemented',
    );
  }

  /// Extracts pages in [pageRanges] from the PDF at [filePath] and
  /// saves the result to [outputPath].
  Future<List<String>> splitDocument(
    String filePath,
    List<List<int>> pageRanges,
    String outputDir,
  ) async {
    throw UnimplementedError('PDFService.splitDocument must be implemented');
  }

  /// Compresses the PDF at [filePath] with the given [quality] level
  /// (0.0–1.0) and returns the compressed file path.
  Future<String> compressDocument(
    String filePath,
    double quality,
  ) async {
    throw UnimplementedError(
      'PDFService.compressDocument must be implemented',
    );
  }
}

/// Metadata and statistics for a loaded PDF document.
class PDFDocumentInfo {
  const PDFDocumentInfo({
    required this.filePath,
    required this.pageCount,
    required this.fileSize,
    required this.title,
    required this.author,
    required this.isEncrypted,
  });

  /// Absolute path to the PDF file on disk.
  final String filePath;

  /// Total number of pages in the document.
  final int pageCount;

  /// File size in bytes.
  final int fileSize;

  /// Document title from metadata, or the filename if absent.
  final String title;

  /// Document author from metadata.
  final String author;

  /// Whether the document has encryption / password protection.
  final bool isEncrypted;
}
