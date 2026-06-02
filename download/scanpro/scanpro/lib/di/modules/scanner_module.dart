/// Scanner feature module — provides all Riverpod providers related to
/// camera capture, edge detection, image processing, and document scanning.
///
/// The module follows Clean Architecture conventions:
/// - **Services** encapsulate platform-level concerns (camera, OpenCV).
/// - **Repository** abstracts data persistence for scanned pages.
/// - **Use cases** expose single-responsibility business operations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/scanner_repository.dart';
import '../../domain/usecases/scanner/capture_document_usecase.dart';
import '../../domain/usecases/scanner/detect_edges_usecase.dart';
import '../../domain/usecases/scanner/enhance_image_usecase.dart';
import '../../domain/usecases/scanner/batch_scan_usecase.dart';
import '../../data/datasources/scanner_local_data_source.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import '../injection.dart';

// ---------------------------------------------------------------------------
// Data Sources
// ---------------------------------------------------------------------------

/// Local data source that persists scanned pages to Hive storage.
final scannerLocalDataSourceProvider = Provider<ScannerLocalDataSource>((ref) {
  final box = ref.watch(hiveBoxProvider);
  return ScannerLocalDataSource(box: box);
});

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

/// Camera service that manages the device camera for document scanning.
///
/// Wraps the camera plugin and provides high-level APIs for capturing
/// images, toggling flash, and switching cameras.
final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

/// Edge detection service powered by OpenCV.
///
/// Detects document boundaries in a camera frame and returns the four
/// corner coordinates for perspective correction.
final edgeDetectionServiceProvider = Provider<EdgeDetectionService>((ref) {
  return EdgeDetectionService();
});

/// Image processing service that handles perspective correction,
/// enhancement filters, and format conversion for scanned pages.
final imageProcessingServiceProvider = Provider<ImageProcessingService>((ref) {
  final edgeService = ref.watch(edgeDetectionServiceProvider);
  return ImageProcessingService(edgeDetectionService: edgeService);
});

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Primary [ScannerRepository] implementation backed by local Hive storage.
final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  final localDataSource = ref.watch(scannerLocalDataSourceProvider);
  final imageService = ref.watch(imageProcessingServiceProvider);
  return ScannerRepositoryImpl(
    localDataSource: localDataSource,
    imageProcessingService: imageService,
  );
});

// ---------------------------------------------------------------------------
// Use Cases
// ---------------------------------------------------------------------------

/// Captures a single document page from the camera, applies edge detection,
/// and saves the processed image.
final captureDocumentUseCaseProvider = Provider<CaptureDocumentUseCase>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  final cameraService = ref.watch(cameraServiceProvider);
  return CaptureDocumentUseCase(
    repository: repository,
    cameraService: cameraService,
  );
});

/// Detects document edges in the current camera frame without capturing.
/// Useful for real-time edge overlay rendering on the camera preview.
final detectEdgesUseCaseProvider = Provider<DetectEdgesUseCase>((ref) {
  final edgeService = ref.watch(edgeDetectionServiceProvider);
  return DetectEdgesUseCase(edgeDetectionService: edgeService);
});

/// Enhances a scanned image by applying adaptive thresholding,
/// contrast adjustment, and shadow removal.
final enhanceImageUseCaseProvider = Provider<EnhanceImageUseCase>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  final imageService = ref.watch(imageProcessingServiceProvider);
  return EnhanceImageUseCase(
    repository: repository,
    imageProcessingService: imageService,
  );
});

/// Orchestrates a batch scanning session, accumulating multiple pages
/// into a single document with automatic edge detection per capture.
final batchScanUseCaseProvider = Provider<BatchScanUseCase>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  final cameraService = ref.watch(cameraServiceProvider);
  return BatchScanUseCase(
    repository: repository,
    cameraService: cameraService,
  );
});

// ---------------------------------------------------------------------------
// Service Classes (inline declarations for DI wiring)
// In production, these live in data/services/. Shown here for clarity.
// ---------------------------------------------------------------------------

/// Manages camera device access for document scanning.
class CameraService {
  /// Captures an image from the active camera and returns its file path.
  Future<String> captureImage() async {
    throw UnimplementedError('CameraService.captureImage must be implemented');
  }

  /// Toggles the device flash between on and off states.
  Future<void> toggleFlash({required bool enabled}) async {
    throw UnimplementedError('CameraService.toggleFlash must be implemented');
  }

  /// Switches between front and rear cameras.
  Future<void> switchCamera() async {
    throw UnimplementedError('CameraService.switchCamera must be implemented');
  }

  /// Disposes camera resources.
  Future<void> dispose() async {}
}

/// Wraps OpenCV edge detection for document boundary identification.
class EdgeDetectionService {
  /// Detects document edges in the provided [imagePath] and returns
  /// four corner points in normalized coordinates (0.0–1.0).
  Future<List<Point<double>>?> detectEdges(String imagePath) async {
    throw UnimplementedError(
      'EdgeDetectionService.detectEdges must be implemented',
    );
  }
}

/// Handles perspective correction and image enhancement for scanned pages.
class ImageProcessingService {
  ImageProcessingService({required this.edgeDetectionService});

  final EdgeDetectionService edgeDetectionService;

  /// Applies perspective correction using the given [corners] and returns
  /// the path to the corrected image.
  Future<String> correctPerspective(
    String imagePath,
    List<Point<double>> corners,
  ) async {
    throw UnimplementedError(
      'ImageProcessingService.correctPerspective must be implemented',
    );
  }

  /// Enhances the image at [imagePath] by applying adaptive thresholding,
  /// shadow removal, and contrast normalization.
  Future<String> enhanceImage(String imagePath, {String mode = 'auto'}) async {
    throw UnimplementedError(
      'ImageProcessingService.enhanceImage must be implemented',
    );
  }
}

/// Simple 2D point used by edge detection.
class Point<T> {
  const Point(this.x, this.y);
  final T x;
  final T y;
}
