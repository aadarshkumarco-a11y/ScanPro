import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/pdf_document.dart';
import '../../domain/entities/pdf_operation.dart';
import '../models/pdf_document_model.dart';

/// Local data source for PDF operations history using Hive for persistence.
///
/// Stores PDF documents and operation results for history and recovery.
/// All methods throw [CacheException] on failure so that the repository
/// implementation can convert them to [Failure]s.
class PdfLocalDatasource {
  PdfLocalDatasource({
    required Box<dynamic> cacheBox,
  }) : _box = cacheBox;

  final Box<dynamic> _box;
  static const _uuid = Uuid();

  /// Hive key prefix for PDF documents.
  static const _docPrefix = 'pdf_doc_';

  /// Hive key prefix for operation results.
  static const _opPrefix = 'pdf_op_';

  // ── PDF Document Operations ────────────────────────────────────────

  /// Saves a [PdfDocument] to the Hive box.
  Future<PdfDocumentModel> savePdfDocument(PdfDocument document) async {
    try {
      final id =
          document.id.isEmpty ? '${_docPrefix}${_uuid.v4()}' : document.id;

      final model = PdfDocumentModel(
        id: id,
        filePath: document.filePath,
        fileName: document.fileName,
        pageCount: document.pageCount,
        fileSize: document.fileSize,
        createdAt: document.createdAt,
        isEncrypted: document.isEncrypted,
        metadata: document.metadata,
      );

      await _box.put(id, model.toHive());
      return model;
    } catch (e) {
      throw CacheException(
        message: 'Failed to save PDF document: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Retrieves all PDF documents from the Hive box.
  List<PdfDocumentModel> getPdfDocuments() {
    try {
      final documents = <PdfDocumentModel>[];

      for (final key in _box.keys) {
        if (key is String && key.startsWith(_docPrefix)) {
          final value = _box.get(key);
          if (value is Map) {
            documents.add(
              PdfDocumentModel.fromHive(Map<dynamic, dynamic>.from(value)),
            );
          }
        }
      }

      documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return documents;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read PDF documents: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Retrieves a single PDF document by ID.
  PdfDocumentModel getPdfDocumentById(String documentId) {
    try {
      final key = documentId.startsWith(_docPrefix)
          ? documentId
          : '$_docPrefix$documentId';
      final value = _box.get(key);
      if (value == null) {
        throw CacheException(
          message: 'PDF document with id "$documentId" not found.',
          code: 1001,
        );
      }
      if (value is Map) {
        return PdfDocumentModel.fromHive(Map<dynamic, dynamic>.from(value));
      }
      throw CacheException(
        message: 'Corrupted data for PDF document "$documentId".',
        code: 1004,
      );
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read PDF document: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Deletes a PDF document by ID.
  Future<void> deletePdfDocument(String documentId) async {
    try {
      final key = documentId.startsWith(_docPrefix)
          ? documentId
          : '$_docPrefix$documentId';

      // Attempt to clean up file on disk
      final value = _box.get(key);
      if (value is Map) {
        final model =
            PdfDocumentModel.fromHive(Map<dynamic, dynamic>.from(value));
        final file = File(model.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      await _box.delete(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete PDF document: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Operation Result Operations ────────────────────────────────────

  /// Saves an operation result to the Hive box.
  Future<PdfOperationResultModel> saveOperationResult(
    PdfOperationResult result,
  ) async {
    try {
      final id = result.id.isEmpty ? '${_opPrefix}${_uuid.v4()}' : result.id;

      final model = PdfOperationResultModel(
        id: id,
        operation: result.operation,
        outputPath: result.outputPath,
        success: result.success,
        originalSize: result.originalSize,
        resultSize: result.resultSize,
        pageCount: result.pageCount,
        errorMessage: result.errorMessage,
        completedAt: result.completedAt,
      );

      await _box.put(id, model.toHive());
      return model;
    } catch (e) {
      throw CacheException(
        message: 'Failed to save operation result: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Retrieves all operation results from the Hive box.
  List<PdfOperationResultModel> getOperationResults() {
    try {
      final results = <PdfOperationResultModel>[];

      for (final key in _box.keys) {
        if (key is String && key.startsWith(_opPrefix)) {
          final value = _box.get(key);
          if (value is Map) {
            results.add(
              PdfOperationResultModel.fromHive(
                Map<dynamic, dynamic>.from(value),
              ),
            );
          }
        }
      }

      results.sort((a, b) =>
          (b.completedAt ?? DateTime.now())
              .compareTo(a.completedAt ?? DateTime.now()));
      return results;
    } catch (e) {
      throw CacheException(
        message: 'Failed to read operation results: ${e.toString()}',
        code: 1003,
      );
    }
  }

  // ── File Helpers ──────────────────────────────────────────────────

  /// Returns the directory where PDF files are stored.
  static Future<Directory> getPdfDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${appDir.path}/pdfs');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir;
  }

  /// Generates a unique file name for a PDF.
  static String generatePdfFileName([String? prefix]) {
    final now = DateTime.now();
    final timestamp =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
    return '${prefix ?? 'ScanPro'}_$timestamp.pdf';
  }
}
