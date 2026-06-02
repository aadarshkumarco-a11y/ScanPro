import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/routing/app_router.dart';

// ═══════════════════════════════════════════════════════════════════
//  Core Infrastructure Providers
// ═══════════════════════════════════════════════════════════════════

/// Provides the [SharedPreferences] singleton.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

/// Provides the application documents directory.
final appDirProvider = Provider<Directory>((ref) {
  throw UnimplementedError(
    'appDirProvider must be overridden in main()',
  );
});

/// Provides the temporary directory.
final tempDirProvider = Provider<Directory>((ref) {
  throw UnimplementedError(
    'tempDirProvider must be overridden in main()',
  );
});

/// Whether the device currently has network connectivity.
/// Always returns true since connectivity_plus was removed.
final isOnlineProvider = Provider<bool>((ref) {
  return true;
});

// ═══════════════════════════════════════════════════════════════════
//  Hive Box Providers
// ═══════════════════════════════════════════════════════════════════

/// Opens and provides the documents Hive box.
final documentsBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'documentsBoxProvider must be overridden in main() after Hive.init()',
  );
});

/// Opens and provides the folders Hive box.
final foldersBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'foldersBoxProvider must be overridden in main()',
  );
});

/// Opens and provides the tags Hive box.
final tagsBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'tagsBoxProvider must be overridden in main()',
  );
});

/// Opens and provides the sync records Hive box.
final syncRecordsBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'syncRecordsBoxProvider must be overridden in main()',
  );
});

/// Opens and provides the signatures Hive box.
final signaturesBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'signaturesBoxProvider must be overridden in main()',
  );
});

/// Opens and provides the settings Hive box.
final settingsBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'settingsBoxProvider must be overridden in main()',
  );
});

/// Opens and provides the cache Hive box.
final cacheBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'cacheBoxProvider must be overridden in main()',
  );
});

/// Opens and provides the annotations Hive box.
final annotationsBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'annotationsBoxProvider must be overridden in main()',
  );
});

/// Opens and provides the search Hive box.
final searchBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'searchBoxProvider must be overridden in main()',
  );
});

/// Opens and provides the QR results Hive box.
final qrResultsBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'qrResultsBoxProvider must be overridden in main()',
  );
});

// ═══════════════════════════════════════════════════════════════════
//  Theme Mode Provider
// ═══════════════════════════════════════════════════════════════════

/// Notifier that persists the selected [ThemeMode] across restarts.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs) : super(ThemeMode.system);

  final SharedPreferences _prefs;

  /// Initialise from persisted value.  Call once after construction.
  void init() {
    final saved = _prefs.getString(AppConstants.prefsThemeModeKey);
    switch (saved) {
      case 'light':
        state = ThemeMode.light;
      case 'dark':
        state = ThemeMode.dark;
      default:
        state = ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _prefs.setString(AppConstants.prefsThemeModeKey, mode.name);
  }

  void toggle() {
    setThemeMode(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}

/// Provider for the current [ThemeMode] with persistence.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final notifier = ThemeModeNotifier(prefs);
  notifier.init();
  return notifier;
});

// ═══════════════════════════════════════════════════════════════════
//  Onboarding Provider
// ═══════════════════════════════════════════════════════════════════

/// Whether the onboarding flow has been completed.
final onboardingCompleteProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.prefsOnboardingCompleteKey) ?? false;
});

// ═══════════════════════════════════════════════════════════════════
//  First Launch Provider
// ═══════════════════════════════════════════════════════════════════

/// Whether this is the first time the app has been launched.
final isFirstLaunchProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final isFirst = prefs.getBool(AppConstants.prefsFirstLaunchKey) ?? true;
  if (isFirst) {
    Future.microtask(() {
      prefs.setBool(AppConstants.prefsFirstLaunchKey, false);
    });
  }
  return isFirst;
});

// ═══════════════════════════════════════════════════════════════════
//  Security / Lock State Providers
// ═══════════════════════════════════════════════════════════════════

/// Whether the app is currently locked (requires PIN / biometric).
final isAppLockedProvider = StateProvider<bool>((ref) => false);

/// Whether the user has set up a PIN.
final isPinSetUpProvider = Provider<bool>((ref) {
  // This will be replaced with a proper check from secure storage
  // once the security feature module is wired in.
  return false;
});

/// Whether the user is authenticated (for route guarding).
final isAuthenticatedProvider = StateProvider<bool>((ref) => true);

// ═══════════════════════════════════════════════════════════════════
//  Scanner Module Providers (placeholder – to be expanded)
// ═══════════════════════════════════════════════════════════════════

/// Whether the scanner is currently active / capturing.
final scannerActiveProvider = StateProvider<bool>((ref) => false);

/// The number of pages scanned in the current batch.
final batchScanCountProvider = StateProvider<int>((ref) => 0);

// ═══════════════════════════════════════════════════════════════════
//  OCR Module Providers (placeholder – to be expanded)
// ═══════════════════════════════════════════════════════════════════

/// The currently selected OCR language.
final ocrLanguageProvider = StateProvider<String>((ref) => 'en');

// ═══════════════════════════════════════════════════════════════════
//  PDF Module Providers (placeholder – to be expanded)
// ═══════════════════════════════════════════════════════════════════

/// The selected PDF compression quality level (0.0 – 1.0).
final pdfCompressionQualityProvider = StateProvider<double>(
  (ref) => AppConstants.pdfCompressionQualityHigh,
);

// ═══════════════════════════════════════════════════════════════════
//  AI Module Providers (placeholder – to be expanded)
// ═══════════════════════════════════════════════════════════════════

/// Maximum words for AI summaries.
final aiSummaryMaxWordsProvider = StateProvider<int>(
  (ref) => AppConstants.aiSummaryMaxWordsDefault,
);

// ═══════════════════════════════════════════════════════════════════
//  Sync Module Providers (placeholder – to be expanded)
// ═══════════════════════════════════════════════════════════════════

/// Whether auto-sync is enabled.
final autoSyncEnabledProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.prefsAutoSyncKey) ?? true;
});

/// Whether to sync only on Wi-Fi.
final wifiOnlySyncProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.prefsWifiOnlySyncKey) ?? false;
});

/// Timestamp of the last successful sync.
final lastSyncTimestampProvider = StateProvider<DateTime?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final millis = prefs.getInt(AppConstants.prefsLastSyncKey);
  if (millis == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(millis);
});

// ═══════════════════════════════════════════════════════════════════
//  Document Module Providers (placeholder – to be expanded)
// ═══════════════════════════════════════════════════════════════════

/// Current sort field for documents.
enum DocumentSortField { name, date, size, category }

/// Current sort order.
enum SortOrder { ascending, descending }

/// Current document filter.
enum DocumentFilter { all, pdf, image, ocr, favorites }

/// State holder for document list sorting and filtering.
class SortFilterState {
  final DocumentSortField sortField;
  final SortOrder sortOrder;
  final DocumentFilter filter;
  final String searchQuery;

  const SortFilterState({
    this.sortField = DocumentSortField.date,
    this.sortOrder = SortOrder.descending,
    this.filter = DocumentFilter.all,
    this.searchQuery = '',
  });

  SortFilterState copyWith({
    DocumentSortField? sortField,
    SortOrder? sortOrder,
    DocumentFilter? filter,
    String? searchQuery,
  }) {
    return SortFilterState(
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier for document sort / filter / search state.
class SortFilterNotifier extends StateNotifier<SortFilterState> {
  SortFilterNotifier() : super(const SortFilterState());

  void setSortField(DocumentSortField field) {
    state = state.copyWith(sortField: field);
  }

  void toggleSortOrder() {
    state = state.copyWith(
      sortOrder: state.sortOrder == SortOrder.ascending
          ? SortOrder.descending
          : SortOrder.ascending,
    );
  }

  void setFilter(DocumentFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reset() {
    state = const SortFilterState();
  }
}

/// Provider for document sort / filter state.
final sortFilterProvider =
    StateNotifierProvider<SortFilterNotifier, SortFilterState>(
  (ref) => SortFilterNotifier(),
);

/// Whether documents are displayed in grid layout (vs list).
final isGridViewProvider = StateProvider<bool>((ref) => true);

// ═══════════════════════════════════════════════════════════════════
//  Initialisation Helper
// ═══════════════════════════════════════════════════════════════════

/// Initializes all core services and returns an [ProviderContainer]
/// with the necessary overrides already applied.
///
/// Call once in `main()` before `runApp()`.
Future<ProviderContainer> initializeApp() async {
  // Ensure Flutter bindings are ready.
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences.
  final prefs = await SharedPreferences.getInstance();

  // Directories.
  final appDir = await getApplicationDocumentsDirectory();
  final tempDir = await getTemporaryDirectory();

  // Hive.
  Hive.init(appDir.path);
  final documentsBox = await Hive.openBox(AppConstants.documentsBox);
  final foldersBox = await Hive.openBox(AppConstants.foldersBox);
  final tagsBox = await Hive.openBox(AppConstants.tagsBox);
  final syncRecordsBox = await Hive.openBox(AppConstants.syncRecordsBox);
  final signaturesBox = await Hive.openBox(AppConstants.signaturesBox);
  final settingsBox = await Hive.openBox(AppConstants.settingsBox);
  final cacheBox = await Hive.openBox(AppConstants.cacheBox);
  final annotationsBox = await Hive.openBox(AppConstants.annotationsBox);
  final searchBox = await Hive.openBox(AppConstants.searchBox);
  final qrResultsBox = await Hive.openBox(AppConstants.qrResultsBox);

  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDirProvider.overrideWithValue(appDir),
      tempDirProvider.overrideWithValue(tempDir),
      documentsBoxProvider.overrideWithValue(documentsBox),
      foldersBoxProvider.overrideWithValue(foldersBox),
      tagsBoxProvider.overrideWithValue(tagsBox),
      syncRecordsBoxProvider.overrideWithValue(syncRecordsBox),
      signaturesBoxProvider.overrideWithValue(signaturesBox),
      settingsBoxProvider.overrideWithValue(settingsBox),
      cacheBoxProvider.overrideWithValue(cacheBox),
      annotationsBoxProvider.overrideWithValue(annotationsBox),
      searchBoxProvider.overrideWithValue(searchBox),
      qrResultsBoxProvider.overrideWithValue(qrResultsBox),
    ],
  );
}
