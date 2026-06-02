import 'dart:convert';

import 'package:scanpro/features/cloud_sync/domain/entities/sync_record.dart';

/// Data model for [SyncRecord], extending the domain entity with
/// JSON, Hive, and Firestore serialization support.
class SyncRecordModel extends SyncRecord {
  const SyncRecordModel({
    required super.id,
    required super.documentId,
    required super.syncStatus,
    super.lastSyncedAt,
    required super.version,
    super.cloudPath,
    super.errorMessage,
  });

  /// Creates a [SyncRecordModel] from a domain [SyncRecord] entity.
  factory SyncRecordModel.fromEntity(SyncRecord entity) {
    return SyncRecordModel(
      id: entity.id,
      documentId: entity.documentId,
      syncStatus: entity.syncStatus,
      lastSyncedAt: entity.lastSyncedAt,
      version: entity.version,
      cloudPath: entity.cloudPath,
      errorMessage: entity.errorMessage,
    );
  }

  /// Creates a [SyncRecordModel] from a JSON map.
  factory SyncRecordModel.fromJson(Map<String, dynamic> json) {
    return SyncRecordModel(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      syncStatus: _statusFromString(json['syncStatus'] as String),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? json['lastSyncedAt'] is String
              ? DateTime.parse(json['lastSyncedAt'] as String)
              : DateTime.fromMillisecondsSinceEpoch(json['lastSyncedAt'] as int)
          : null,
      version: json['version'] as int,
      cloudPath: json['cloudPath'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  /// Creates a [SyncRecordModel] from a Hive box entry.
  factory SyncRecordModel.fromHive(Map<dynamic, dynamic> map) {
    return SyncRecordModel(
      id: map['id'] as String,
      documentId: map['documentId'] as String,
      syncStatus: _statusFromString(map['syncStatus'] as String),
      lastSyncedAt: map['lastSyncedAt'] != null
          ? map['lastSyncedAt'] is String
              ? DateTime.parse(map['lastSyncedAt'] as String)
              : map['lastSyncedAt'] is int
                  ? DateTime.fromMillisecondsSinceEpoch(map['lastSyncedAt'] as int)
                  : null
          : null,
      version: map['version'] as int,
      cloudPath: map['cloudPath'] as String?,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  /// Creates a [SyncRecordModel] from a Firestore document snapshot.
  factory SyncRecordModel.fromFirestore(Map<String, dynamic> data) {
    return SyncRecordModel(
      id: data['id'] as String? ?? '',
      documentId: data['documentId'] as String,
      syncStatus: _statusFromString(data['syncStatus'] as String? ?? 'pending'),
      lastSyncedAt: data['lastSyncedAt'] != null
          ? (data['lastSyncedAt'] as dynamic).toDate() as DateTime
          : null,
      version: data['version'] as int? ?? 1,
      cloudPath: data['cloudPath'] as String?,
      errorMessage: data['errorMessage'] as String?,
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'syncStatus': _statusToString(syncStatus),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'version': version,
      'cloudPath': cloudPath,
      'errorMessage': errorMessage,
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'documentId': documentId,
      'syncStatus': _statusToString(syncStatus),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'version': version,
      'cloudPath': cloudPath,
      'errorMessage': errorMessage,
    };
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'documentId': documentId,
      'syncStatus': _statusToString(syncStatus),
      'lastSyncedAt': lastSyncedAt,
      'version': version,
      'cloudPath': cloudPath,
      'errorMessage': errorMessage,
    };
  }

  /// Converts this model back to a domain [SyncRecord] entity.
  @override
  SyncRecord toEntity() {
    return SyncRecord(
      id: id,
      documentId: documentId,
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt,
      version: version,
      cloudPath: cloudPath,
      errorMessage: errorMessage,
    );
  }

  // ── Private Helpers ──────────────────────────────────────────────

  /// Converts a [SyncStatus] to its string representation.
  static String _statusToString(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.conflict:
        return 'conflict';
      case SyncStatus.error:
        return 'error';
    }
  }

  /// Parses a string back to [SyncStatus].
  static SyncStatus _statusFromString(String value) {
    switch (value) {
      case 'pending':
        return SyncStatus.pending;
      case 'synced':
        return SyncStatus.synced;
      case 'conflict':
        return SyncStatus.conflict;
      case 'error':
        return SyncStatus.error;
      default:
        return SyncStatus.pending;
    }
  }
}
