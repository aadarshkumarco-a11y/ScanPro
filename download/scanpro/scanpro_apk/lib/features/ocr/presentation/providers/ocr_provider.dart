import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/di/app_module.dart';
import 'package:scanpro/features/ocr/data/datasources/ocr_local_datasource.dart';
import 'package:scanpro/features/ocr/data/datasources/ocr_ml_datasource.dart';
import 'package:scanpro/features/ocr/data/repositories/ocr_repository_impl.dart';
import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';
import 'package:scanpro/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:scanpro/features/ocr/domain/usecases/extract_text_regions_usecase.dart';
import 'package:scanpro/features/ocr/domain/usecases/recognize_text_usecase.dart';

// ═══════════════════════════════════════════════════════════════════
//  Repository Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the [OcrRepository] implementation.
final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  final cacheBox = ref.watch(cacheBoxProvider);
  final mlDatasource = OcrMlDatasource();
  final localDatasource = OcrLocalDatasource(cacheBox: cacheBox);
  return OcrRepositoryImpl(
    mlDatasource: mlDatasource,
    localDatasource: localDatasource,
  );
});

// ═══════════════════════════════════════════════════════════════════
//  Use Case Providers
// ═══════════════════════════════════════════════════════════════════

/// Provides the [RecognizeTextUseCase].
final recognizeTextUseCaseProvider = Provider<RecognizeTextUseCase>((ref) {
  return RecognizeTextUseCase(ref.watch(ocrRepositoryProvider));
});

/// Provides the [ExtractTextRegionsUseCase].
final extractTextRegionsUseCaseProvider =
    Provider<ExtractTextRegionsUseCase>((ref) {
  return ExtractTextRegionsUseCase(ref.watch(ocrRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════
//  OCR State
// ═══════════════════════════════════════════════════════════════════

/// Possible states for the OCR feature.
enum OcrStatus {
  idle,
  loading,
  recognizing,
  extracting,
  success,
  error,
}

/// State holder for the OCR feature.
class OcrState {
  final OcrStatus status;
  final OcrResult? currentResult;
  final List<OcrResult> results;
  final String? errorMessage;
  final String selectedLanguage;
  final String? selectedDocumentPath;
  final String? selectedDocumentId;
  final double progress;

  const OcrState({
    this.status = OcrStatus.idle,
    this.currentResult,
    this.results = const [],
    this.errorMessage,
    this.selectedLanguage = 'en',
    this.selectedDocumentPath,
    this.selectedDocumentId,
    this.progress = 0.0,
  });

  OcrState copyWith({
    OcrStatus? status,
    OcrResult? currentResult,
    List<OcrResult>? results,
    String? errorMessage,
    String? selectedLanguage,
    String? selectedDocumentPath,
    String? selectedDocumentId,
    double? progress,
  }) {
    return OcrState(
      status: status ?? this.status,
      currentResult: currentResult ?? this.currentResult,
      results: results ?? this.results,
      errorMessage: errorMessage,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedDocumentPath:
          selectedDocumentPath ?? this.selectedDocumentPath,
      selectedDocumentId: selectedDocumentId ?? this.selectedDocumentId,
      progress: progress ?? this.progress,
    );
  }
}

/// State notifier for the OCR feature.
class OcrNotifier extends StateNotifier<OcrState> {
  OcrNotifier({
    required RecognizeTextUseCase recognizeTextUseCase,
    required ExtractTextRegionsUseCase extractTextRegionsUseCase,
    required OcrRepository repository,
  })  : _recognizeTextUseCase = recognizeTextUseCase,
        _extractTextRegionsUseCase = extractTextRegionsUseCase,
        _repository = repository,
        super(const OcrState());

  final RecognizeTextUseCase _recognizeTextUseCase;
  final ExtractTextRegionsUseCase _extractTextRegionsUseCase;
  final OcrRepository _repository;

  /// Sets the selected document for OCR processing.
  void selectDocument({
    required String documentId,
    required String documentPath,
  }) {
    state = state.copyWith(
      selectedDocumentId: documentId,
      selectedDocumentPath: documentPath,
    );
  }

  /// Sets the selected OCR language.
  void setLanguage(String language) {
    state = state.copyWith(selectedLanguage: language);
  }

  /// Starts text recognition on the selected document.
  Future<void> recognizeText() async {
    if (state.selectedDocumentPath == null) {
      state = state.copyWith(
        status: OcrStatus.error,
        errorMessage: 'Please select a document first.',
      );
      return;
    }

    state = state.copyWith(
      status: OcrStatus.recognizing,
      progress: 0.2,
      errorMessage: null,
    );

    // Simulate progress
    Future.delayed(const Duration(milliseconds: 500), () {
      if (state.status == OcrStatus.recognizing) {
        state = state.copyWith(progress: 0.5);
      }
    });

    final result = await _recognizeTextUseCase(
      imagePath: state.selectedDocumentPath!,
      language: state.selectedLanguage,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OcrStatus.error,
          errorMessage: failure.message,
          progress: 0.0,
        );
      },
      (ocrResult) {
        // Update the result with the selected document ID
        final updatedResult = ocrResult.copyWith(
          documentId: state.selectedDocumentId ?? ocrResult.documentId,
        );
        state = state.copyWith(
          status: OcrStatus.success,
          currentResult: updatedResult,
          progress: 1.0,
        );
      },
    );
  }

  /// Extracts text regions from the selected document.
  Future<void> extractTextRegions() async {
    if (state.selectedDocumentPath == null) {
      state = state.copyWith(
        status: OcrStatus.error,
        errorMessage: 'Please select a document first.',
      );
      return;
    }

    state = state.copyWith(
      status: OcrStatus.extracting,
      progress: 0.2,
      errorMessage: null,
    );

    final result = await _extractTextRegionsUseCase(
      imagePath: state.selectedDocumentPath!,
      language: state.selectedLanguage,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OcrStatus.error,
          errorMessage: failure.message,
          progress: 0.0,
        );
      },
      (ocrResult) {
        final updatedResult = ocrResult.copyWith(
          documentId: state.selectedDocumentId ?? ocrResult.documentId,
        );
        state = state.copyWith(
          status: OcrStatus.success,
          currentResult: updatedResult,
          progress: 1.0,
        );
      },
    );
  }

  /// Loads all OCR results from storage.
  Future<void> loadResults() async {
    state = state.copyWith(status: OcrStatus.loading);

    final result = await _repository.getOcrResults();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OcrStatus.error,
          errorMessage: failure.message,
        );
      },
      (results) {
        state = state.copyWith(
          status: OcrStatus.idle,
          results: results,
        );
      },
    );
  }

  /// Deletes an OCR result by ID.
  Future<void> deleteResult(String ocrResultId) async {
    final result = await _repository.deleteOcrResult(ocrResultId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OcrStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        final updatedResults =
            state.results.where((r) => r.id != ocrResultId).toList();
        state = state.copyWith(results: updatedResults);
      },
    );
  }

  /// Resets the OCR state to idle.
  void reset() {
    state = const OcrState();
  }

  /// Clears the current result.
  void clearCurrentResult() {
    state = state.copyWith(
      status: OcrStatus.idle,
      currentResult: null,
      progress: 0.0,
      errorMessage: null,
    );
  }
}

/// Provider for the [OcrNotifier].
final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  return OcrNotifier(
    recognizeTextUseCase: ref.watch(recognizeTextUseCaseProvider),
    extractTextRegionsUseCase: ref.watch(extractTextRegionsUseCaseProvider),
    repository: ref.watch(ocrRepositoryProvider),
  );
});

/// Provider for the current OCR status.
final ocrStatusProvider = Provider<OcrStatus>((ref) {
  return ref.watch(ocrProvider).status;
});

/// Provider for the current OCR result.
final currentOcrResultProvider = Provider<OcrResult?>((ref) {
  return ref.watch(ocrProvider).currentResult;
});

/// Provider for OCR progress value.
final ocrProgressProvider = Provider<double>((ref) {
  return ref.watch(ocrProvider).progress;
});
