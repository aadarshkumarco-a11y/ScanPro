import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/scanner/domain/repositories/image_processing_repository.dart';
import 'package:scanpro/features/scanner/data/services/image_processing_service.dart';
import 'package:scanpro/features/scanner/data/services/perspective_correction_service.dart';

/// Implementation of [ImageProcessingRepository] using platform services.
///
/// Delegates image processing operations to the [ImageProcessingService]
/// and perspective correction to the [PerspectiveCorrectionService].
class ImageProcessingRepositoryImpl implements ImageProcessingRepository {
  final ImageProcessingService _imageProcessingService;
  final PerspectiveCorrectionService _perspectiveCorrectionService;

  ImageProcessingRepositoryImpl({
    required ImageProcessingService imageProcessingService,
    required PerspectiveCorrectionService perspectiveCorrectionService,
  })  : _imageProcessingService = imageProcessingService,
        _perspectiveCorrectionService = perspectiveCorrectionService;

  @override
  Future<Either<Failure, String>> processImage(String imagePath) async {
    try {
      final result = await _imageProcessingService.autoEnhance(imagePath);
      return Right(result);
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(message: e.message));
    } catch (e) {
      return Left(
        ImageProcessingFailure(message: 'Failed to process image: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> applyFilter(
    String imagePath,
    String filterName,
  ) async {
    try {
      String result;
      switch (filterName.toLowerCase()) {
        case 'grayscale':
          result = await _imageProcessingService.toGrayscale(imagePath);
          break;
        case 'bw':
        case 'blackandwhite':
          result = await _imageProcessingService.toBlackAndWhite(imagePath);
          break;
        case 'sepia':
          result = await _imageProcessingService.applySepia(imagePath);
          break;
        case 'magic':
          result = await _imageProcessingService.magicFilter(imagePath);
          break;
        default:
          result = await _imageProcessingService.autoEnhance(imagePath);
      }
      return Right(result);
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(message: e.message));
    } catch (e) {
      return Left(
        ImageProcessingFailure(message: 'Failed to apply filter: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> correctPerspective(
    String imagePath,
    List<Map<String, double>> corners,
  ) async {
    try {
      final result = await _perspectiveCorrectionService.correctPerspective(
        imagePath,
        corners,
      );
      return Right(result);
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(message: e.message));
    } catch (e) {
      return Left(
        ImageProcessingFailure(
          message: 'Failed to correct perspective: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> removeShadows(String imagePath) async {
    try {
      final result = await _imageProcessingService.removeShadows(imagePath);
      return Right(result);
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(message: e.message));
    } catch (e) {
      return Left(
        ImageProcessingFailure(message: 'Failed to remove shadows: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> adjustBrightness(
    String imagePath,
    double value,
  ) async {
    try {
      final result = await _imageProcessingService.adjustBrightness(
        imagePath,
        value,
      );
      return Right(result);
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(message: e.message));
    } catch (e) {
      return Left(
        ImageProcessingFailure(
          message: 'Failed to adjust brightness: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> adjustContrast(
    String imagePath,
    double value,
  ) async {
    try {
      final result = await _imageProcessingService.adjustContrast(
        imagePath,
        value,
      );
      return Right(result);
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(message: e.message));
    } catch (e) {
      return Left(
        ImageProcessingFailure(message: 'Failed to adjust contrast: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> sharpen(
    String imagePath,
    double intensity,
  ) async {
    try {
      final result = await _imageProcessingService.sharpen(
        imagePath,
        intensity,
      );
      return Right(result);
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(message: e.message));
    } catch (e) {
      return Left(
        ImageProcessingFailure(message: 'Failed to sharpen image: $e'),
      );
    }
  }
}
