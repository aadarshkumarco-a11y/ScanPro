import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_result.dart';
import 'package:scanpro/features/scanner/domain/entities/edge_detection_result.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:scanpro/features/scanner/data/services/camera_service.dart';
import 'package:scanpro/features/scanner/data/services/edge_detection_service.dart';
import 'package:scanpro/features/scanner/data/services/image_processing_service.dart';
import 'package:scanpro/features/scanner/data/services/perspective_correction_service.dart';
import 'package:scanpro/features/scanner/data/models/scan_result_model.dart';

/// Implementation of [ScannerRepository] using platform services.
///
/// Orchestrates camera, edge detection, image processing, and
/// perspective correction services to fulfill scanner operations.
class ScannerRepositoryImpl implements ScannerRepository {
  final CameraService _cameraService;
  final EdgeDetectionService _edgeDetectionService;
  final ImageProcessingService _imageProcessingService;
  final PerspectiveCorrectionService _perspectiveCorrectionService;

  ScannerRepositoryImpl({
    required CameraService cameraService,
    required EdgeDetectionService edgeDetectionService,
    required ImageProcessingService imageProcessingService,
    required PerspectiveCorrectionService perspectiveCorrectionService,
  })  : _cameraService = cameraService,
        _edgeDetectionService = edgeDetectionService,
        _imageProcessingService = imageProcessingService,
        _perspectiveCorrectionService = perspectiveCorrectionService;

  @override
  Future<Either<Failure, ScanResult>> captureDocument() async {
    try {
      final imagePath = await _cameraService.captureImage();
      if (imagePath == null) {
        return const Left(CameraFailure(message: 'Image capture was cancelled'));
      }

      final edgeResult = await _edgeDetectionService.detectEdges(imagePath);

      final scanResult = ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalPath: imagePath,
        edges: edgeResult.points
            .map((p) => EdgePoint(x: p.x, y: p.y))
            .toList(),
        confidence: edgeResult.confidence,
        timestamp: DateTime.now(),
      );

      return Right(scanResult);
    } on CameraException catch (e) {
      return Left(CameraFailure(message: e.message));
    } catch (e) {
      return Left(CameraFailure(message: 'Failed to capture document: $e'));
    }
  }

  @override
  Future<Either<Failure, EdgeDetectionResult>> detectEdges(
    String imagePath,
  ) async {
    try {
      final result = await _edgeDetectionService.detectEdges(imagePath);
      return Right(result);
    } on EdgeDetectionException catch (e) {
      return Left(EdgeDetectionFailure(message: e.message));
    } catch (e) {
      return Left(
        EdgeDetectionFailure(message: 'Failed to detect edges: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> cropDocument(
    String imagePath,
    List<EdgePoint> edges,
  ) async {
    try {
      final corners = edges
          .map((e) => {'x': e.x, 'y': e.y})
          .toList();
      final croppedPath = await _perspectiveCorrectionService.correctPerspective(
        imagePath,
        corners,
      );
      return Right(croppedPath);
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(message: e.message));
    } catch (e) {
      return Left(
        ImageProcessingFailure(message: 'Failed to crop document: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> enhanceDocument(
    String imagePath,
    EnhancementType enhancementType,
  ) async {
    try {
      String enhancedPath;
      switch (enhancementType) {
        case EnhancementType.auto:
          enhancedPath = await _imageProcessingService.autoEnhance(imagePath);
          break;
        case EnhancementType.sharp:
          enhancedPath = await _imageProcessingService.sharpen(
            imagePath,
            0.8,
          );
          break;
        case EnhancementType.magic:
          enhancedPath = await _imageProcessingService.magicFilter(imagePath);
          break;
        case EnhancementType.removeShadows:
          enhancedPath = await _imageProcessingService.removeShadows(imagePath);
          break;
        case EnhancementType.brighten:
          enhancedPath = await _imageProcessingService.adjustBrightness(
            imagePath,
            30.0,
          );
          break;
        case EnhancementType.none:
          enhancedPath = imagePath;
          break;
      }
      return Right(enhancedPath);
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(message: e.message));
    } catch (e) {
      return Left(
        ImageProcessingFailure(message: 'Failed to enhance document: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ScanResult>>> importFromGallery() async {
    try {
      final imagePaths = await _cameraService.pickImagesFromGallery();
      if (imagePaths.isEmpty) {
        return const Left(CameraFailure(message: 'No images selected'));
      }

      final results = <ScanResult>[];
      for (final path in imagePaths) {
        final edgeResult = await _edgeDetectionService.detectEdges(path);
        results.add(ScanResult(
          id: '${DateTime.now().millisecondsSinceEpoch}_${results.length}',
          originalPath: path,
          edges: edgeResult.points
              .map((p) => EdgePoint(x: p.x, y: p.y))
              .toList(),
          confidence: edgeResult.confidence,
          timestamp: DateTime.now(),
        ));
      }

      return Right(results);
    } on CameraException catch (e) {
      return Left(CameraFailure(message: e.message));
    } catch (e) {
      return Left(CameraFailure(message: 'Failed to import from gallery: $e'));
    }
  }
}
