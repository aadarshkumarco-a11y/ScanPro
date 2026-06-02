import 'package:scanpro/features/search/domain/entities/search_result.dart';

/// Data model for [SearchResult], extending the domain entity with
/// JSON and Hive serialization support.
class SearchResultModel extends SearchResult {
  const SearchResultModel({
    required super.id,
    required super.title,
    required super.type,
    required super.matchedText,
    required super.filePath,
    required super.createdAt,
    super.relevanceScore = 0.0,
  });

  /// Creates a [SearchResultModel] from a domain [SearchResult] entity.
  factory SearchResultModel.fromEntity(SearchResult entity) {
    return SearchResultModel(
      id: entity.id,
      title: entity.title,
      type: entity.type,
      matchedText: entity.matchedText,
      filePath: entity.filePath,
      createdAt: entity.createdAt,
      relevanceScore: entity.relevanceScore,
    );
  }

  /// Creates a [SearchResultModel] from a JSON map.
  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: _typeFromString(json['type'] as String),
      matchedText: json['matchedText'] as String,
      filePath: json['filePath'] as String,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      relevanceScore: (json['relevanceScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Creates a [SearchResultModel] from a Hive box entry.
  factory SearchResultModel.fromHive(Map<dynamic, dynamic> map) {
    return SearchResultModel(
      id: map['id'] as String,
      title: map['title'] as String,
      type: _typeFromString(map['type'] as String),
      matchedText: map['matchedText'] as String,
      filePath: map['filePath'] as String,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      relevanceScore: (map['relevanceScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': _typeToString(type),
      'matchedText': matchedText,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'relevanceScore': relevanceScore,
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'title': title,
      'type': _typeToString(type),
      'matchedText': matchedText,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'relevanceScore': relevanceScore,
    };
  }

  /// Converts this model back to a domain [SearchResult] entity.
  SearchResult toEntity() {
    return SearchResult(
      id: id,
      title: title,
      type: type,
      matchedText: matchedText,
      filePath: filePath,
      createdAt: createdAt,
      relevanceScore: relevanceScore,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  static SearchResultType _typeFromString(String value) {
    switch (value) {
      case 'document':
        return SearchResultType.document;
      case 'ocrText':
        return SearchResultType.ocrText;
      case 'tag':
        return SearchResultType.tag;
      case 'folder':
        return SearchResultType.folder;
      default:
        return SearchResultType.document;
    }
  }

  static String _typeToString(SearchResultType type) {
    switch (type) {
      case SearchResultType.document:
        return 'document';
      case SearchResultType.ocrText:
        return 'ocrText';
      case SearchResultType.tag:
        return 'tag';
      case SearchResultType.folder:
        return 'folder';
    }
  }
}
