import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/scanned_document.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/scanner_local_datasource.dart';
import '../models/scanned_document_model.dart';

/// Concrete implementation of [ScannerRepository].
///
/// Delegates local persistence to [ScannerLocalDatasource] and
/// performs image processing (crop, enhance, rotate, filter) using
/// the `image` package. All exceptions are caught and converted to
/// the appropriate [Failure] subclass.
class ScannerRepositoryImpl implements ScannerRepository {
  ScannerRepositoryImpl({
    required ScannerLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  final ScannerLocalDatasource _localDatasource;
  static const _uuid = Uuid();

  // ── Scan ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ScannedDocument>> scanDocument() async {
    try {
      // In production, this would open the camera and capture an image.
      // For now, we create a placeholder document entry.
      final scanDir = await ScannerLocalDatasource.getScanDirectory();
      final fileName = ScannerLocalDatasource.generateScanFileName();
      final filePath = '${scanDir.path}/$fileName';

      final now = DateTime.now();
      final document = ScannedDocument(
        id: _uuid.v4(),
        filePath: filePath,
        createdAt: now,
        updatedAt: now,
        name: 'Scan ${now.toIso8601String().substring(0, 19)}',
        pages: [
          ScannedPage(
            id: _uuid.v4(),
            filePath: filePath,
          ),
        ],
      );

      final saved = await _localDatasource.saveDocument(document);
      return Right(saved.toEntity());
    } on ScannerException catch (e) {
      return Left(ScannerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ScannerFailure(
        message: 'Unexpected scan error: ${e.toString()}',
        code: 6002,
      ));
    }
  }

  // ── Crop ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ScannedDocument>> cropImage({
    required String filePath,
    required List<double> cropArea,
    required ScannedDocument document,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(NotFoundFailure.file());
      }

      final bytes = await file.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) {
        return Left(ScannerFailure.imageProcessingError());
      }

      final w = original.width;
      final h = original.height;
      final x1 = (cropArea[0] * w).round();
      final y1 = (cropArea[1] * h).round();
      final x2 = (cropArea[2] * w).round();
      final y2 = (cropArea[3] * h).round();

      final cropped = img.copyCrop(
        original,
        x: x1,
        y: y1,
        width: x2 - x1,
        height: y2 - y1,
      );

      final croppedPath = await _writeProcessedImage(cropped, filePath, '_cropped');

      final updatedPages = document.pages.map((p) {
        if (p.filePath == filePath) {
          return p.copyWith(filePath: croppedPath, cropArea: cropArea);
        }
        return p;
      }).toList();

      final updated = document.copyWith(
        filePath: croppedPath,
        pages: updatedPages,
        updatedAt: DateTime.now(),
      );

      final saved = await _localDatasource.saveDocument(updated);
      return Right(saved.toEntity());
    } on ScannerException catch (e) {
      return Left(ScannerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ScannerFailure.imageProcessingError());
    }
  }

  // ── Enhance ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ScannedDocument>> enhanceImage({
    required String filePath,
    required ScannedDocument document,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(NotFoundFailure.file());
      }

      final bytes = await file.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) {
        return Left(ScannerFailure.imageProcessingError());
      }

      // Apply auto-contrast and slight sharpening.
      final enhanced = img.adjustColor(
        original,
        contrast: 1.2,
        brightness: 5,
      );

      final enhancedPath = await _writeProcessedImage(enhanced, filePath, '_enhanced');

      final updatedPages = document.pages.map((p) {
        if (p.filePath == filePath) {
          return p.copyWith(
            filePath: enhancedPath,
            brightness: 0.05,
            contrast: 1.2,
            filters: [...p.filters, 'enhanced'],
          );
        }
        return p;
      }).toList();

      final updated = document.copyWith(
        filePath: enhancedPath,
        pages: updatedPages,
        updatedAt: DateTime.now(),
      );

      final saved = await _localDatasource.saveDocument(updated);
      return Right(saved.toEntity());
    } on ScannerException catch (e) {
      return Left(ScannerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ScannerFailure.imageProcessingError());
    }
  }

  // ── Rotate ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ScannedDocument>> rotateImage({
    required String filePath,
    required int degrees,
    required ScannedDocument document,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(NotFoundFailure.file());
      }

      final bytes = await file.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) {
        return Left(ScannerFailure.imageProcessingError());
      }

      img.Image rotated;
      switch (degrees) {
        case 90:
          rotated = img.copyRotate(original, angle: 90);
          break;
        case 180:
          rotated = img.copyRotate(original, angle: 180);
          break;
        case 270:
          rotated = img.copyRotate(original, angle: 270);
          break;
        default:
          rotated = img.copyRotate(original, angle: degrees);
      }

      final rotatedPath = await _writeProcessedImage(rotated, filePath, '_rotated');

      final updatedPages = document.pages.map((p) {
        if (p.filePath == filePath) {
          return p.copyWith(filePath: rotatedPath, rotation: p.rotation + degrees);
        }
        return p;
      }).toList();

      final updated = document.copyWith(
        filePath: rotatedPath,
        pages: updatedPages,
        updatedAt: DateTime.now(),
      );

      final saved = await _localDatasource.saveDocument(updated);
      return Right(saved.toEntity());
    } on ScannerException catch (e) {
      return Left(ScannerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ScannerFailure.imageProcessingError());
    }
  }

  // ── Filter ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ScannedDocument>> applyFilter({
    required String filePath,
    required String filterName,
    required ScannedDocument document,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(NotFoundFailure.file());
      }

      final bytes = await file.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) {
        return Left(ScannerFailure.imageProcessingError());
      }

      img.Image filtered;
      switch (filterName) {
        case 'grayscale':
          filtered = img.grayscale(original);
          break;
        case 'bw':
          filtered = img.adjustColor(
            img.grayscale(original),
            contrast: 2.0,
            brightness: -20,
          );
          break;
        case 'magic_color':
          filtered = img.adjustColor(
            original,
            saturation: 1.5,
            contrast: 1.3,
            brightness: 10,
          );
          break;
        case 'brightened':
          filtered = img.adjustColor(
            original,
            brightness: 30,
            contrast: 1.1,
          );
          break;
        default:
          filtered = original;
      }

      final filteredPath = await _writeProcessedImage(filtered, filePath, '_$filterName');

      final updatedPages = document.pages.map((p) {
        if (p.filePath == filePath) {
          return p.copyWith(
            filePath: filteredPath,
            filters: [...p.filters, filterName],
          );
        }
        return p;
      }).toList();

      final updated = document.copyWith(
        filePath: filteredPath,
        pages: updatedPages,
        updatedAt: DateTime.now(),
      );

      final saved = await _localDatasource.saveDocument(updated);
      return Right(saved.toEntity());
    } on ScannerException catch (e) {
      return Left(ScannerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ScannerFailure.imageProcessingError());
    }
  }

  // ── Save ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ScannedDocument>> saveDocument(
    ScannedDocument document,
  ) async {
    try {
      final saved = await _localDatasource.saveDocument(document);
      return Right(saved.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to save document: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  // ── Delete ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> deleteDocument(String documentId) async {
    try {
      await _localDatasource.deleteDocument(documentId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to delete document: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  // ── Get Documents ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ScannedDocument>>> getDocuments() async {
    try {
      final models = _localDatasource.getDocuments();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get documents: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  // ── Get Document By Id ────────────────────────────────────────────

  @override
  Future<Either<Failure, ScannedDocument>> getDocumentById(
    String documentId,
  ) async {
    try {
      final model = _localDatasource.getDocumentById(documentId);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      if (e.code == 1001) {
        return Left(NotFoundFailure.document());
      }
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get document: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  // ── Batch Scan ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ScannedDocument>> batchScan({
    required int pageCount,
  }) async {
    try {
      final scanDir = await ScannerLocalDatasource.getScanDirectory();
      final now = DateTime.now();
      final pages = <ScannedPage>[];

      for (var i = 0; i < pageCount; i++) {
        final fileName =
            '${ScannerLocalDatasource.generateScanFileName().replaceAll('.jpg', '')}_page_${i + 1}.jpg';
        final filePath = '${scanDir.path}/$fileName';

        pages.add(ScannedPage(
          id: _uuid.v4(),
          filePath: filePath,
        ));
      }

      final document = ScannedDocument(
        id: _uuid.v4(),
        filePath: pages.first.filePath,
        createdAt: now,
        updatedAt: now,
        name: 'Batch Scan ${now.toIso8601String().substring(0, 19)}',
        pages: pages,
      );

      final saved = await _localDatasource.saveDocument(document);
      return Right(saved.toEntity());
    } on ScannerException catch (e) {
      return Left(ScannerFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ScannerFailure(
        message: 'Unexpected batch scan error: ${e.toString()}',
        code: 6002,
      ));
    }
  }

  // ── Private Helpers ───────────────────────────────────────────────

  /// Writes a processed [img.Image] to disk alongside the original.
  ///
  /// The output file name is derived from [originalPath] with [suffix]
  /// appended before the extension.
  Future<String> _writeProcessedImage(
    img.Image image,
    String originalPath,
    String suffix,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final baseName = originalPath.split('/').last.replaceAll('.jpg', '');
    final outputPath = '${tempDir.path}/${baseName}$suffix.jpg';

    final outputFile = File(outputPath);
    final jpgBytes = img.encodeJpg(image, quality: 95);
    await outputFile.writeAsBytes(jpgBytes);

    return outputPath;
  }
}
