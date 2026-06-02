import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/search_result.dart';
import '../models/search_result_model.dart';

/// Local data source for search operations using Hive.
///
/// Provides full-text matching across documents, OCR text, and tags.
/// Also manages the recent-search history. All methods throw
/// [CacheException] on failure so the repository implementation
/// can convert them to [Failure]s.
class SearchLocalDatasource {
  SearchLocalDatasource({
    required Box<dynamic> searchBox,
    required Box<dynamic> documentsBox,
  })  : _searchBox = searchBox,
        _documentsBox = documentsBox;

  final Box<dynamic> _searchBox;
  final Box<dynamic> _documentsBox;
  static const _uuid = Uuid();

  // ═══════════════════════════════════════════════════════════════════
  //  Full-Text Search
  // ═══════════════════════════════════════════════════════════════════

  static const String _recentSearchesKey = 'recent_searches';

  /// Performs a full-text search across document names, OCR text, and
  /// tags stored in the documents Hive box.
  ///
  /// Matching is case-insensitive and supports partial word matching.
  List<SearchResultModel> search(String query) {
    try {
      final lowerQuery = query.toLowerCase().trim();
      if (lowerQuery.isEmpty) return [];

      final results = <SearchResultModel>[];

      for (final key in _documentsBox.keys) {
        final value = _documentsBox.get(key);
        if (value is! Map) continue;

        final map = Map<String, dynamic>.from(value);

        // Skip trashed documents.
        if (map['isTrashed'] as bool? ?? false) continue;

        final docId = map['id'] as String? ?? key.toString();
        final docName = map['name'] as String? ?? '';
        final filePath = map['filePath'] as String? ?? '';
        final ocrText = map['ocrText'] as String? ?? '';
        final tags = (map['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];
        final createdAt = _parseDate(map['createdAt']);

        // ── Match against document name ───────────────────────────
        if (docName.toLowerCase().contains(lowerQuery)) {
          results.add(SearchResultModel(
            id: _uuid.v4(),
            title: docName,
            type: SearchResultType.document,
            matchedText: _extractSnippet(docName, lowerQuery),
            filePath: filePath,
            createdAt: createdAt,
            relevanceScore: _calculateRelevance(
              lowerQuery,
              docName,
            ),
          ));
        }

        // ── Match against OCR text ────────────────────────────────
        if (ocrText.toLowerCase().contains(lowerQuery)) {
          results.add(SearchResultModel(
            id: _uuid.v4(),
            title: docName,
            type: SearchResultType.ocrText,
            matchedText: _extractSnippet(ocrText, lowerQuery),
            filePath: filePath,
            createdAt: createdAt,
            relevanceScore: _calculateRelevance(
              lowerQuery,
              ocrText,
            ),
          ));
        }

        // ── Match against tags ────────────────────────────────────
        for (final tag in tags) {
          if (tag.toLowerCase().contains(lowerQuery)) {
            results.add(SearchResultModel(
              id: _uuid.v4(),
              title: docName,
              type: SearchResultType.tag,
              matchedText: '#$tag',
              filePath: filePath,
              createdAt: createdAt,
              relevanceScore: _calculateRelevance(
                lowerQuery,
                tag,
              ),
            ));
          }
        }
      }

      // Sort by relevance score descending.
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

      return results;
    } catch (e) {
      throw CacheException(
        message: 'Failed to perform search: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Searches documents by tag.
  List<SearchResultModel> searchByTag(String tag) {
    try {
      final lowerTag = tag.toLowerCase().trim();
      if (lowerTag.isEmpty) return [];

      final results = <SearchResultModel>[];

      for (final key in _documentsBox.keys) {
        final value = _documentsBox.get(key);
        if (value is! Map) continue;

        final map = Map<String, dynamic>.from(value);
        if (map['isTrashed'] as bool? ?? false) continue;

        final tags = (map['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];

        final hasMatch = tags.any(
          (t) => t.toLowerCase().contains(lowerTag),
        );

        if (hasMatch) {
          results.add(SearchResultModel(
            id: _uuid.v4(),
            title: map['name'] as String? ?? '',
            type: SearchResultType.tag,
            matchedText: tags
                .where((t) => t.toLowerCase().contains(lowerTag))
                .map((t) => '#$t')
                .join(', '),
            filePath: map['filePath'] as String? ?? '',
            createdAt: _parseDate(map['createdAt']),
            relevanceScore: 1.0,
          ));
        }
      }

      return results;
    } catch (e) {
      throw CacheException(
        message: 'Failed to search by tag: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Searches OCR text content.
  List<SearchResultModel> searchByOcrText(String query) {
    try {
      final lowerQuery = query.toLowerCase().trim();
      if (lowerQuery.isEmpty) return [];

      final results = <SearchResultModel>[];

      for (final key in _documentsBox.keys) {
        final value = _documentsBox.get(key);
        if (value is! Map) continue;

        final map = Map<String, dynamic>.from(value);
        if (map['isTrashed'] as bool? ?? false) continue;

        final ocrText = map['ocrText'] as String? ?? '';
        if (ocrText.toLowerCase().contains(lowerQuery)) {
          results.add(SearchResultModel(
            id: _uuid.v4(),
            title: map['name'] as String? ?? '',
            type: SearchResultType.ocrText,
            matchedText: _extractSnippet(ocrText, lowerQuery),
            filePath: map['filePath'] as String? ?? '',
            createdAt: _parseDate(map['createdAt']),
            relevanceScore: _calculateRelevance(lowerQuery, ocrText),
          ));
        }
      }

      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      return results;
    } catch (e) {
      throw CacheException(
        message: 'Failed to search OCR text: ${e.toString()}',
        code: 1003,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Recent Searches
  // ═══════════════════════════════════════════════════════════════════

  /// Retrieves the list of recent search queries.
  List<String> getRecentSearches() {
    try {
      final data = _searchBox.get(_recentSearchesKey);
      if (data == null) return [];
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      throw CacheException(
        message: 'Failed to get recent searches: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Saves a search query to the recent searches list.
  ///
  /// Deduplicates and caps at 20 entries.
  Future<void> saveRecentSearch(String query) async {
    try {
      final trimmed = query.trim();
      if (trimmed.isEmpty) return;

      final recent = getRecentSearches();
      // Remove duplicate if it exists.
      recent.remove(trimmed);
      // Insert at the front.
      recent.insert(0, trimmed);
      // Cap at 20 entries.
      if (recent.length > 20) {
        recent.removeRange(20, recent.length);
      }
      await _searchBox.put(_recentSearchesKey, recent);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save recent search: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Clears the recent search history.
  Future<void> clearRecentSearches() async {
    try {
      await _searchBox.delete(_recentSearchesKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear recent searches: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Helpers
  // ═══════════════════════════════════════════════════════════════════

  DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  /// Extracts a text snippet around the first occurrence of [query]
  /// within [text]. Returns up to 120 characters for display.
  String _extractSnippet(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) return text.length > 120 ? '${text.substring(0, 120)}…' : text;

    const snippetRadius = 50;
    final start = (index - snippetRadius).clamp(0, text.length);
    final end = (index + query.length + snippetRadius).clamp(0, text.length);

    final snippet = text.substring(start, end);
    final prefix = start > 0 ? '…' : '';
    final suffix = end < text.length ? '…' : '';

    return '$prefix$snippet$suffix';
  }

  /// Calculates a simple relevance score based on how early and
  /// how frequently the query appears in the text.
  double _calculateRelevance(String query, String text) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    // Position-based scoring: earlier matches score higher.
    final position = lowerText.indexOf(lowerQuery);
    final positionScore = position <= 0
        ? 1.0
        : position < 20
            ? 0.8
            : position < 50
                ? 0.6
                : 0.4;

    // Frequency-based scoring.
    final frequency = _countOccurrences(lowerText, lowerQuery);
    final frequencyScore = (frequency / 10).clamp(0.0, 0.3);

    return (positionScore + frequencyScore).clamp(0.0, 1.0);
  }

  /// Counts non-overlapping occurrences of [pattern] in [text].
  int _countOccurrences(String text, String pattern) {
    if (pattern.isEmpty) return 0;
    int count = 0;
    int index = 0;
    while ((index = text.indexOf(pattern, index)) != -1) {
      count++;
      index += pattern.length;
    }
    return count;
  }
}
