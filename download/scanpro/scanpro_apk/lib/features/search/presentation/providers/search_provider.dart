import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/di/app_module.dart';
import 'package:scanpro/features/search/data/datasources/search_local_datasource.dart';
import 'package:scanpro/features/search/data/repositories/search_repository_impl.dart';
import 'package:scanpro/features/search/domain/entities/search_result.dart';
import 'package:scanpro/features/search/domain/repositories/search_repository.dart';

// ═══════════════════════════════════════════════════════════════════
//  Repository Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the [SearchRepository] implementation.
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final searchBox = ref.watch(searchBoxProvider);
  final documentsBox = ref.watch(documentsBoxProvider);

  final localDatasource = SearchLocalDatasource(
    searchBox: searchBox,
    documentsBox: documentsBox,
  );

  return SearchRepositoryImpl(localDatasource: localDatasource);
});

// ═══════════════════════════════════════════════════════════════════
//  Search State
// ═══════════════════════════════════════════════════════════════════

/// Possible load states for the search feature.
enum SearchStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Tab filter for search results.
enum SearchTab {
  all,
  documents,
  ocrText,
  tags,
}

/// State holder for the search feature.
class SearchState {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results = const [],
    this.recentSearches = const [],
    this.selectedTab = SearchTab.all,
    this.errorMessage,
  });

  final SearchStatus status;
  final String query;
  final List<SearchResult> results;
  final List<String> recentSearches;
  final SearchTab selectedTab;
  final String? errorMessage;

  /// Results filtered by the selected tab.
  List<SearchResult> get filteredResults {
    switch (selectedTab) {
      case SearchTab.all:
        return results;
      case SearchTab.documents:
        return results
            .where((r) => r.type == SearchResultType.document)
            .toList();
      case SearchTab.ocrText:
        return results
            .where((r) => r.type == SearchResultType.ocrText)
            .toList();
      case SearchTab.tags:
        return results
            .where((r) => r.type == SearchResultType.tag)
            .toList();
    }
  }

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<SearchResult>? results,
    List<String>? recentSearches,
    SearchTab? selectedTab,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      selectedTab: selectedTab ?? this.selectedTab,
      errorMessage: errorMessage,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Search Notifier
// ═══════════════════════════════════════════════════════════════════

/// State notifier for the search feature.
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier({required SearchRepository repository})
      : _repository = repository,
        super(const SearchState());

  final SearchRepository _repository;

  /// Loads recent searches from storage.
  Future<void> loadRecentSearches() async {
    final result = await _repository.getRecentSearches();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (searches) => state = state.copyWith(recentSearches: searches),
    );
  }

  /// Performs a search with the given [query].
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        status: SearchStatus.initial,
        query: '',
        results: [],
      );
      return;
    }

    state = state.copyWith(
      status: SearchStatus.loading,
      query: trimmed,
    );

    final result = await _repository.search(trimmed);
    result.fold(
      (failure) => state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: failure.message,
      ),
      (results) {
        state = state.copyWith(
          status: SearchStatus.loaded,
          results: results,
        );
        // Save the query to recent searches.
        _repository.saveRecentSearch(trimmed);
        // Refresh recent searches list.
        loadRecentSearches();
      },
    );
  }

  /// Changes the selected tab filter.
  void setTab(SearchTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  /// Clears the current search results.
  void clearSearch() {
    state = state.copyWith(
      status: SearchStatus.initial,
      query: '',
      results: [],
      selectedTab: SearchTab.all,
    );
  }

  /// Clears the recent search history.
  Future<void> clearRecentSearches() async {
    final result = await _repository.clearRecentSearches();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) => state = state.copyWith(recentSearches: []),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Provider
// ═══════════════════════════════════════════════════════════════════

/// Provider for the [SearchNotifier].
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(
    repository: ref.watch(searchRepositoryProvider),
  );
});
