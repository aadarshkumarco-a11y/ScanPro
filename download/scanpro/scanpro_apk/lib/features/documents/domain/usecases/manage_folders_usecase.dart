import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/documents/domain/entities/document_folder.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';

/// Use case for managing document folders (create, rename, delete).
class ManageFoldersUseCase {
  const ManageFoldersUseCase(this._repository);

  final DocumentRepository _repository;

  /// Creates a new folder with the given [name] and optional metadata.
  ///
  /// Returns a [ValidationFailure] if [name] is empty.
  Future<Either<Failure, DocumentFolder>> createFolder({
    required String name,
    String? color,
    String? icon,
    String? parentFolderId,
  }) async {
    if (name.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('name'));
    }
    return _repository.createFolder(
      name: name.trim(),
      color: color,
      icon: icon,
      parentFolderId: parentFolderId,
    );
  }

  /// Renames an existing folder.
  ///
  /// Returns a [ValidationFailure] if [newName] is empty.
  Future<Either<Failure, DocumentFolder>> renameFolder({
    required String folderId,
    required String newName,
  }) async {
    if (newName.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('newName'));
    }
    if (folderId.isEmpty) {
      return Left(ValidationFailure.emptyField('folderId'));
    }
    return _repository.renameFolder(
      folderId: folderId,
      newName: newName.trim(),
    );
  }

  /// Deletes a folder by [folderId].
  ///
  /// Returns a [ValidationFailure] if [folderId] is empty.
  Future<Either<Failure, Unit>> deleteFolder(String folderId) async {
    if (folderId.isEmpty) {
      return Left(ValidationFailure.emptyField('folderId'));
    }
    return _repository.deleteFolder(folderId);
  }
}
