import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/scanner/domain/entities/edge_detection_result.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';

/// Parameters for the crop document use case.
class CropDocumentParams extends Equatable {
  /// Absolute path to the source image.
  final String imagePath;

  /// Four corner points defining the crop region.
  final List<EdgePoint> edges;

  const CropDocumentParams({
    required this.imagePath,
    required this.edges,
  });

  @override
  List<Object?> get props => [imagePath, edges];
}

/// Use case for cropping a document image to its detected edges.
///
/// Takes an image path and four edge points, then returns the
/// path to the cropped image with perspective correction applied.
class CropDocument implements UseCase<String, CropDocumentParams> {
  final ScannerRepository _repository;

  CropDocument(this._repository);

  @override
  Future<Either<Failure, String>> call(CropDocumentParams params) async {
    if (params.imagePath.isEmpty) {
      return const Left(ValidationFailure(message: 'Image path cannot be empty'));
    }
    if (params.edges.length != 4) {
      return const Left(
        ValidationFailure(message: 'Exactly 4 edge points are required'),
      );
    }
    return _repository.cropDocument(params.imagePath, params.edges);
  }
}
