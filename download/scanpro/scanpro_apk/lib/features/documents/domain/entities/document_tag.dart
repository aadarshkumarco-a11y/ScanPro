import 'package:equatable/equatable.dart';

/// Domain entity representing a tag that can be applied to documents.
///
/// Tags provide a flexible, flat categorisation system that
/// complements the hierarchical folder structure.
class DocumentTag extends Equatable {
  const DocumentTag({
    required this.id,
    required this.name,
    this.color,
    this.usageCount = 0,
    this.createdAt,
  });

  /// Unique identifier for this tag.
  final String id;

  /// Human-readable tag name (e.g. "receipt", "urgent").
  final String name;

  /// Optional tag colour as a hex string (e.g. '#00BFA6').
  final String? color;

  /// Number of documents using this tag.
  final int usageCount;

  /// Timestamp when the tag was created.
  final DateTime? createdAt;

  /// Creates a copy with optional field overrides.
  DocumentTag copyWith({
    String? id,
    String? name,
    String? color,
    int? usageCount,
    DateTime? createdAt,
  }) {
    return DocumentTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        color,
        usageCount,
        createdAt,
      ];
}
