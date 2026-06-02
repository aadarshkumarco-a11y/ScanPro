import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scanpro/core/error/failures.dart';

/// Custom exception for Firebase sync errors.
class FirebaseSyncException implements Exception {
  final String message;
  final bool isConflict;
  final Map<String, dynamic>? remoteData;

  const FirebaseSyncException({
    required this.message,
    this.isConflict = false,
    this.remoteData,
  });

  @override
  String toString() => 'FirebaseSyncException: $message';
}

/// Service for synchronizing documents with Firebase Firestore.
///
/// Handles uploading, downloading, and conflict detection for
/// document data between the local device and the cloud.
class FirebaseSyncService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _documentsCollection = 'documents';
  static const String _usersCollection = 'users';

  FirebaseSyncService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  /// Gets the current user ID, throwing if not authenticated.
  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw const FirebaseSyncException(
        message: 'User is not authenticated',
      );
    }
    return user.uid;
  }

  /// Gets the user's document collection reference.
  CollectionReference<Map<String, dynamic>> get _userDocuments {
    return _firestore
        .collection(_usersCollection)
        .doc(_userId)
        .collection(_documentsCollection);
  }

  /// Uploads a document to Firestore.
  ///
  /// [data] is the document data map to upload.
  /// [forceOverwrite] if true, skips conflict detection.
  Future<void> uploadDocument(
    Map<String, dynamic> data, {
    bool forceOverwrite = false,
  }) async {
    try {
      final docId = data['id'] as String;
      final docRef = _userDocuments.doc(docId);

      if (!forceOverwrite) {
        final serverDoc = await docRef.get();
        if (serverDoc.exists) {
          final serverData = serverDoc.data()!;
          final serverUpdatedAt = serverData['updatedAt'] as String?;
          final localUpdatedAt = data['updatedAt'] as String?;

          if (serverUpdatedAt != null &&
              localUpdatedAt != null &&
              serverUpdatedAt.compareTo(localUpdatedAt) > 0) {
            throw FirebaseSyncException(
              message: 'Document was modified on another device',
              isConflict: true,
              remoteData: serverData,
            );
          }
        }
      }

      await docRef.set(
        {
          ...data,
          'syncedAt': DateTime.now().toIso8601String(),
          'userId': _userId,
        },
        SetOptions(merge: true),
      );
    } on FirebaseSyncException {
      rethrow;
    } catch (e) {
      throw FirebaseSyncException(
        message: 'Failed to upload document: $e',
      );
    }
  }

  /// Downloads documents that have changed since the given timestamp.
  ///
  /// [since] is the timestamp to compare against.
  /// Returns a list of document data maps.
  Future<List<Map<String, dynamic>>> downloadChanges({
    DateTime? since,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _userDocuments;

      if (since != null) {
        query = query.where(
          'syncedAt',
          isGreaterThan: since.toIso8601String(),
        );
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => doc.data())
          .where((data) => data.isNotEmpty)
          .toList();
    } catch (e) {
      throw FirebaseSyncException(
        message: 'Failed to download changes: $e',
      );
    }
  }

  /// Deletes a document from Firestore.
  ///
  /// [documentId] is the ID of the document to delete.
  Future<void> deleteDocument(String documentId) async {
    try {
      await _userDocuments.doc(documentId).delete();
    } catch (e) {
      throw FirebaseSyncException(
        message: 'Failed to delete document from cloud: $e',
      );
    }
  }

  /// Gets a specific document from Firestore.
  ///
  /// [documentId] is the ID of the document to retrieve.
  /// Returns the document data map, or null if not found.
  Future<Map<String, dynamic>?> getDocument(String documentId) async {
    try {
      final doc = await _userDocuments.doc(documentId).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw FirebaseSyncException(
        message: 'Failed to get document from cloud: $e',
      );
    }
  }

  /// Gets the count of documents stored in the cloud.
  Future<int> getCloudDocumentCount() async {
    try {
      final snapshot = await _userDocuments.get();
      return snapshot.size;
    } catch (e) {
      throw FirebaseSyncException(
        message: 'Failed to get cloud document count: $e',
      );
    }
  }

  /// Batch uploads multiple documents to Firestore.
  ///
  /// [documents] is a list of document data maps to upload.
  /// Uses Firestore batch writes for efficiency.
  Future<void> batchUpload(List<Map<String, dynamic>> documents) async {
    try {
      const batchSize = 500;
      for (var i = 0; i < documents.length; i += batchSize) {
        final batch = _firestore.batch();
        final end = (i + batchSize).clamp(0, documents.length);

        for (var j = i; j < end; j++) {
          final data = documents[j];
          final docRef = _userDocuments.doc(data['id'] as String);
          batch.set(
            docRef,
            {
              ...data,
              'syncedAt': DateTime.now().toIso8601String(),
              'userId': _userId,
            },
            SetOptions(merge: true),
          );
        }

        await batch.commit();
      }
    } catch (e) {
      throw FirebaseSyncException(
        message: 'Batch upload failed: $e',
      );
    }
  }
}
