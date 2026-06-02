import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/core/usecases/usecase.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';

/// Parameters for the enhance document use case.
class EnhanceDocumentParams extends Equatable {
  /// Absolute path to the source image.
  final String imagePath;

  /// Type of enhancement to apply.
  final EnhancementType enhancementType;

  const EnhanceDocumentParams({
    required this.imagePath,
    required this.enhancementType,
  });

  @override
  List<Object?> get props => [imagePath, enhancementType];
}

/// Use case for enhancing a scanned document image.
///
/// Applies the specified enhancement type to improve readability,
/// clarity, or visual quality of the document image.
class EnhanceDocument implements UseCase<String, EnhanceDocumentParams> {
  final ScannerRepository _repository;

  EnhanceDocument(this._repository);

  @override
  Future<Either<Failure, String>> call(EnhanceDocumentParams params) async {
    if (params.imagePath.isEmpty) {
      return const Left(ValidationFailure(message: 'Image path cannot be empty'));
    }
    if (params.enhancementType == EnhancementType.none) {
      return Right(params.imagePath);
    }
    return _repository.enhanceDocument(
      params.imagePath,
      params.enhancementType,
    );
  }
}
