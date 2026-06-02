import 'package:equatable/equatable.dart';

/// Type of content that a search result refers to.
enum SearchResultType {
  document,
  ocrText,
  tag,
  folder,
}

/// Domain entity representing a single search result.
///
/// Each result contains the matched text snippet, the type of content
/// it belongs to, and the file path so the user can navigate to it.
class SearchResult extends Equatable {
  const SearchResult({
    required this.id,
    required this.title,
    required this.type,
    required this.matchedText,
    required this.filePath,
    required this.createdAt,
    this.relevanceScore = 0.0,
  });

  /// Unique identifier for this search result.
  final String id;

  /// Display title (e.g. document name or tag value).
  final String title;

  /// The category of the matched content.
  final SearchResultType type;

  /// The text fragment that matched the search query.
  final String matchedText;

  /// Absolute file path to the source document.
  final String filePath;

  /// Timestamp when the source content was created.
  final DateTime createdAt;

  /// Relevance score from 0.0 to 1.0 used for result ranking.
  final double relevanceScore;

  /// Creates a copy with optional field overrides.
  SearchResult copyWith({
    String? id,
    String? title,
    SearchResultType? type,
    String? matchedText,
    String? filePath,
    DateTime? createdAt,
    double? relevanceScore,
  }) {
    return SearchResult(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      matchedText: matchedText ?? this.matchedText,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        matchedText,
        filePath,
        createdAt,
        relevanceScore,
      ];
}
