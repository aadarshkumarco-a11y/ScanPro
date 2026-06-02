import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/documents/domain/entities/document_tag.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';

/// Use case for managing document tags (add, remove, create, delete).
class ManageTagsUseCase {
  const ManageTagsUseCase(this._repository);

  final DocumentRepository _repository;

  /// Adds a [tag] to the document identified by [documentId].
  ///
  /// Returns a [ValidationFailure] if either field is empty.
  Future<Either<Failure, Unit>> addTagToDocument({
    required String documentId,
    required String tag,
  }) async {
    if (documentId.isEmpty) {
      return Left(ValidationFailure.emptyField('documentId'));
    }
    if (tag.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('tag'));
    }

    final result = await _repository.addTagToDocument(
      documentId: documentId,
      tag: tag.trim(),
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }

  /// Removes a [tag] from the document identified by [documentId].
  ///
  /// Returns a [ValidationFailure] if either field is empty.
  Future<Either<Failure, Unit>> removeTagFromDocument({
    required String documentId,
    required String tag,
  }) async {
    if (documentId.isEmpty) {
      return Left(ValidationFailure.emptyField('documentId'));
    }
    if (tag.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('tag'));
    }

    final result = await _repository.removeTagFromDocument(
      documentId: documentId,
      tag: tag.trim(),
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }

  /// Creates a new tag with the given [name] and optional [color].
  ///
  /// Returns a [ValidationFailure] if [name] is empty.
  Future<Either<Failure, DocumentTag>> createTag({
    required String name,
    String? color,
  }) async {
    if (name.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('name'));
    }
    return _repository.createTag(name: name.trim(), color: color);
  }

  /// Deletes a tag by [tagId].
  ///
  /// Returns a [ValidationFailure] if [tagId] is empty.
  Future<Either<Failure, Unit>> deleteTag(String tagId) async {
    if (tagId.isEmpty) {
      return Left(ValidationFailure.emptyField('tagId'));
    }
    return _repository.deleteTag(tagId);
  }
}
