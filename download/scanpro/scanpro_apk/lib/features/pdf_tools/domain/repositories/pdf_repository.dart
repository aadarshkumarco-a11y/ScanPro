import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_document.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_operation.dart';

/// Abstract repository contract for PDF operations.
///
/// Defines the domain-level API for creating, merging, splitting,
/// compressing, watermarking, and password-protecting PDF documents.
/// Implementations must convert data-layer exceptions into [Failure]s.
abstract class PdfRepository {
  /// Creates a PDF from a list of image file paths.
  ///
  /// [imagePaths] are absolute paths to images (one per page).
  /// [fileName] is the desired output file name.
  /// Returns the created [PdfDocument] on success, or a [PdfFailure].
  Future<Either<Failure, PdfDocument>> createPdf({
    required List<String> imagePaths,
    required String fileName,
  });

  /// Merges multiple PDF files into a single PDF.
  ///
  /// [pdfPaths] must contain at least two file paths.
  /// [outputFileName] is the desired output file name.
  /// Returns the merged [PdfDocument] on success, or a [PdfFailure].
  Future<Either<Failure, PdfDocument>> mergePdfs({
    required List<String> pdfPaths,
    required String outputFileName,
  });

  /// Splits a PDF by page ranges.
  ///
  /// [pdfPath] is the source PDF file path.
  /// [pageRanges] is a list of page range strings (e.g. ['1-3', '5', '7-10']).
  /// Returns a list of [PdfDocument]s (one per range) on success.
  Future<Either<Failure, List<PdfDocument>>> splitPdf({
    required String pdfPath,
    required List<String> pageRanges,
  });

  /// Compresses a PDF to reduce file size.
  ///
  /// [pdfPath] is the source PDF file path.
  /// [quality] is the compression quality (0.0 to 1.0).
  /// Returns the compressed [PdfOperationResult] on success.
  Future<Either<Failure, PdfOperationResult>> compressPdf({
    required String pdfPath,
    required double quality,
  });

  /// Adds a text watermark to every page of a PDF.
  ///
  /// [pdfPath] is the source PDF file path.
  /// [watermarkText] is the text to use as a watermark.
  /// [fontSize] is the watermark font size.
  /// Returns the watermarked [PdfDocument] on success.
  Future<Either<Failure, PdfDocument>> addWatermark({
    required String pdfPath,
    required String watermarkText,
    double fontSize = 48,
  });

  /// Protects a PDF with a password.
  ///
  /// [pdfPath] is the source PDF file path.
  /// [password] is the user password to set.
  /// Returns the protected [PdfDocument] on success.
  Future<Either<Failure, PdfDocument>> protectPdf({
    required String pdfPath,
    required String password,
  });

  /// Retrieves information about a PDF file.
  ///
  /// [pdfPath] is the file path to inspect.
  /// Returns the [PdfDocument] with metadata on success.
  Future<Either<Failure, PdfDocument>> getPdfInfo({
    required String pdfPath,
  });
}
