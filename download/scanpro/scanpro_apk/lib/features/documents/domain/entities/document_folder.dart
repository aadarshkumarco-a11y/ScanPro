import 'package:equatable/equatable.dart';

/// Domain entity representing a folder that groups scanned documents.
///
/// Folders allow users to organise their scanned documents into
/// logical categories (e.g. "Work", "Receipts", "Medical").
class DocumentFolder extends Equatable {
  const DocumentFolder({
    required this.id,
    required this.name,
    required this.createdAt,
    this.color,
    this.icon,
    this.parentFolderId,
    this.documentCount = 0,
    this.isSynced = false,
  });

  /// Unique identifier for this folder.
  final String id;

  /// Human-readable folder name.
  final String name;

  /// Timestamp when the folder was created.
  final DateTime createdAt;

  /// Optional folder colour as a hex string (e.g. '#4D2DAB').
  final String? color;

  /// Optional icon identifier for the folder.
  final String? icon;

  /// ID of the parent folder for nested folder support.
  final String? parentFolderId;

  /// Number of documents in this folder.
  final int documentCount;

  /// Whether this folder has been synced to the cloud.
  final bool isSynced;

  /// Creates a copy with optional field overrides.
  DocumentFolder copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? color,
    String? icon,
    String? parentFolderId,
    int? documentCount,
    bool? isSynced,
  }) {
    return DocumentFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      documentCount: documentCount ?? this.documentCount,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        createdAt,
        color,
        icon,
        parentFolderId,
        documentCount,
        isSynced,
      ];
}
