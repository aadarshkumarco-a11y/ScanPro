import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/signature/domain/entities/signature.dart';

/// Abstract repository defining the contract for signature management.
///
/// Provides CRUD operations for saved signatures and the ability
/// to insert signatures into PDF documents.
abstract class SignatureRepository {
  /// Creates and saves a new signature.
  ///
  /// [signature] is the signature entity to save.
  /// Returns the saved [Signature] with any assigned fields.
  Future<Either<Failure, Signature>> createSignature(Signature signature);

  /// Retrieves all saved signatures.
  ///
  /// Returns a list of [Signature] entities ordered by most recent.
  Future<Either<Failure, List<Signature>>> getSignatures();

  /// Deletes a saved signature.
  ///
  /// [id] is the signature identifier.
  /// Returns unit on success.
  Future<Either<Failure, Unit>> deleteSignature(String id);

  /// Inserts a signature into a PDF document at the specified position.
  ///
  /// [signatureId] is the ID of the saved signature to insert.
  /// [pdfPath] is the path to the target PDF document.
  /// [pageIndex] is the 0-based page index.
  /// [x] and [y] are the insertion coordinates in PDF points.
  /// [width] and [height] are the signature dimensions in PDF points.
  /// Returns the path to the modified PDF.
  Future<Either<Failure, String>> insertSignature({
    required String signatureId,
    required String pdfPath,
    required int pageIndex,
    required double x,
    required double y,
    required double width,
    required double height,
  });
}
