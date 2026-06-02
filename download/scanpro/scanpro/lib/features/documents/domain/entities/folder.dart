import 'package:equatable/equatable.dart';

/// Entity representing a folder for organizing scanned documents.
///
/// Folders support hierarchical nesting through the [parentId] field,
/// allowing users to create a tree structure for document organization.
class Folder extends Equatable {
  /// Unique identifier for the folder.
  final String id;

  /// Display name of the folder.
  final String name;

  /// ID of the parent folder; null for root-level folders.
  final String? parentId;

  /// Color hex code for the folder (e.g., '#FF5722').
  final String color;

  /// Icon identifier from the available icon set.
  final String icon;

  /// Number of documents directly contained in this folder.
  final int documentCount;

  /// Timestamp when the folder was created.
  final DateTime createdAt;

  /// Timestamp when the folder was last updated.
  final DateTime updatedAt;

  const Folder({
    required this.id,
    required this.name,
    this.parentId,
    this.color = '#2196F3',
    this.icon = 'folder',
    this.documentCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this is a root-level folder (no parent).
  bool get isRoot => parentId == null;

  /// Creates a copy with optional field overrides.
  Folder copyWith({
    String? id,
    String? name,
    String? parentId,
    String? color,
    String? icon,
    int? documentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      documentCount: documentCount ?? this.documentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        parentId,
        color,
        icon,
        documentCount,
        createdAt,
        updatedAt,
      ];
}
