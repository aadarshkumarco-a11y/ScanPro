import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_result.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';

/// Parameters for the import from gallery use case.
class ImportFromGalleryParams extends Equatable {
  /// Maximum number of images allowed for import.
  final int maxImages;

  /// Whether to auto-detect edges on imported images.
  final bool autoDetect;

  const ImportFromGalleryParams({
    this.maxImages = 10,
    this.autoDetect = true,
  });

  @override
  List<Object?> get props => [maxImages, autoDetect];
}

/// Use case for importing document images from the device gallery.
///
/// Opens the system image picker and processes selected images
/// through the scanner pipeline including edge detection.
class ImportFromGallery
    implements UseCase<List<ScanResult>, ImportFromGalleryParams> {
  final ScannerRepository _repository;

  ImportFromGallery(this._repository);

  @override
  Future<Either<Failure, List<ScanResult>>> call(
    ImportFromGalleryParams params,
  ) async {
    if (params.maxImages <= 0) {
      return const Left(
        ValidationFailure(message: 'Max images must be greater than 0'),
      );
    }
    return _repository.importFromGallery();
  }
}
