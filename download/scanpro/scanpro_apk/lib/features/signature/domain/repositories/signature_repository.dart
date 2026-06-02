import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/signature/domain/entities/signature.dart';

/// Abstract repository contract for signature operations.
///
/// Defines the domain-level API for saving, retrieving, deleting,
/// and managing default status of signatures.
abstract class SignatureRepository {
  /// Saves a new signature.
  ///
  /// Returns the saved [Signature] with generated ID and timestamp.
  Future<Either<Failure, Signature>> saveSignature(Signature signature);

  /// Retrieves all saved signatures.
  ///
  /// Returns a list of [Signature]s ordered by most recent first.
  Future<Either<Failure, List<Signature>>> getSignatures();

  /// Deletes a signature by [signatureId].
  Future<Either<Failure, Unit>> deleteSignature(String signatureId);

  /// Sets the signature with [signatureId] as the default.
  ///
  /// Removes default status from any previously default signature.
  Future<Either<Failure, Signature>> setDefaultSignature(String signatureId);
}
