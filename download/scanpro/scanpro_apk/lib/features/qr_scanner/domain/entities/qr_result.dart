import 'package:equatable/equatable.dart';

/// Type of data encoded in a QR code.
enum QrDataType {
  url,
  text,
  wifi,
  contact,
  email,
  phone,
  sms,
}

/// Domain entity representing a scanned QR code result.
///
/// Stores the raw data, detected type, and creation timestamp.
class QrResult extends Equatable {
  const QrResult({
    required this.id,
    required this.data,
    required this.type,
    required this.createdAt,
  });

  /// Unique identifier for this scan result.
  final String id;

  /// The raw data string decoded from the QR code.
  final String data;

  /// The detected data type of the QR code content.
  final QrDataType type;

  /// Timestamp when the QR code was scanned.
  final DateTime createdAt;

  /// Creates a copy with optional field overrides.
  QrResult copyWith({
    String? id,
    String? data,
    QrDataType? type,
    DateTime? createdAt,
  }) {
    return QrResult(
      id: id ?? this.id,
      data: data ?? this.data,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, data, type, createdAt];
}
