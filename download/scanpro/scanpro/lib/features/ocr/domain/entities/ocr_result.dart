import 'package:equatable/equatable.dart';

/// Enumeration of smart action types that can be detected in OCR text.
enum SmartActionType {
  /// Phone number detected.
  phone,

  /// Email address detected.
  email,

  /// URL / web link detected.
  url,

  /// Physical address detected.
  address,

  /// Date or time reference detected.
  date,
}

/// Represents a single smart action detected in OCR text.
class SmartAction extends Equatable {
  /// Type of the detected smart action.
  final SmartActionType type;

  /// The detected text value (e.g., the phone number, email address).
  final String value;

  /// Starting character index in the original text.
  final int startIndex;

  /// Ending character index in the original text.
  final int endIndex;

  const SmartAction({
    required this.type,
    required this.value,
    required this.startIndex,
    required this.endIndex,
  });

  @override
  List<Object?> get props => [type, value, startIndex, endIndex];
}

/// Entity representing the result of OCR text extraction.
///
/// Contains the extracted text, detected language, confidence score,
/// paragraph breakdown, and any smart actions detected in the text.
class OCRResult extends Equatable {
  /// Unique identifier for this OCR result.
  final String id;

  /// ID of the document this OCR result belongs to.
  final String documentId;

  /// Full extracted text content.
  final String text;

  /// Detected language code (e.g., 'en', 'es', 'fr').
  final String language;

  /// Overall confidence score of the text recognition (0.0–1.0).
  final double confidence;

  /// List of detected paragraphs in the text.
  final List<String> paragraphs;

  /// Smart actions detected within the extracted text.
  final List<SmartAction> smartActions;

  /// Timestamp when the OCR result was created.
  final DateTime createdAt;

  const OCRResult({
    required this.id,
    required this.documentId,
    required this.text,
    this.language = 'en',
    this.confidence = 0.0,
    this.paragraphs = const [],
    this.smartActions = const [],
    required this.createdAt,
  });

  /// Whether any smart actions were detected.
  bool get hasSmartActions => smartActions.isNotEmpty;

  /// Returns all phone numbers found in the text.
  List<SmartAction> get phoneNumbers =>
      smartActions.where((a) => a.type == SmartActionType.phone).toList();

  /// Returns all email addresses found in the text.
  List<SmartAction> get emails =>
      smartActions.where((a) => a.type == SmartActionType.email).toList();

  /// Returns all URLs found in the text.
  List<SmartAction> get urls =>
      smartActions.where((a) => a.type == SmartActionType.url).toList();

  /// Returns all addresses found in the text.
  List<SmartAction> get addresses =>
      smartActions.where((a) => a.type == SmartActionType.address).toList();

  /// Returns all dates found in the text.
  List<SmartAction> get dates =>
      smartActions.where((a) => a.type == SmartActionType.date).toList();

  /// Creates a copy with optional field overrides.
  OCRResult copyWith({
    String? id,
    String? documentId,
    String? text,
    String? language,
    double? confidence,
    List<String>? paragraphs,
    List<SmartAction>? smartActions,
    DateTime? createdAt,
  }) {
    return OCRResult(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      text: text ?? this.text,
      language: language ?? this.language,
      confidence: confidence ?? this.confidence,
      paragraphs: paragraphs ?? this.paragraphs,
      smartActions: smartActions ?? this.smartActions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        text,
        language,
        confidence,
        paragraphs,
        smartActions,
        createdAt,
      ];
}
