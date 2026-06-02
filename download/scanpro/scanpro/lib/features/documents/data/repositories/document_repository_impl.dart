import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';
import 'package:scanpro/features/scanner/data/models/scan_document_model.dart';

/// Implementation of [DocumentRepository] using Hive for local storage
/// and Firestore for remote sync.
///
/// Implements an offline-first strategy: all reads come from the local
/// Hive cache, and writes are persisted locally first, then synced to
/// Firestore in the background.
class DocumentRepositoryImpl implements DocumentRepository {
  final Box<ScanDocumentModel> _localBox;
  final FirebaseFirestore _firestore;

  static const String _firestoreCollection = 'documents';

  DocumentRepositoryImpl({
    required Box<ScanDocumentModel> localBox,
    required FirebaseFirestore firestore,
  })  : _localBox = localBox,
        _firestore = firestore;

  @override
  Future<Either<Failure, List<ScanDocument>>> getDocuments() async {
    try {
      final documents = _localBox.values
          .map((model) => model.toEntity())
          .where((doc) => !doc.isDeleted)
          .toList();
      documents.sort(
        (a, b) => b.updatedAt.compareTo(a.updatedAt),
      );
      return Right(documents);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to get documents: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ScanDocument>> getDocument(String id) async {
    try {
      final model = _localBox.get(id);
      if (model == null) {
        return Left(
          NotFoundFailure(message: 'Document not found: $id'),
        );
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to get document: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ScanDocument>> createDocument(
    ScanDocument document,
  ) async {
    try {
      final model = ScanDocumentModel.fromEntity(document);
      await _localBox.put(document.id, model);

      await _syncToFirestore(document.id, model);

      return Right(document);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to create document: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ScanDocument>> updateDocument(
    ScanDocument document,
  ) async {
    try {
      final updatedDoc = document.copyWith(
        updatedAt: DateTime.now(),
      );
      final model = ScanDocumentModel.fromEntity(updatedDoc);
      await _localBox.put(document.id, model);

      await _syncToFirestore(document.id, model);

      return Right(updatedDoc);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to update document: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDocument(String id) async {
    try {
      final model = _localBox.get(id);
      if (model == null) {
        return Left(
          NotFoundFailure(message: 'Document not found: $id'),
        );
      }

      final deletedDoc = model.toEntity().copyWith(
            isDeleted: true,
            updatedAt: DateTime.now(),
          );
      await _localBox.put(id, ScanDocumentModel.fromEntity(deletedDoc));

      await _syncToFirestore(id, ScanDocumentModel.fromEntity(deletedDoc));

      return const Right(unit);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to delete document: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ScanDocument>> restoreDocument(String id) async {
    try {
      final model = _localBox.get(id);
      if (model == null) {
        return Left(
          NotFoundFailure(message: 'Document not found: $id'),
        );
      }

      final restoredDoc = model.toEntity().copyWith(
            isDeleted: false,
            updatedAt: DateTime.now(),
          );
      await _localBox.put(id, ScanDocumentModel.fromEntity(restoredDoc));

      await _syncToFirestore(id, ScanDocumentModel.fromEntity(restoredDoc));

      return Right(restoredDoc);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to restore document: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ScanDocument>>> getFavorites() async {
    try {
      final favorites = _localBox.values
          .map((model) => model.toEntity())
          .where((doc) => doc.isFavorite && !doc.isDeleted)
          .toList();
      favorites.sort(
        (a, b) => b.updatedAt.compareTo(a.updatedAt),
      );
      return Right(favorites);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to get favorites: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ScanDocument>>> getRecent({
    int limit = 10,
  }) async {
    try {
      final recent = _localBox.values
          .map((model) => model.toEntity())
          .where((doc) => !doc.isDeleted && !doc.isArchived)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return Right(recent.take(limit).toList());
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to get recent documents: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ScanDocument>>> getByFolder(
    String? folderId,
  ) async {
    try {
      final docs = _localBox.values
          .map((model) => model.toEntity())
          .where((doc) =>
              doc.folderId == folderId && !doc.isDeleted)
          .toList();
      docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return Right(docs);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to get documents by folder: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ScanDocument>>> getByTag(String tagId) async {
    try {
      final docs = _localBox.values
          .map((model) => model.toEntity())
          .where((doc) =>
              doc.tags.contains(tagId) && !doc.isDeleted)
          .toList();
      docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return Right(docs);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to get documents by tag: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ScanDocument>>> searchDocuments(
    String query,
  ) async {
    try {
      final lowerQuery = query.toLowerCase();
      final results = _localBox.values
          .map((model) => model.toEntity())
          .where((doc) {
        if (doc.isDeleted) return false;
        if (doc.title.toLowerCase().contains(lowerQuery)) return true;
        if (doc.ocrText != null &&
            doc.ocrText!.toLowerCase().contains(lowerQuery)) {
          return true;
        }
        return false;
      }).toList();
      results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return Right(results);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to search documents: $e'),
      );
    }
  }

  /// Syncs the document model to Firestore.
  Future<void> _syncToFirestore(
    String id,
    ScanDocumentModel model,
  ) async {
    try {
      await _firestore
          .collection(_firestoreCollection)
          .doc(id)
          .set(model.toJson(), SetOptions(merge: true));
    } catch (_) {
      // Sync failures are handled by the background sync mechanism.
    }
  }
}
