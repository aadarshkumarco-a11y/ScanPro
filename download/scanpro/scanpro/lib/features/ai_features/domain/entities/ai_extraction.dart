import 'package:equatable/equatable.dart';

/// Entity representing structured data extracted from a document by AI.
///
/// Contains the detected document type and a map of extracted fields
/// specific to that document type (e.g., invoice number, total amount).
class AIExtraction extends Equatable {
  /// Unique identifier for this extraction.
  final String id;

  /// ID of the document this extraction belongs to.
  final String documentId;

  /// Detected document type (e.g., 'invoice', 'receipt', 'id_card', 'contract').
  final String documentType;

  /// Extracted key-value fields specific to the document type.
  ///
  /// Example for an invoice:
  /// ```dart
  /// {
  ///   'invoice_number': 'INV-2024-001',
  ///   'total_amount': '\$1,250.00',
  ///   'due_date': '2024-03-15',
  ///   'vendor_name': 'Acme Corp',
  /// }
  /// ```
  final Map<String, dynamic> extractedFields;

  /// Overall confidence score of the extraction (0.0–1.0).
  final double confidence;

  const AIExtraction({
    required this.id,
    required this.documentId,
    required this.documentType,
    this.extractedFields = const {},
    this.confidence = 0.0,
  });

  /// Gets a specific extracted field by key.
  /// Returns null if the key does not exist.
  T? getField<T>(String key) {
    final value = extractedFields[key];
    if (value is T) return value;
    return null;
  }

  /// Gets a specific extracted field by key with a default value.
  T getFieldOrDefault<T>(String key, T defaultValue) {
    final value = extractedFields[key];
    if (value is T) return value;
    return defaultValue;
  }

  /// Whether the AI has high confidence in this extraction.
  bool get isHighConfidence => confidence >= 0.8;

  /// Creates a copy with optional field overrides.
  AIExtraction copyWith({
    String? id,
    String? documentId,
    String? documentType,
    Map<String, dynamic>? extractedFields,
    double? confidence,
  }) {
    return AIExtraction(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentType: documentType ?? this.documentType,
      extractedFields: extractedFields ?? this.extractedFields,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        documentType,
        extractedFields,
        confidence,
      ];
}
