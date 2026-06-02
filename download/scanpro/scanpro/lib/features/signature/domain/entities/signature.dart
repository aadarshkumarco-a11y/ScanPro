import 'package:equatable/equatable.dart';

/// Entity representing a saved signature.
///
/// Stores the signature image data for reuse across documents.
class Signature extends Equatable {
  /// Unique identifier for this signature.
  final String id;

  /// Display name for the signature (e.g., 'John Doe - Formal').
  final String name;

  /// Base64-encoded PNG image data of the signature.
  final String imageData;

  /// Timestamp when the signature was created.
  final DateTime createdAt;

  /// Timestamp when the signature was last modified.
  final DateTime updatedAt;

  const Signature({
    required this.id,
    required this.name,
    required this.imageData,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy with optional field overrides.
  Signature copyWith({
    String? id,
    String? name,
    String? imageData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Signature(
      id: id ?? this.id,
      name: name ?? this.name,
      imageData: imageData ?? this.imageData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, imageData, createdAt, updatedAt];
}
