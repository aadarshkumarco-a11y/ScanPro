import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_document.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_operation.dart';

/// Abstract repository defining the contract for PDF operations.
///
/// Provides comprehensive PDF manipulation capabilities including
/// creation, merging, splitting, compression, and page management.
abstract class PDFRepository {
  /// Creates a new PDF from a list of image paths.
  ///
  /// [imagePaths] are the absolute paths to images to include.
  /// [title] is the display name for the PDF.
  /// Returns the created [PDFDocument].
  Future<Either<Failure, PDFDocument>> createPDF(
    List<String> imagePaths, {
    String? title,
  });

  /// Merges multiple PDF files into a single document.
  ///
  /// [pdfPaths] are the absolute paths to PDFs to merge.
  /// [outputTitle] is the name for the merged PDF.
  /// Returns the [PDFOperationResult] with the output path.
  Future<Either<Failure, PDFOperationResult>> mergePDFs(
    List<String> pdfPaths, {
    String? outputTitle,
  });

  /// Splits a PDF into multiple documents based on page ranges.
  ///
  /// [pdfPath] is the source PDF path.
  /// [ranges] is a list of page ranges (e.g., ['1-3', '4-6']).
  /// Returns the [PDFOperationResult] with output paths for each split.
  Future<Either<Failure, PDFOperationResult>> splitPDF(
    String pdfPath,
    List<String> ranges,
  );

  /// Compresses a PDF to reduce file size.
  ///
  /// [pdfPath] is the source PDF path.
  /// [quality] is the compression quality (0-100, where 100 is lossless).
  /// Returns the [PDFOperationResult] with compression metrics.
  Future<Either<Failure, PDFOperationResult>> compressPDF(
    String pdfPath, {
    int quality = 75,
  });

  /// Rearranges pages in a PDF according to the new order.
  ///
  /// [pdfPath] is the source PDF path.
  /// [newOrder] is the list of page indices in the desired order (0-based).
  /// Returns the [PDFOperationResult] with the output path.
  Future<Either<Failure, PDFOperationResult>> rearrangePages(
    String pdfPath,
    List<int> newOrder,
  );

  /// Rotates a specific page in the PDF.
  ///
  /// [pdfPath] is the source PDF path.
  /// [pageIndex] is the 0-based page index.
  /// [degrees] is the rotation angle (90, 180, 270).
  /// Returns the [PDFOperationResult] with the output path.
  Future<Either<Failure, PDFOperationResult>> rotatePage(
    String pdfPath,
    int pageIndex,
    int degrees,
  );

  /// Inserts a page from one PDF into another at a specific position.
  ///
  /// [targetPdfPath] is the PDF to insert into.
  /// [sourcePdfPath] is the PDF containing the page to insert.
  /// [sourcePageIndex] is the 0-based page index in the source.
  /// [targetPageIndex] is the 0-based insertion position in the target.
  /// Returns the [PDFOperationResult] with the output path.
  Future<Either<Failure, PDFOperationResult>> insertPage(
    String targetPdfPath,
    String sourcePdfPath,
    int sourcePageIndex,
    int targetPageIndex,
  );

  /// Deletes pages from a PDF.
  ///
  /// [pdfPath] is the source PDF path.
  /// [pageIndices] are the 0-based page indices to delete.
  /// Returns the [PDFOperationResult] with the output path.
  Future<Either<Failure, PDFOperationResult>> deletePage(
    String pdfPath,
    List<int> pageIndices,
  );

  /// Replaces a page in one PDF with a page from another.
  ///
  /// [targetPdfPath] is the PDF to modify.
  /// [sourcePdfPath] is the PDF containing the replacement page.
  /// [sourcePageIndex] is the 0-based page index in the source.
  /// [targetPageIndex] is the 0-based page index to replace.
  /// Returns the [PDFOperationResult] with the output path.
  Future<Either<Failure, PDFOperationResult>> replacePage(
    String targetPdfPath,
    String sourcePdfPath,
    int sourcePageIndex,
    int targetPageIndex,
  );
}
