import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/signature/domain/entities/signature.dart';
import 'package:scanpro/features/signature/domain/repositories/signature_repository.dart';
import 'package:scanpro/features/signature/data/models/signature_model.dart';
import 'package:scanpro/features/pdf_tools/data/services/syncfusion_pdf_service.dart';

/// Implementation of [SignatureRepository] using Hive for local storage
/// and Syncfusion for PDF signature insertion.
///
/// Manages signature CRUD operations in Hive and delegates PDF
/// modification to the Syncfusion PDF service.
class SignatureRepositoryImpl implements SignatureRepository {
  final Box<SignatureModel> _signatureBox;
  final SyncfusionPDFService _pdfService;

  static const String _signaturesBoxName = 'signatures';

  SignatureRepositoryImpl({
    required Box<SignatureModel> signatureBox,
    required SyncfusionPDFService pdfService,
  })  : _signatureBox = signatureBox,
        _pdfService = pdfService;

  @override
  Future<Either<Failure, Signature>> createSignature(
    Signature signature,
  ) async {
    try {
      final model = SignatureModel.fromEntity(signature);
      await _signatureBox.put(signature.id, model);
      return Right(signature);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to create signature: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Signature>>> getSignatures() async {
    try {
      final signatures = _signatureBox.values
          .map((model) => model.toEntity())
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return Right(signatures);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to get signatures: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSignature(String id) async {
    try {
      final model = _signatureBox.get(id);
      if (model == null) {
        return Left(
          NotFoundFailure(message: 'Signature not found: $id'),
        );
      }
      await _signatureBox.delete(id);
      return const Right(unit);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to delete signature: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> insertSignature({
    required String signatureId,
    required String pdfPath,
    required int pageIndex,
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    try {
      final signatureModel = _signatureBox.get(signatureId);
      if (signatureModel == null) {
        return Left(
          NotFoundFailure(message: 'Signature not found: $signatureId'),
        );
      }

      final signature = signatureModel.toEntity();

      final outputPath = await _pdfService.insertSignature(
        pdfPath: pdfPath,
        pageIndex: pageIndex,
        signatureImageData: signature.imageData,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      return Right(outputPath);
    } on PDFServiceException catch (e) {
      return Left(PDFFailure(message: e.message));
    } catch (e) {
      return Left(
        PDFFailure(message: 'Failed to insert signature: $e'),
      );
    }
  }
}
