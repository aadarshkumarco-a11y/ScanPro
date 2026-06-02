import 'package:equatable/equatable.dart';

/// Domain entity representing a saved signature.
///
/// Stores the signature image data (as a base64-encoded PNG),
/// a user-defined name, creation timestamp, and whether it
/// is the default signature used when signing documents.
class Signature extends Equatable {
  const Signature({
    required this.id,
    required this.name,
    required this.imageData,
    required this.createdAt,
    this.isDefault = false,
  });

  /// Unique identifier for this signature.
  final String id;

  /// Human-readable name (e.g. "John Doe - Formal").
  final String name;

  /// Base64-encoded PNG image data of the signature.
  final String imageData;

  /// When this signature was created.
  final DateTime createdAt;

  /// Whether this is the default signature.
  final bool isDefault;

  /// Creates a copy with optional field overrides.
  Signature copyWith({
    String? id,
    String? name,
    String? imageData,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return Signature(
      id: id ?? this.id,
      name: name ?? this.name,
      imageData: imageData ?? this.imageData,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        imageData,
        createdAt,
        isDefault,
      ];
}
