import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/di/app_module.dart';
import 'package:scanpro/features/pdf_tools/data/datasources/pdf_local_datasource.dart';
import 'package:scanpro/features/pdf_tools/data/repositories/pdf_repository_impl.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_document.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_operation.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';
import 'package:scanpro/features/pdf_tools/domain/usecases/compress_pdf_usecase.dart';
import 'package:scanpro/features/pdf_tools/domain/usecases/create_pdf_usecase.dart';
import 'package:scanpro/features/pdf_tools/domain/usecases/merge_pdf_usecase.dart';
import 'package:scanpro/features/pdf_tools/domain/usecases/split_pdf_usecase.dart';

// ═══════════════════════════════════════════════════════════════════
//  Repository Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the [PdfRepository] implementation.
final pdfRepositoryProvider = Provider<PdfRepository>((ref) {
  final cacheBox = ref.watch(cacheBoxProvider);
  final localDatasource = PdfLocalDatasource(cacheBox: cacheBox);
  return PdfRepositoryImpl(localDatasource: localDatasource);
});

// ═══════════════════════════════════════════════════════════════════
//  Use Case Providers
// ═══════════════════════════════════════════════════════════════════

/// Provides the [CreatePdfUseCase].
final createPdfUseCaseProvider = Provider<CreatePdfUseCase>((ref) {
  return CreatePdfUseCase(ref.watch(pdfRepositoryProvider));
});

/// Provides the [MergePdfUseCase].
final mergePdfUseCaseProvider = Provider<MergePdfUseCase>((ref) {
  return MergePdfUseCase(ref.watch(pdfRepositoryProvider));
});

/// Provides the [SplitPdfUseCase].
final splitPdfUseCaseProvider = Provider<SplitPdfUseCase>((ref) {
  return SplitPdfUseCase(ref.watch(pdfRepositoryProvider));
});

/// Provides the [CompressPdfUseCase].
final compressPdfUseCaseProvider = Provider<CompressPdfUseCase>((ref) {
  return CompressPdfUseCase(ref.watch(pdfRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════
//  PDF Tools State
// ═══════════════════════════════════════════════════════════════════

/// Possible states for PDF operations.
enum PdfStatus {
  idle,
  loading,
  creating,
  merging,
  splitting,
  compressing,
  watermarking,
  protecting,
  success,
  error,
}

/// State holder for the PDF tools feature.
class PdfState {
  final PdfStatus status;
  final PdfDocument? currentDocument;
  final List<PdfDocument> documents;
  final List<PdfOperationResult> operationResults;
  final String? errorMessage;
  final double progress;

  // Create PDF state
  final List<String> selectedImagePaths;

  // Merge PDF state
  final List<String> selectedPdfPaths;

  // Split PDF state
  final String? splitPdfPath;
  final List<String> pageRanges;

  // Compress PDF state
  final String? compressPdfPath;
  final double compressionQuality;

  // Watermark state
  final String? watermarkPdfPath;
  final String watermarkText;

  // Password state
  final String? protectPdfPath;
  final String protectPassword;

  const PdfState({
    this.status = PdfStatus.idle,
    this.currentDocument,
    this.documents = const [],
    this.operationResults = const [],
    this.errorMessage,
    this.progress = 0.0,
    this.selectedImagePaths = const [],
    this.selectedPdfPaths = const [],
    this.splitPdfPath,
    this.pageRanges = const [],
    this.compressPdfPath,
    this.compressionQuality = 0.6,
    this.watermarkPdfPath,
    this.watermarkText = '',
    this.protectPdfPath,
    this.protectPassword = '',
  });

  PdfState copyWith({
    PdfStatus? status,
    PdfDocument? currentDocument,
    List<PdfDocument>? documents,
    List<PdfOperationResult>? operationResults,
    String? errorMessage,
    double? progress,
    List<String>? selectedImagePaths,
    List<String>? selectedPdfPaths,
    String? splitPdfPath,
    List<String>? pageRanges,
    String? compressPdfPath,
    double? compressionQuality,
    String? watermarkPdfPath,
    String? watermarkText,
    String? protectPdfPath,
    String? protectPassword,
  }) {
    return PdfState(
      status: status ?? this.status,
      currentDocument: currentDocument ?? this.currentDocument,
      documents: documents ?? this.documents,
      operationResults: operationResults ?? this.operationResults,
      errorMessage: errorMessage,
      progress: progress ?? this.progress,
      selectedImagePaths: selectedImagePaths ?? this.selectedImagePaths,
      selectedPdfPaths: selectedPdfPaths ?? this.selectedPdfPaths,
      splitPdfPath: splitPdfPath ?? this.splitPdfPath,
      pageRanges: pageRanges ?? this.pageRanges,
      compressPdfPath: compressPdfPath ?? this.compressPdfPath,
      compressionQuality: compressionQuality ?? this.compressionQuality,
      watermarkPdfPath: watermarkPdfPath ?? this.watermarkPdfPath,
      watermarkText: watermarkText ?? this.watermarkText,
      protectPdfPath: protectPdfPath ?? this.protectPdfPath,
      protectPassword: protectPassword ?? this.protectPassword,
    );
  }
}

/// State notifier for the PDF tools feature.
class PdfNotifier extends StateNotifier<PdfState> {
  PdfNotifier({
    required CreatePdfUseCase createPdfUseCase,
    required MergePdfUseCase mergePdfUseCase,
    required SplitPdfUseCase splitPdfUseCase,
    required CompressPdfUseCase compressPdfUseCase,
    required PdfRepository repository,
  })  : _createPdfUseCase = createPdfUseCase,
        _mergePdfUseCase = mergePdfUseCase,
        _splitPdfUseCase = splitPdfUseCase,
        _compressPdfUseCase = compressPdfUseCase,
        _repository = repository,
        super(const PdfState());

  final CreatePdfUseCase _createPdfUseCase;
  final MergePdfUseCase _mergePdfUseCase;
  final SplitPdfUseCase _splitPdfUseCase;
  final CompressPdfUseCase _compressPdfUseCase;
  final PdfRepository _repository;

  // ── Create PDF ──────────────────────────────────────────────────

  /// Adds an image path to the create PDF list.
  void addImage(String imagePath) {
    final updated = [...state.selectedImagePaths, imagePath];
    state = state.copyWith(selectedImagePaths: updated);
  }

  /// Removes an image path from the create PDF list.
  void removeImage(int index) {
    final updated = [...state.selectedImagePaths]..removeAt(index);
    state = state.copyWith(selectedImagePaths: updated);
  }

  /// Reorders images in the create PDF list.
  void reorderImages(int oldIndex, int newIndex) {
    final updated = [...state.selectedImagePaths];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    state = state.copyWith(selectedImagePaths: updated);
  }

  /// Creates a PDF from the selected images.
  Future<void> createPdf({String fileName = 'ScanPro_Document'}) async {
    if (state.selectedImagePaths.isEmpty) {
      state = state.copyWith(
        status: PdfStatus.error,
        errorMessage: 'Please select at least one image.',
      );
      return;
    }

    state = state.copyWith(status: PdfStatus.creating, progress: 0.3);

    final result = await _createPdfUseCase(
      imagePaths: state.selectedImagePaths,
      fileName: fileName,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PdfStatus.error,
          errorMessage: failure.message,
          progress: 0.0,
        );
      },
      (document) {
        state = state.copyWith(
          status: PdfStatus.success,
          currentDocument: document,
          progress: 1.0,
        );
      },
    );
  }

  // ── Merge PDFs ──────────────────────────────────────────────────

  /// Adds a PDF path to the merge list.
  void addPdfForMerge(String pdfPath) {
    final updated = [...state.selectedPdfPaths, pdfPath];
    state = state.copyWith(selectedPdfPaths: updated);
  }

  /// Removes a PDF path from the merge list.
  void removePdfForMerge(int index) {
    final updated = [...state.selectedPdfPaths]..removeAt(index);
    state = state.copyWith(selectedPdfPaths: updated);
  }

  /// Reorders PDFs in the merge list.
  void reorderPdfsForMerge(int oldIndex, int newIndex) {
    final updated = [...state.selectedPdfPaths];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    state = state.copyWith(selectedPdfPaths: updated);
  }

  /// Merges the selected PDFs.
  Future<void> mergePdfs({String fileName = 'ScanPro_Merged'}) async {
    if (state.selectedPdfPaths.length < 2) {
      state = state.copyWith(
        status: PdfStatus.error,
        errorMessage: 'Please select at least two PDFs to merge.',
      );
      return;
    }

    state = state.copyWith(status: PdfStatus.merging, progress: 0.3);

    final result = await _mergePdfUseCase(
      pdfPaths: state.selectedPdfPaths,
      outputFileName: fileName,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PdfStatus.error,
          errorMessage: failure.message,
          progress: 0.0,
        );
      },
      (document) {
        state = state.copyWith(
          status: PdfStatus.success,
          currentDocument: document,
          progress: 1.0,
        );
      },
    );
  }

  // ── Split PDF ───────────────────────────────────────────────────

  /// Sets the PDF file to split.
  void setSplitPdfPath(String path) {
    state = state.copyWith(splitPdfPath: path);
  }

  /// Adds a page range to the split list.
  void addPageRange(String range) {
    final updated = [...state.pageRanges, range];
    state = state.copyWith(pageRanges: updated);
  }

  /// Removes a page range from the split list.
  void removePageRange(int index) {
    final updated = [...state.pageRanges]..removeAt(index);
    state = state.copyWith(pageRanges: updated);
  }

  /// Splits the selected PDF.
  Future<void> splitPdf() async {
    if (state.splitPdfPath == null) {
      state = state.copyWith(
        status: PdfStatus.error,
        errorMessage: 'Please select a PDF to split.',
      );
      return;
    }

    if (state.pageRanges.isEmpty) {
      state = state.copyWith(
        status: PdfStatus.error,
        errorMessage: 'Please add at least one page range.',
      );
      return;
    }

    state = state.copyWith(status: PdfStatus.splitting, progress: 0.3);

    final result = await _splitPdfUseCase(
      pdfPath: state.splitPdfPath!,
      pageRanges: state.pageRanges,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PdfStatus.error,
          errorMessage: failure.message,
          progress: 0.0,
        );
      },
      (documents) {
        state = state.copyWith(
          status: PdfStatus.success,
          progress: 1.0,
        );
      },
    );
  }

  // ── Compress PDF ────────────────────────────────────────────────

  /// Sets the PDF file to compress.
  void setCompressPdfPath(String path) {
    state = state.copyWith(compressPdfPath: path);
  }

  /// Sets the compression quality.
  void setCompressionQuality(double quality) {
    state = state.copyWith(compressionQuality: quality);
  }

  /// Compresses the selected PDF.
  Future<void> compressPdf() async {
    if (state.compressPdfPath == null) {
      state = state.copyWith(
        status: PdfStatus.error,
        errorMessage: 'Please select a PDF to compress.',
      );
      return;
    }

    state = state.copyWith(status: PdfStatus.compressing, progress: 0.3);

    final result = await _compressPdfUseCase(
      pdfPath: state.compressPdfPath!,
      quality: state.compressionQuality,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PdfStatus.error,
          errorMessage: failure.message,
          progress: 0.0,
        );
      },
      (operationResult) {
        state = state.copyWith(
          status: PdfStatus.success,
          progress: 1.0,
          operationResults: [...state.operationResults, operationResult],
        );
      },
    );
  }

  // ── Common ──────────────────────────────────────────────────────

  /// Resets the state to idle.
  void reset() {
    state = const PdfState();
  }

  /// Clears only the error state.
  void clearError() {
    state = state.copyWith(
      status: PdfStatus.idle,
      errorMessage: null,
      progress: 0.0,
    );
  }
}

/// Provider for the [PdfNotifier].
final pdfProvider = StateNotifierProvider<PdfNotifier, PdfState>((ref) {
  return PdfNotifier(
    createPdfUseCase: ref.watch(createPdfUseCaseProvider),
    mergePdfUseCase: ref.watch(mergePdfUseCaseProvider),
    splitPdfUseCase: ref.watch(splitPdfUseCaseProvider),
    compressPdfUseCase: ref.watch(compressPdfUseCaseProvider),
    repository: ref.watch(pdfRepositoryProvider),
  );
});

/// Provider for the current PDF status.
final pdfStatusProvider = Provider<PdfStatus>((ref) {
  return ref.watch(pdfProvider).status;
});

/// Provider for selected images (create PDF).
final selectedImagePathsProvider = Provider<List<String>>((ref) {
  return ref.watch(pdfProvider).selectedImagePaths;
});

/// Provider for selected PDFs (merge).
final selectedPdfPathsProvider = Provider<List<String>>((ref) {
  return ref.watch(pdfProvider).selectedPdfPaths;
});
