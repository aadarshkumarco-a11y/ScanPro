import 'package:hive/hive.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_record.dart';

part 'sync_record_model.g.dart';

/// Hive-compatible data model for [SyncRecord].
///
/// Provides serialization/deserialization for local storage with Hive,
/// and conversion methods between the domain entity and data model.
@HiveType(typeId: 6)
class SyncRecordModel extends HiveObject {
  /// Unique identifier.
  @HiveField(0)
  final String id;

  /// ID of the document being synced.
  @HiveField(1)
  final String documentId;

  /// Sync operation type index.
  @HiveField(2)
  final int operationIndex;

  /// Timestamp as ISO 8601 string.
  @HiveField(3)
  final String timestamp;

  /// Sync record status index.
  @HiveField(4)
  final int statusIndex;

  /// Conflict data as a JSON-serializable map.
  @HiveField(5)
  final Map? conflictData;

  /// Number of retry attempts.
  @HiveField(6)
  final int retryCount;

  SyncRecordModel({
    required this.id,
    required this.documentId,
    required this.operationIndex,
    required this.timestamp,
    this.statusIndex = 0,
    this.conflictData,
    this.retryCount = 0,
  });

  /// Creates a model from a domain entity.
  factory SyncRecordModel.fromEntity(SyncRecord entity) {
    return SyncRecordModel(
      id: entity.id,
      documentId: entity.documentId,
      operationIndex: entity.operation.index,
      timestamp: entity.timestamp.toIso8601String(),
      statusIndex: entity.status.index,
      conflictData: entity.conflictData,
      retryCount: entity.retryCount,
    );
  }

  /// Converts this model to a domain entity.
  SyncRecord toEntity() {
    return SyncRecord(
      id: id,
      documentId: documentId,
      operation: SyncOperation.values[operationIndex.clamp(
        0,
        SyncOperation.values.length - 1,
      )],
      timestamp: DateTime.parse(timestamp),
      status: SyncRecordStatus.values[statusIndex.clamp(
        0,
        SyncRecordStatus.values.length - 1,
      )],
      conflictData: conflictData != null
          ? Map<String, dynamic>.from(conflictData!)
          : null,
      retryCount: retryCount,
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'operationIndex': operationIndex,
      'timestamp': timestamp,
      'statusIndex': statusIndex,
      'conflictData': conflictData,
      'retryCount': retryCount,
    };
  }

  /// Creates a model from a JSON map.
  factory SyncRecordModel.fromJson(Map<String, dynamic> json) {
    return SyncRecordModel(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      operationIndex: json['operationIndex'] as int,
      timestamp: json['timestamp'] as String,
      statusIndex: json['statusIndex'] as int? ?? 0,
      conflictData: json['conflictData'] as Map?,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}
