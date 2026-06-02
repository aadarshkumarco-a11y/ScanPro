import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Domain Models ──────────────────────────────────────────────

enum SearchCategory { files, ocrContent, tags, folders }

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchCategory category;
  final String matchedText;
  final String? filePath;
  final DateTime? lastModified;
  final IconData icon;

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.matchedText,
    this.filePath,
    this.lastModified,
    required this.icon,
  });
}

class SearchSuggestion {
  final String text;
  final bool isHistory;

  const SearchSuggestion({required this.text, this.isHistory = false});
}

// ── State ──────────────────────────────────────────────────────

class SearchState {
  final String query;
  final Set<SearchCategory> activeCategories;
  final List<SearchResult> results;
  final List<String> searchHistory;
  final bool isSearching;
  final String? error;

  const SearchState({
    this.query = '',
    this.activeCategories = const {
      SearchCategory.files,
      SearchCategory.ocrContent,
      SearchCategory.tags,
      SearchCategory.folders,
    },
    this.results = const [],
    this.searchHistory = const [],
    this.isSearching = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    Set<SearchCategory>? activeCategories,
    List<SearchResult>? results,
    List<String>? searchHistory,
    bool? isSearching,
    String? error,
  }) =>
      SearchState(
        query: query ?? this.query,
        activeCategories: activeCategories ?? this.activeCategories,
        results: results ?? this.results,
        searchHistory: searchHistory ?? this.searchHistory,
        isSearching: isSearching ?? this.isSearching,
        error: error,
      );
}

// ── Notifier ───────────────────────────────────────────────────

class SearchNotifier extends StateNotifier<SearchState> {
  Timer? _debounceTimer;

  SearchNotifier() : super(const SearchState());

  void updateQuery(String query) {
    state = state.copyWith(query: query);
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }
    state = state.copyWith(isSearching: true);
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  void toggleCategory(SearchCategory category) {
    final categories = {...state.activeCategories};
    if (categories.contains(category)) {
      if (categories.length > 1) categories.remove(category);
    } else {
      categories.add(category);
    }
    state = state.copyWith(activeCategories: categories);
    if (state.query.isNotEmpty) _performSearch(state.query);
  }

  void clearHistory() => state = state.copyWith(searchHistory: []);

  void removeHistoryItem(String item) {
    state = state.copyWith(
      searchHistory: state.searchHistory.where((h) => h != item).toList(),
    );
  }

  List<SearchSuggestion> getSuggestions() {
    if (state.query.isEmpty) {
      return state.searchHistory
          .take(5)
          .map((h) => SearchSuggestion(text: h, isHistory: true))
          .toList();
    }
    final suggestions = <SearchSuggestion>[];
    for (final history in state.searchHistory) {
      if (history.toLowerCase().contains(state.query.toLowerCase())) {
        suggestions.add(SearchSuggestion(text: history, isHistory: true));
      }
    }
    const commonSuggestions = [
      'invoice', 'receipt', 'contract', 'report', 'tax', 'medical',
      'insurance', 'bank statement', 'resume', 'letter', 'bill', 'warranty',
    ];
    for (final suggestion in commonSuggestions) {
      if (suggestion.toLowerCase().contains(state.query.toLowerCase()) &&
          !suggestions.any((s) => s.text == suggestion)) {
        suggestions.add(SearchSuggestion(text: suggestion, isHistory: false));
      }
    }
    return suggestions.take(8).toList();
  }

  Future<void> _performSearch(String query) async {
    state = state.copyWith(isSearching: true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final results = _mockSearch(query, state.activeCategories);
      final updatedHistory = [
        query,
        ...state.searchHistory.where((h) => h != query),
      ].take(20).toList();
      state = state.copyWith(
        results: results,
        isSearching: false,
        searchHistory: updatedHistory,
      );
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());
    }
  }

  List<SearchResult> _mockSearch(String query, Set<SearchCategory> categories) {
    final allResults = <SearchResult>[];
    final q = query.toLowerCase();

    if (categories.contains(SearchCategory.files)) {
      const fileData = [
        ('Invoice_March_2025.pdf', '/documents/invoices/', Icons.picture_as_pdf),
        ('Tax_Return_2024.pdf', '/documents/tax/', Icons.picture_as_pdf),
        ('Contract_Acme_Corp.pdf', '/documents/contracts/', Icons.picture_as_pdf),
        ('Meeting_Notes_Jan.docx', '/documents/notes/', Icons.description),
        ('Budget_Report_Q4.xlsx', '/documents/reports/', Icons.table_chart),
      ];
      for (final (name, path, icon) in fileData) {
        if (name.toLowerCase().contains(q)) {
          allResults.add(SearchResult(
            id: 'file_$name',
            title: name,
            subtitle: path,
            category: SearchCategory.files,
            matchedText: name,
            filePath: '$path$name',
            lastModified: DateTime.now().subtract(Duration(days: allResults.length + 1)),
            icon: icon,
          ));
        }
      }
    }

    if (categories.contains(SearchCategory.ocrContent)) {
      const ocrData = [
        ('Invoice #INV-2024-0892', 'Total: \$140.37 - Acme Corporation', Icons.text_fields),
        ('Insurance Policy Document', 'Policy number: INS-789456123', Icons.text_fields),
      ];
      for (final (title, content, icon) in ocrData) {
        if (title.toLowerCase().contains(q) || content.toLowerCase().contains(q)) {
          allResults.add(SearchResult(
            id: 'ocr_$title',
            title: title,
            subtitle: content,
            category: SearchCategory.ocrContent,
            matchedText: content,
            lastModified: DateTime.now().subtract(Duration(days: allResults.length + 3)),
            icon: icon,
          ));
        }
      }
    }

    if (categories.contains(SearchCategory.tags)) {
      const tagData = [
        ('invoice', '3 documents', Icons.label),
        ('tax', '2 documents', Icons.label),
        ('contract', '1 document', Icons.label),
        ('important', '5 documents', Icons.label),
      ];
      for (final (tag, count, icon) in tagData) {
        if (tag.toLowerCase().contains(q)) {
          allResults.add(SearchResult(
            id: 'tag_$tag',
            title: '#$tag',
            subtitle: count,
            category: SearchCategory.tags,
            matchedText: tag,
            icon: icon,
          ));
        }
      }
    }

    if (categories.contains(SearchCategory.folders)) {
      const folderData = [
        ('Invoices', '12 items', Icons.folder),
        ('Tax Documents', '8 items', Icons.folder),
        ('Contracts', '5 items', Icons.folder),
        ('Medical Records', '3 items', Icons.folder),
      ];
      for (final (name, count, icon) in folderData) {
        if (name.toLowerCase().contains(q)) {
          allResults.add(SearchResult(
            id: 'folder_$name',
            title: name,
            subtitle: count,
            category: SearchCategory.folders,
            matchedText: name,
            icon: icon,
          ));
        }
      }
    }

    return allResults;
  }
}

// ── Providers ──────────────────────────────────────────────────

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(),
);

final searchQueryProvider = Provider<String>(
  (ref) => ref.watch(searchProvider).query,
);

final searchResultsProvider = Provider<List<SearchResult>>(
  (ref) => ref.watch(searchProvider).results,
);

final searchHistoryProvider = Provider<List<String>>(
  (ref) => ref.watch(searchProvider).searchHistory,
);

final recentSearchesProvider = Provider<List<String>>((ref) {
  return ref.watch(searchHistoryProvider).take(5).toList();
});
