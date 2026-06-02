import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/signature/domain/entities/signature.dart';
import 'package:scanpro/features/signature/domain/repositories/signature_repository.dart';

/// Use case for saving a signature.
///
/// Validates the signature data before delegating to
/// [SignatureRepository.saveSignature].
class SaveSignatureUseCase {
  const SaveSignatureUseCase(this._repository);

  final SignatureRepository _repository;

  /// Executes the signature save operation.
  ///
  /// [signature] – the signature to persist.
  /// Validates that the name is not empty and the image data is present.
  Future<Either<Failure, Signature>> call(Signature signature) async {
    if (signature.name.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Signature name'));
    }

    if (signature.imageData.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('Signature image'));
    }

    return _repository.saveSignature(signature);
  }
}
