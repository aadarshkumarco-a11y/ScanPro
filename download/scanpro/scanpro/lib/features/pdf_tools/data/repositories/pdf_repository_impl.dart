import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_document.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_operation.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';
import 'package:scanpro/features/pdf_tools/data/models/pdf_document_model.dart';
import 'package:scanpro/features/pdf_tools/data/services/syncfusion_pdf_service.dart';

/// Implementation of [PDFRepository] using Syncfusion PDF library.
///
/// Delegates all PDF operations to the [SyncfusionPDFService],
/// handling error mapping between service exceptions and domain failures.
class PDFRepositoryImpl implements PDFRepository {
  final SyncfusionPDFService _pdfService;

  PDFRepositoryImpl({
    required SyncfusionPDFService pdfService,
  }) : _pdfService = pdfService;

  @override
  Future<Either<Failure, PDFDocument>> createPDF(
    List<String> imagePaths, {
    String? title,
  }) async {
    try {
      final result = await _pdfService.createPDFFromImages(
        imagePaths,
        title: title ?? 'Untitled',
      );
      return Right(result);
    } on PDFServiceException catch (e) {
      return Left(PDFFailure(message: e.message));
    } catch (e) {
      return Left(PDFFailure(message: 'Failed to create PDF: $e'));
    }
  }

  @override
  Future<Either<Failure, PDFOperationResult>> mergePDFs(
    List<String> pdfPaths, {
    String? outputTitle,
  }) async {
    try {
      final outputPath = await _pdfService.mergePDFs(
        pdfPaths,
        outputTitle: outputTitle ?? 'Merged Document',
      );

      final originalSize = await _pdfService.getFileSize(pdfPaths.first);
      final resultSize = await _pdfService.getFileSize(outputPath);

      return Right(PDFOperationResult(
        operation: PDFOperation.merge,
        outputPaths: [outputPath],
        originalSize: originalSize,
        resultSize: resultSize,
        metadata: {'sourceCount': pdfPaths.length},
      ));
    } on PDFServiceException catch (e) {
      return Left(PDFFailure(message: e.message));
    } catch (e) {
      return Left(PDFFailure(message: 'Failed to merge PDFs: $e'));
    }
  }

  @override
  Future<Either<Failure, PDFOperationResult>> splitPDF(
    String pdfPath,
    List<String> ranges,
  ) async {
    try {
      final outputPaths = await _pdfService.splitPDF(pdfPath, ranges);
      final originalSize = await _pdfService.getFileSize(pdfPath);

      return Right(PDFOperationResult(
        operation: PDFOperation.split,
        outputPaths: outputPaths,
        originalSize: originalSize,
        metadata: {'rangeCount': ranges.length},
      ));
    } on PDFServiceException catch (e) {
      return Left(PDFFailure(message: e.message));
    } catch (e) {
      return Left(PDFFailure(message: 'Failed to split PDF: $e'));
    }
  }

  @override
  Future<Either<Failure, PDFOperationResult>> compressPDF(
    String pdfPath, {
    int quality = 75,
  }) async {
    try {
      final outputPath = await _pdfService.compressPDF(
        pdfPath,
        quality: quality,
      );
      final originalSize = await _pdfService.getFileSize(pdfPath);
      final resultSize = await _pdfService.getFileSize(outputPath);

      return Right(PDFOperationResult(
        operation: PDFOperation.compress,
        outputPaths: [outputPath],
        originalSize: originalSize,
        resultSize: resultSize,
        metadata: {'quality': quality},
      ));
    } on PDFServiceException catch (e) {
      return Left(PDFFailure(message: e.message));
    } catch (e) {
      return Left(PDFFailure(message: 'Failed to compress PDF: $e'));
    }
  }

  @override
  Future<Either<Failure, PDFOperationResult>> rearrangePages(
    String pdfPath,
    List<int> newOrder,
  ) async {
    try {
      final outputPath = await _pdfService.rearrangePages(
        pdfPath,
        newOrder,
      );
      final fileSize = await _pdfService.getFileSize(outputPath);

      return Right(PDFOperationResult(
        operation: PDFOperation.rearrange,
        outputPaths: [outputPath],
        originalSize: fileSize,
        resultSize: fileSize,
        metadata: {'pageOrder': newOrder},
      ));
    } on PDFServiceException catch (e) {
      return Left(PDFFailure(message: e.message));
    } catch (e) {
      return Left(PDFFailure(message: 'Failed to rearrange pages: $e'));
    }
  }

  @override
  Future<Either<Failure, PDFOperationResult>> rotatePage(
    String pdfPath,
    int pageIndex,
    int degrees,
  ) async {
    try {
      final outputPath = await _pdfService.rotatePage(
        pdfPath,
        pageIndex,
        degrees,
      );
      final fileSize = await _pdfService.getFileSize(outputPath);

      return Right(PDFOperationResult(
        operation: PDFOperation.rotate,
        outputPaths: [outputPath],
        originalSize: fileSize,
        resultSize: fileSize,
        metadata: {'pageIndex': pageIndex, 'degrees': degrees},
      ));
    } on PDFServiceException catch (e) {
      return Left(PDFFailure(message: e.message));
    } catch (e) {
      return Left(PDFFailure(message: 'Failed to rotate page: $e'));
    }
  }

  @override
  Future<Either<Failure, PDFOperationResult>> insertPage(
    String targetPdfPath,
    String sourcePdfPath,
    int sourcePageIndex,
    int targetPageIndex,
  ) async {
    try {
      final outputPath = await _pdfService.insertPage(
        targetPdfPath,
        sourcePdfPath,
        sourcePageIndex,
        targetPageIndex,
      );
      final fileSize = await _pdfService.getFileSize(outputPath);

      return Right(PDFOperationResult(
        operation: PDFOperation.insert,
        outputPaths: [outputPath],
        originalSize: fileSize,
        resultSize: fileSize,
        metadata: {
          'sourcePageIndex': sourcePageIndex,
          'targetPageIndex': targetPageIndex,
        },
      ));
    } on PDFServiceException catch (e) {
      return Left(PDFFailure(message: e.message));
    } catch (e) {
      return Left(PDFFailure(message: 'Failed to insert page: $e'));
    }
  }

  @override
  Future<Either<Failure, PDFOperationResult>> deletePage(
    String pdfPath,
    List<int> pageIndices,
  ) async {
    try {
      final outputPath = await _pdfService.deletePages(
        pdfPath,
        pageIndices,
      );
      final originalSize = await _pdfService.getFileSize(pdfPath);
      final resultSize = await _pdfService.getFileSize(outputPath);

      return Right(PDFOperationResult(
        operation: PDFOperation.delete,
        outputPaths: [outputPath],
        originalSize: originalSize,
        resultSize: resultSize,
        metadata: {'deletedPages': pageIndices},
      ));
    } on PDFServiceException catch (e) {
      return Left(PDFFailure(message: e.message));
    } catch (e) {
      return Left(PDFFailure(message: 'Failed to delete page: $e'));
    }
  }

  @override
  Future<Either<Failure, PDFOperationResult>> replacePage(
    String targetPdfPath,
    String sourcePdfPath,
    int sourcePageIndex,
    int targetPageIndex,
  ) async {
    try {
      final outputPath = await _pdfService.replacePage(
        targetPdfPath,
        sourcePdfPath,
        sourcePageIndex,
        targetPageIndex,
      );
      final fileSize = await _pdfService.getFileSize(outputPath);

      return Right(PDFOperationResult(
        operation: PDFOperation.replace,
        outputPaths: [outputPath],
        originalSize: fileSize,
        resultSize: fileSize,
        metadata: {
          'sourcePageIndex': sourcePageIndex,
          'targetPageIndex': targetPageIndex,
        },
      ));
    } on PDFServiceException catch (e) {
      return Left(PDFFailure(message: e.message));
    } catch (e) {
      return Left(PDFFailure(message: 'Failed to replace page: $e'));
    }
  }
}
