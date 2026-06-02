import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/exceptions.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/scanner/data/models/scanned_document_model.dart';
import 'package:scanpro/features/documents/domain/entities/document_folder.dart';
import 'package:scanpro/features/documents/domain/entities/document_tag.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';
import 'package:scanpro/features/documents/data/datasources/document_local_datasource.dart';
import 'package:scanpro/features/documents/data/models/document_folder_model.dart';
import 'package:scanpro/features/documents/data/models/document_tag_model.dart';

/// Concrete implementation of [DocumentRepository].
///
/// Delegates local persistence to [DocumentLocalDatasource] and
/// converts all exceptions to appropriate [Failure] subclasses.
class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl({
    required DocumentLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  final DocumentLocalDatasource _localDatasource;

  // ═══════════════════════════════════════════════════════════════════
  //  Documents
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, List<ScannedDocument>>> getDocuments({
    String? folderId,
    String? tag,
    bool includeDeleted = false,
  }) async {
    try {
      final dataMaps = _localDatasource.getDocuments(
        folderId: folderId,
        tag: tag,
        includeDeleted: includeDeleted,
      );
      final documents = dataMaps
          .map((m) => ScannedDocumentModel.fromHive(m).toEntity())
          .toList();
      return Right(documents);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get documents: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  @override
  Future<Either<Failure, ScannedDocument>> getDocumentById(
    String documentId,
  ) async {
    try {
      final map = _localDatasource.getDocumentById(documentId);
      return Right(ScannedDocumentModel.fromHive(map).toEntity());
    } on CacheException catch (e) {
      if (e.code == 1001) {
        return Left(NotFoundFailure.document());
      }
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get document: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> moveToTrash(String documentId) async {
    try {
      await _localDatasource.markAsTrashed(documentId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to move document to trash: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> restoreFromTrash(String documentId) async {
    try {
      await _localDatasource.restoreFromTrash(documentId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to restore document: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> permanentDelete(String documentId) async {
    try {
      await _localDatasource.permanentDeleteDocument(documentId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to permanently delete document: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> emptyTrash() async {
    try {
      await _localDatasource.emptyTrash();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to empty trash: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, List<ScannedDocument>>> getTrashedDocuments() async {
    try {
      final dataMaps = _localDatasource.getDocuments(includeDeleted: true);
      final trashed = dataMaps
          .where((m) => m['isTrashed'] as bool? ?? false)
          .map((m) => ScannedDocumentModel.fromHive(m).toEntity())
          .toList();
      return Right(trashed);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get trashed documents: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  @override
  Future<Either<Failure, ScannedDocument>> toggleFavorite(
    String documentId,
  ) async {
    try {
      final map = _localDatasource.getDocumentById(documentId);
      final current = (map['isFavorite'] as bool?) ?? false;
      map['isFavorite'] = !current;
      map['updatedAt'] = DateTime.now().toIso8601String();
      await _localDatasource.saveDocument(documentId, map);
      return Right(ScannedDocumentModel.fromHive(map).toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to toggle favourite: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, List<ScannedDocument>>> getFavoriteDocuments() async {
    try {
      final dataMaps = _localDatasource.getDocuments();
      final favorites = dataMaps
          .where((m) => (m['isFavorite'] as bool?) ?? false)
          .map((m) => ScannedDocumentModel.fromHive(m).toEntity())
          .toList();
      return Right(favorites);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get favourite documents: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  @override
  Future<Either<Failure, ScannedDocument>> moveDocumentToFolder({
    required String documentId,
    String? folderId,
  }) async {
    try {
      final map = _localDatasource.getDocumentById(documentId);
      map['folderId'] = folderId;
      map['updatedAt'] = DateTime.now().toIso8601String();
      await _localDatasource.saveDocument(documentId, map);
      return Right(ScannedDocumentModel.fromHive(map).toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to move document: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, ScannedDocument>> addTagToDocument({
    required String documentId,
    required String tag,
  }) async {
    try {
      final map = _localDatasource.getDocumentById(documentId);
      final tags = (map['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];
      if (!tags.contains(tag)) {
        tags.add(tag);
        map['tags'] = tags;
        map['updatedAt'] = DateTime.now().toIso8601String();
        await _localDatasource.saveDocument(documentId, map);
      }
      return Right(ScannedDocumentModel.fromHive(map).toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to add tag: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, ScannedDocument>> removeTagFromDocument({
    required String documentId,
    required String tag,
  }) async {
    try {
      final map = _localDatasource.getDocumentById(documentId);
      final tags = (map['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];
      tags.remove(tag);
      map['tags'] = tags;
      map['updatedAt'] = DateTime.now().toIso8601String();
      await _localDatasource.saveDocument(documentId, map);
      return Right(ScannedDocumentModel.fromHive(map).toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to remove tag: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, ScannedDocument>> renameDocument({
    required String documentId,
    required String newName,
  }) async {
    try {
      final map = _localDatasource.getDocumentById(documentId);
      map['name'] = newName;
      map['updatedAt'] = DateTime.now().toIso8601String();
      await _localDatasource.saveDocument(documentId, map);
      return Right(ScannedDocumentModel.fromHive(map).toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to rename document: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Folders
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, List<DocumentFolder>>> getFolders() async {
    try {
      final models = _localDatasource.getFolders();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get folders: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  @override
  Future<Either<Failure, DocumentFolder>> createFolder({
    required String name,
    String? color,
    String? icon,
    String? parentFolderId,
  }) async {
    try {
      final model = await _localDatasource.createFolder(
        name: name,
        color: color,
        icon: icon,
        parentFolderId: parentFolderId,
      );
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to create folder: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, DocumentFolder>> renameFolder({
    required String folderId,
    required String newName,
  }) async {
    try {
      final model = await _localDatasource.renameFolder(
        folderId: folderId,
        newName: newName,
      );
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to rename folder: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteFolder(String folderId) async {
    try {
      await _localDatasource.deleteFolder(folderId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to delete folder: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Tags
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, List<DocumentTag>>> getTags() async {
    try {
      final models = _localDatasource.getTags();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get tags: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  @override
  Future<Either<Failure, DocumentTag>> createTag({
    required String name,
    String? color,
  }) async {
    try {
      final model = await _localDatasource.createTag(
        name: name,
        color: color,
      );
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to create tag: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTag(String tagId) async {
    try {
      await _localDatasource.deleteTag(tagId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to delete tag: ${e.toString()}',
        code: 1002,
      ));
    }
  }
}
