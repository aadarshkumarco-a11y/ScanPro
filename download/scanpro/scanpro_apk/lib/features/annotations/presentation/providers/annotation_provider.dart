import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/di/app_module.dart';
import 'package:scanpro/features/annotations/data/datasources/annotation_local_datasource.dart';
import 'package:scanpro/features/annotations/data/repositories/annotation_repository_impl.dart';
import 'package:scanpro/features/annotations/domain/entities/annotation.dart';
import 'package:scanpro/features/annotations/domain/repositories/annotation_repository.dart';
import 'package:scanpro/features/annotations/domain/usecases/add_annotation_usecase.dart';
import 'package:scanpro/features/annotations/domain/usecases/get_annotations_usecase.dart';

// Note: [annotationsBoxProvider] is defined in lib/di/app_module.dart
// and is imported via the scanpro/di/app_module.dart import above.

// ═══════════════════════════════════════════════════════════════════
//  Repository Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the [AnnotationRepository] implementation.
final annotationRepositoryProvider = Provider<AnnotationRepository>((ref) {
  final annotationsBox = ref.watch(annotationsBoxProvider);
  final localDatasource = AnnotationLocalDatasource(
    annotationsBox: annotationsBox,
  );
  return AnnotationRepositoryImpl(localDatasource: localDatasource);
});

// ═══════════════════════════════════════════════════════════════════
//  Use Case Providers
// ═══════════════════════════════════════════════════════════════════

/// Provides the [AddAnnotationUseCase].
final addAnnotationUseCaseProvider = Provider<AddAnnotationUseCase>((ref) {
  return AddAnnotationUseCase(ref.watch(annotationRepositoryProvider));
});

/// Provides the [GetAnnotationsUseCase].
final getAnnotationsUseCaseProvider = Provider<GetAnnotationsUseCase>((ref) {
  return GetAnnotationsUseCase(ref.watch(annotationRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════
//  Annotation State
// ═══════════════════════════════════════════════════════════════════

/// Possible states for annotation operations.
enum AnnotationStatus {
  idle,
  loading,
  success,
  error,
}

/// State holder for the annotation feature.
class AnnotationState {
  final AnnotationStatus status;
  final List<Annotation> annotations;
  final String? errorMessage;
  final AnnotationType? selectedTool;
  final int? selectedPage;

  const AnnotationState({
    this.status = AnnotationStatus.idle,
    this.annotations = const [],
    this.errorMessage,
    this.selectedTool,
    this.selectedPage,
  });

  AnnotationState copyWith({
    AnnotationStatus? status,
    List<Annotation>? annotations,
    String? errorMessage,
    AnnotationType? selectedTool,
    int? selectedPage,
  }) {
    return AnnotationState(
      status: status ?? this.status,
      annotations: annotations ?? this.annotations,
      errorMessage: errorMessage,
      selectedTool: selectedTool ?? this.selectedTool,
      selectedPage: selectedPage ?? this.selectedPage,
    );
  }

  /// Annotations filtered by the current selected tool type.
  List<Annotation> get filteredAnnotations {
    if (selectedTool == null) return annotations;
    return annotations.where((a) => a.type == selectedTool).toList();
  }

  /// Annotations for a specific page.
  List<Annotation> annotationsForPage(int page) {
    return annotations.where((a) => a.page == page).toList();
  }

  /// Count of annotations by type.
  int countByType(AnnotationType type) {
    return annotations.where((a) => a.type == type).length;
  }
}

/// State notifier for the annotation feature.
class AnnotationNotifier extends StateNotifier<AnnotationState> {
  AnnotationNotifier({
    required AnnotationRepository repository,
    required AddAnnotationUseCase addAnnotationUseCase,
    required GetAnnotationsUseCase getAnnotationsUseCase,
  })  : _repository = repository,
        _addAnnotationUseCase = addAnnotationUseCase,
        _getAnnotationsUseCase = getAnnotationsUseCase,
        super(const AnnotationState());

  final AnnotationRepository _repository;
  final AddAnnotationUseCase _addAnnotationUseCase;
  final GetAnnotationsUseCase _getAnnotationsUseCase;

  /// Loads all annotations for a given document.
  Future<void> loadAnnotations(String documentId) async {
    state = state.copyWith(status: AnnotationStatus.loading);

    final result = await _getAnnotationsUseCase.getByDocument(documentId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AnnotationStatus.error,
          errorMessage: failure.message,
        );
      },
      (annotations) {
        state = state.copyWith(
          status: AnnotationStatus.success,
          annotations: annotations,
        );
      },
    );
  }

  /// Adds a new annotation.
  Future<bool> addAnnotation(Annotation annotation) async {
    state = state.copyWith(status: AnnotationStatus.loading);

    final result = await _addAnnotationUseCase(annotation);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AnnotationStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (savedAnnotation) {
        state = state.copyWith(
          status: AnnotationStatus.success,
          annotations: [...state.annotations, savedAnnotation],
        );
        return true;
      },
    );
  }

  /// Updates an existing annotation.
  Future<bool> updateAnnotation(Annotation annotation) async {
    state = state.copyWith(status: AnnotationStatus.loading);

    final result = await _repository.updateAnnotation(annotation);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AnnotationStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedAnnotation) {
        final updatedList = state.annotations
            .map((a) => a.id == updatedAnnotation.id ? updatedAnnotation : a)
            .toList();
        state = state.copyWith(
          status: AnnotationStatus.success,
          annotations: updatedList,
        );
        return true;
      },
    );
  }

  /// Deletes an annotation by ID.
  Future<void> deleteAnnotation(String annotationId) async {
    final result = await _repository.deleteAnnotation(annotationId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AnnotationStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: AnnotationStatus.success,
          annotations: state.annotations
              .where((a) => a.id != annotationId)
              .toList(),
        );
      },
    );
  }

  /// Selects an annotation tool.
  void selectTool(AnnotationType? type) {
    state = state.copyWith(selectedTool: type);
  }

  /// Selects a page for viewing annotations.
  void selectPage(int page) {
    state = state.copyWith(selectedPage: page);
  }

  /// Clears any error message.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for the [AnnotationNotifier].
final annotationProvider =
    StateNotifierProvider<AnnotationNotifier, AnnotationState>((ref) {
  return AnnotationNotifier(
    repository: ref.watch(annotationRepositoryProvider),
    addAnnotationUseCase: ref.watch(addAnnotationUseCaseProvider),
    getAnnotationsUseCase: ref.watch(getAnnotationsUseCaseProvider),
  );
});
