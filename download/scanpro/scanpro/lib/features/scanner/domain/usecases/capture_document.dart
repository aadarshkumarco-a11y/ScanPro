import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_result.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';

/// Parameters for the capture document use case.
class CaptureParams extends Equatable {
  /// Whether to automatically detect and crop document edges.
  final bool autoDetect;

  /// Whether to apply auto-enhancement after capture.
  final bool autoEnhance;

  /// Color mode for the captured image.
  final ColorMode colorMode;

  const CaptureParams({
    this.autoDetect = true,
    this.autoEnhance = false,
    this.colorMode = ColorMode.color,
  });

  @override
  List<Object?> get props => [autoDetect, autoEnhance, colorMode];
}

/// Use case for capturing a document using the device camera.
///
/// Handles the full capture workflow including edge detection
/// and optional auto-enhancement based on the provided parameters.
class CaptureDocument implements UseCase<ScanResult, CaptureParams> {
  final ScannerRepository _repository;

  CaptureDocument(this._repository);

  @override
  Future<Either<Failure, ScanResult>> call(CaptureParams params) async {
    final captureResult = await _repository.captureDocument();

    return captureResult.fold(
      (failure) => Left(failure),
      (scanResult) async {
        if (params.autoDetect && scanResult.edges.isEmpty) {
          final edgeResult = await _repository.detectEdges(
            scanResult.originalPath,
          );
          return edgeResult.fold(
            (failure) => Right(scanResult),
            (edges) => Right(
              scanResult.copyWith(
                edges: edges.points,
                confidence: edges.confidence,
              ),
            ),
          );
        }
        return Right(scanResult);
      },
    );
  }
}
