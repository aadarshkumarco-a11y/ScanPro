import 'package:equatable/equatable.dart';

/// Entity representing a collection of folders and documents.
///
/// Collections allow users to group items from different folders
/// into a single view, similar to playlists in a music app.
class Collection extends Equatable {
  /// Unique identifier for the collection.
  final String id;

  /// Display name of the collection.
  final String name;

  /// IDs of folders included in this collection.
  final List<String> folderIds;

  /// IDs of individual documents included in this collection.
  final List<String> documentIds;

  /// Color hex code for the collection (e.g., '#9C27B0').
  final String color;

  /// Icon identifier from the available icon set.
  final String icon;

  /// Timestamp when the collection was created.
  final DateTime createdAt;

  const Collection({
    required this.id,
    required this.name,
    this.folderIds = const [],
    this.documentIds = const [],
    this.color = '#9C27B0',
    this.icon = 'collection',
    required this.createdAt,
  });

  /// Total number of items in the collection.
  int get totalItemCount => folderIds.length + documentIds.length;

  /// Whether the collection contains any items.
  bool get isEmpty => totalItemCount == 0;

  /// Creates a copy with optional field overrides.
  Collection copyWith({
    String? id,
    String? name,
    List<String>? folderIds,
    List<String>? documentIds,
    String? color,
    String? icon,
    DateTime? createdAt,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      folderIds: folderIds ?? this.folderIds,
      documentIds: documentIds ?? this.documentIds,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        folderIds,
        documentIds,
        color,
        icon,
        createdAt,
      ];
}
