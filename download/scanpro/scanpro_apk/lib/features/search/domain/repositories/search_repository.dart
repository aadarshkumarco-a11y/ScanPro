import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/search/domain/entities/search_result.dart';

/// Abstract repository contract for search operations.
///
/// Defines the domain-level API for searching documents, OCR text,
/// and tags. Implementations must convert data-layer exceptions
/// into [Failure]s.
abstract class SearchRepository {
  /// Performs a full-text search across documents, OCR text, and tags.
  ///
  /// Returns results ordered by relevance, or a [Failure] on error.
  Future<Either<Failure, List<SearchResult>>> search(String query);

  /// Searches documents that have a specific tag.
  Future<Either<Failure, List<SearchResult>>> searchByTag(String tag);

  /// Searches OCR-extracted text content.
  Future<Either<Failure, List<SearchResult>>> searchByOcrText(String query);

  /// Retrieves recent search queries for autocomplete.
  Future<Either<Failure, List<String>>> getRecentSearches();

  /// Clears the recent search history.
  Future<Either<Failure, Unit>> clearRecentSearches();

  /// Saves a search query to recent search history.
  Future<Either<Failure, Unit>> saveRecentSearch(String query);
}
