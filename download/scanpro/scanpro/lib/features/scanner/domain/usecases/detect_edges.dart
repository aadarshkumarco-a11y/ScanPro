import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/scanner/domain/entities/edge_detection_result.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';

/// Parameters for the detect edges use case.
class DetectEdgesParams extends Equatable {
  /// Absolute path to the image file.
  final String imagePath;

  const DetectEdgesParams({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

/// Use case for detecting document edges in an image.
///
/// Analyzes the provided image and returns the four corner points
/// of the detected document along with a confidence score.
class DetectEdges implements UseCase<EdgeDetectionResult, DetectEdgesParams> {
  final ScannerRepository _repository;

  DetectEdges(this._repository);

  @override
  Future<Either<Failure, EdgeDetectionResult>> call(
    DetectEdgesParams params,
  ) async {
    if (params.imagePath.isEmpty) {
      return const Left(ValidationFailure(message: 'Image path cannot be empty'));
    }
    return _repository.detectEdges(params.imagePath);
  }
}
