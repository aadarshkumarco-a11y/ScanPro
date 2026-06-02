import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

/// Custom exception for camera-related errors.
class CameraException implements Exception {
  final String message;
  const CameraException(this.message);
  @override
  String toString() => 'CameraException: $message';
}

/// Service for camera and image picking operations.
///
/// Wraps the camera package for capturing document images and
/// the image_picker package for gallery imports.
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  /// Whether the camera is currently initialized and ready.
  bool get isInitialized => _isInitialized;

  /// The current camera controller, if initialized.
  CameraController? get controller => _controller;

  /// Initializes the camera with the first available rear camera.
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw const CameraException('No cameras available');
      }

      final rearCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        rearCamera,
        ResolutionPolicy.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } on CameraException {
      rethrow;
    } catch (e) {
      throw CameraException('Failed to initialize camera: $e');
    }
  }

  /// Captures a single image and returns the file path.
  ///
  /// Returns null if the capture was cancelled or the camera
  /// is not initialized.
  Future<String?> captureImage() async {
    if (!_isInitialized || _controller == null) {
      throw const CameraException('Camera is not initialized');
    }

    try {
      final xFile = await _controller!.takePicture();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = p.join(tempDir.path, 'scan_$timestamp.jpg');

      await File(xFile.path).copy(newPath);
      return newPath;
    } catch (e) {
      throw CameraException('Failed to capture image: $e');
    }
  }

  /// Opens the system image picker for gallery import.
  ///
  /// Returns a list of selected image file paths.
  Future<List<String>> pickImagesFromGallery() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 95);

    if (images.isEmpty) return [];

    final paths = <String>[];
    final tempDir = await getTemporaryDirectory();

    for (final image in images) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = p.join(
        tempDir.path,
        'import_${timestamp}_${paths.length}.jpg',
      );
      await File(image.path).copy(newPath);
      paths.add(newPath);
    }

    return paths;
  }

  /// Toggles the camera flash mode.
  Future<void> toggleFlash() async {
    if (_controller == null) return;

    final currentMode = _controller!.value.flashMode;
    final newMode = currentMode == FlashMode.off
        ? FlashMode.torch
        : FlashMode.off;

    await _controller!.setFlashMode(newMode);
  }

  /// Switches between front and rear cameras.
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final currentIndex = _cameras!.indexOf(_controller!.description);
    final nextIndex = (currentIndex + 1) % _cameras!.length;

    await _controller!.dispose();

    _controller = CameraController(
      _cameras![nextIndex],
      ResolutionPolicy.veryHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
  }

  /// Disposes of camera resources.
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
