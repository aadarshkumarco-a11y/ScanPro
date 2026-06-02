import 'package:equatable/equatable.dart';

/// Entity representing a tag for categorizing scanned documents.
///
/// Tags provide a flexible, non-hierarchical way to organize documents
/// beyond the folder structure. Each tag tracks its usage frequency.
class Tag extends Equatable {
  /// Unique identifier for the tag.
  final String id;

  /// Display name of the tag.
  final String name;

  /// Color hex code for the tag (e.g., '#4CAF50').
  final String color;

  /// Number of documents currently using this tag.
  final int usageCount;

  /// Timestamp when the tag was created.
  final DateTime createdAt;

  const Tag({
    required this.id,
    required this.name,
    this.color = '#4CAF50',
    this.usageCount = 0,
    required this.createdAt,
  });

  /// Creates a copy with optional field overrides.
  Tag copyWith({
    String? id,
    String? name,
    String? color,
    int? usageCount,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, color, usageCount, createdAt];
}
