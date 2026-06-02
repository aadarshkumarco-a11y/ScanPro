import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/di/app_module.dart';
import 'package:scanpro/features/ai_features/data/datasources/ai_local_datasource.dart';
import 'package:scanpro/features/ai_features/data/datasources/ai_remote_datasource.dart';
import 'package:scanpro/features/ai_features/data/repositories/ai_repository_impl.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_result.dart';
import 'package:scanpro/features/ai_features/domain/repositories/ai_repository.dart';
import 'package:scanpro/features/ai_features/domain/usecases/categorize_document_usecase.dart';
import 'package:scanpro/features/ai_features/domain/usecases/extract_key_info_usecase.dart';
import 'package:scanpro/features/ai_features/domain/usecases/smart_rename_usecase.dart';
import 'package:scanpro/features/ai_features/domain/usecases/summarize_document_usecase.dart';

// ═══════════════════════════════════════════════════════════════════
//  Repository Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the [AiRepository] implementation.
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final cacheBox = ref.watch(cacheBoxProvider);
  final remoteDatasource = AiRemoteDatasource();
  final localDatasource = AiLocalDatasource(cacheBox: cacheBox);
  return AiRepositoryImpl(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
  );
});

// ═══════════════════════════════════════════════════════════════════
//  Use Case Providers
// ═══════════════════════════════════════════════════════════════════

/// Provides the [SummarizeDocumentUseCase].
final summarizeDocumentUseCaseProvider = Provider<SummarizeDocumentUseCase>(
  (ref) => SummarizeDocumentUseCase(ref.watch(aiRepositoryProvider)),
);

/// Provides the [CategorizeDocumentUseCase].
final categorizeDocumentUseCaseProvider = Provider<CategorizeDocumentUseCase>(
  (ref) => CategorizeDocumentUseCase(ref.watch(aiRepositoryProvider)),
);

/// Provides the [SmartRenameUseCase].
final smartRenameUseCaseProvider = Provider<SmartRenameUseCase>(
  (ref) => SmartRenameUseCase(ref.watch(aiRepositoryProvider)),
);

/// Provides the [ExtractKeyInfoUseCase].
final extractKeyInfoUseCaseProvider = Provider<ExtractKeyInfoUseCase>(
  (ref) => ExtractKeyInfoUseCase(ref.watch(aiRepositoryProvider)),
);

// ═══════════════════════════════════════════════════════════════════
//  AI State
// ═══════════════════════════════════════════════════════════════════

/// Possible states for AI operations.
enum AiStatus {
  idle,
  loading,
  success,
  error,
}

/// State holder for the AI features.
class AiState {
  final AiStatus status;
  final AiResult? currentResult;
  final List<AiResult> results;
  final String? errorMessage;
  final AiFeatureType? activeFeature;

  const AiState({
    this.status = AiStatus.idle,
    this.currentResult,
    this.results = const [],
    this.errorMessage,
    this.activeFeature,
  });

  AiState copyWith({
    AiStatus? status,
    AiResult? currentResult,
    List<AiResult>? results,
    String? errorMessage,
    AiFeatureType? activeFeature,
  }) {
    return AiState(
      status: status ?? this.status,
      currentResult: currentResult ?? this.currentResult,
      results: results ?? this.results,
      errorMessage: errorMessage,
      activeFeature: activeFeature ?? this.activeFeature,
    );
  }
}

/// State notifier for the AI features.
class AiNotifier extends StateNotifier<AiState> {
  AiNotifier({
    required AiRepository repository,
    required SummarizeDocumentUseCase summarizeUseCase,
    required CategorizeDocumentUseCase categorizeUseCase,
    required SmartRenameUseCase smartRenameUseCase,
    required ExtractKeyInfoUseCase extractKeyInfoUseCase,
  })  : _repository = repository,
        _summarizeUseCase = summarizeUseCase,
        _categorizeUseCase = categorizeUseCase,
        _smartRenameUseCase = smartRenameUseCase,
        _extractKeyInfoUseCase = extractKeyInfoUseCase,
        super(const AiState());

  final AiRepository _repository;
  final SummarizeDocumentUseCase _summarizeUseCase;
  final CategorizeDocumentUseCase _categorizeUseCase;
  final SmartRenameUseCase _smartRenameUseCase;
  final ExtractKeyInfoUseCase _extractKeyInfoUseCase;

  /// Loads cached AI results.
  Future<void> loadResults({AiFeatureType? type}) async {
    final result = await _repository.getAiResults(type: type);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AiStatus.error,
          errorMessage: failure.message,
        );
      },
      (results) {
        state = state.copyWith(
          status: AiStatus.success,
          results: results,
        );
      },
    );
  }

  /// Summarizes a document.
  Future<void> summarizeDocument({
    required String text,
    String? documentId,
    int maxWords = 200,
  }) async {
    state = state.copyWith(
      status: AiStatus.loading,
      activeFeature: AiFeatureType.summary,
      errorMessage: null,
    );

    final result = await _summarizeUseCase(
      text: text,
      documentId: documentId,
      maxWords: maxWords,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AiStatus.error,
          errorMessage: failure.message,
        );
      },
      (aiResult) {
        state = state.copyWith(
          status: AiStatus.success,
          currentResult: aiResult,
          results: [aiResult, ...state.results],
        );
      },
    );
  }

  /// Categorizes a document.
  Future<void> categorizeDocument({
    required String text,
    String? documentId,
  }) async {
    state = state.copyWith(
      status: AiStatus.loading,
      activeFeature: AiFeatureType.categorize,
      errorMessage: null,
    );

    final result = await _categorizeUseCase(
      text: text,
      documentId: documentId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AiStatus.error,
          errorMessage: failure.message,
        );
      },
      (aiResult) {
        state = state.copyWith(
          status: AiStatus.success,
          currentResult: aiResult,
          results: [aiResult, ...state.results],
        );
      },
    );
  }

  /// Generates smart rename suggestions.
  Future<void> smartRename({
    required String text,
    required String currentName,
    String? documentId,
  }) async {
    state = state.copyWith(
      status: AiStatus.loading,
      activeFeature: AiFeatureType.rename,
      errorMessage: null,
    );

    final result = await _smartRenameUseCase(
      text: text,
      currentName: currentName,
      documentId: documentId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AiStatus.error,
          errorMessage: failure.message,
        );
      },
      (aiResult) {
        state = state.copyWith(
          status: AiStatus.success,
          currentResult: aiResult,
          results: [aiResult, ...state.results],
        );
      },
    );
  }

  /// Extracts key information from a document.
  Future<void> extractKeyInfo({
    required String text,
    String? documentId,
  }) async {
    state = state.copyWith(
      status: AiStatus.loading,
      activeFeature: AiFeatureType.extract,
      errorMessage: null,
    );

    final result = await _extractKeyInfoUseCase(
      text: text,
      documentId: documentId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AiStatus.error,
          errorMessage: failure.message,
        );
      },
      (aiResult) {
        state = state.copyWith(
          status: AiStatus.success,
          currentResult: aiResult,
          results: [aiResult, ...state.results],
        );
      },
    );
  }

  /// Clears the current result and error.
  void clearResult() {
    state = state.copyWith(
      currentResult: null,
      errorMessage: null,
      status: AiStatus.idle,
      activeFeature: null,
    );
  }
}

/// Provider for the [AiNotifier].
final aiProvider = StateNotifierProvider<AiNotifier, AiState>((ref) {
  return AiNotifier(
    repository: ref.watch(aiRepositoryProvider),
    summarizeUseCase: ref.watch(summarizeDocumentUseCaseProvider),
    categorizeUseCase: ref.watch(categorizeDocumentUseCaseProvider),
    smartRenameUseCase: ref.watch(smartRenameUseCaseProvider),
    extractKeyInfoUseCase: ref.watch(extractKeyInfoUseCaseProvider),
  );
});
