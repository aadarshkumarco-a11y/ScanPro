/// Image processing utilities for ScanPro.
///
/// Provides helpers for image compression, resizing, format
/// conversion, and metadata extraction using dart:io and
/// Flutter's image handling capabilities.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Utility class for image processing operations.
class ImageUtils {
  ImageUtils._();

  /// Compresses image bytes with the given [quality] (1–100).
  ///
  /// Returns the compressed JPEG bytes. Lower quality means
  /// smaller file size at the cost of visual fidelity.
  static Future<Uint8List> compressImage(
    Uint8List imageBytes, {
    int quality = AppConstants.defaultCompressionQuality,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ScannerException(message: 'Failed to decode image for compression.');
      }
      final compressed = img.encodeJpg(image, quality: quality);
      return Uint8List.fromList(compressed);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ScannerException(message: 'Image compression failed.', originalError: e);
    }
  }

  /// Resizes an image to fit within [maxWidth] × [maxHeight] while
  /// preserving aspect ratio. Returns the original bytes if already
  /// within bounds.
  static Future<Uint8List> resizeImage(
    Uint8List imageBytes, {
    int maxWidth = AppConstants.maxImageDimension,
    int maxHeight = AppConstants.maxImageDimension,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ScannerException(message: 'Failed to decode image for resizing.');
      }

      if (image.width <= maxWidth && image.height <= maxHeight) {
        return imageBytes;
      }

      final ratio = _calculateScaleRatio(image.width, image.height, maxWidth, maxHeight);
      final newWidth = (image.width * ratio).round();
      final newHeight = (image.height * ratio).round();

      final resized = img.copyResize(image, width: newWidth, height: newHeight);
      final encoded = img.encodeJpg(resized, quality: AppConstants.defaultCompressionQuality);
      return Uint8List.fromList(encoded);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ScannerException(message: 'Image resize failed.', originalError: e);
    }
  }

  /// Generates a thumbnail of the given [imageBytes].
  ///
  /// Thumbnail size defaults to [AppConstants.thumbnailSize].
  static Future<Uint8List> generateThumbnail(
    Uint8List imageBytes, {
    int size = AppConstants.thumbnailSize,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ScannerException(message: 'Failed to decode image for thumbnail.');
      }

      final ratio = _calculateScaleRatio(image.width, image.height, size, size);
      final newWidth = (image.width * ratio).round();
      final newHeight = (image.height * ratio).round();

      final thumbnail = img.copyResize(image, width: newWidth, height: newHeight);
      final encoded = img.encodeJpg(thumbnail, quality: 70);
      return Uint8List.fromList(encoded);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ScannerException(message: 'Thumbnail generation failed.', originalError: e);
    }
  }

  /// Converts image bytes to JPEG format.
  static Future<Uint8List> convertToJpeg(Uint8List imageBytes, {int quality = 90}) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ScannerException(message: 'Failed to decode image for conversion.');
      }
      final encoded = img.encodeJpg(image, quality: quality);
      return Uint8List.fromList(encoded);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ScannerException(message: 'Image conversion to JPEG failed.', originalError: e);
    }
  }

  /// Converts image bytes to PNG format.
  static Future<Uint8List> convertToPng(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ScannerException(message: 'Failed to decode image for conversion.');
      }
      final encoded = img.encodePng(image);
      return Uint8List.fromList(encoded);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ScannerException(message: 'Image conversion to PNG failed.', originalError: e);
    }
  }

  /// Returns the dimensions of the image as a [Size].
  static Future<Size> getImageDimensions(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ScannerException(message: 'Failed to decode image for dimensions.');
      }
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      if (e is AppException) rethrow;
      throw ScannerException(message: 'Failed to get image dimensions.', originalError: e);
    }
  }

  /// Saves image bytes to a file in the app's temporary directory.
  ///
  /// Returns the path to the saved file.
  static Future<String> saveToTemp(Uint8List imageBytes, {String? fileName}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final name = fileName ?? 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = p.join(tempDir.path, name);
      final file = File(path);
      await file.writeAsBytes(imageBytes);
      return path;
    } catch (e) {
      throw CacheException(message: 'Failed to save image to temp.', originalError: e);
    }
  }

  /// Applies grayscale conversion to the image bytes.
  static Future<Uint8List> toGrayscale(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ScannerException(message: 'Failed to decode image for grayscale.');
      }
      final grayscale = img.grayscale(image);
      final encoded = img.encodeJpg(grayscale, quality: AppConstants.defaultCompressionQuality);
      return Uint8List.fromList(encoded);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ScannerException(message: 'Grayscale conversion failed.', originalError: e);
    }
  }

  /// Calculates the scale ratio to fit within the target dimensions.
  static double _calculateScaleRatio(
    int srcWidth,
    int srcHeight,
    int maxWidth,
    int maxHeight,
  ) {
    final widthRatio = maxWidth / srcWidth;
    final heightRatio = maxHeight / srcHeight;
    return widthRatio < heightRatio ? widthRatio : heightRatio;
  }
}
