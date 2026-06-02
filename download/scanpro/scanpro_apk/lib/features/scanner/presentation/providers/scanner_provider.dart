import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/di/app_module.dart';
import 'package:scanpro/features/scanner/data/datasources/scanner_local_datasource.dart';
import 'package:scanpro/features/scanner/data/repositories/scanner_repository_impl.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:scanpro/features/scanner/domain/usecases/batch_scan_usecase.dart';
import 'package:scanpro/features/scanner/domain/usecases/crop_image_usecase.dart';
import 'package:scanpro/features/scanner/domain/usecases/enhance_image_usecase.dart';
import 'package:scanpro/features/scanner/domain/usecases/scan_document_usecase.dart';

// ═══════════════════════════════════════════════════════════════════
//  Repository Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the [ScannerRepository] implementation.
final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  final documentsBox = ref.watch(documentsBoxProvider);
  final localDatasource = ScannerLocalDatasource(documentsBox: documentsBox);
  return ScannerRepositoryImpl(localDatasource: localDatasource);
});

// ═══════════════════════════════════════════════════════════════════
//  Use Case Providers
// ═══════════════════════════════════════════════════════════════════

/// Provides the [ScanDocumentUseCase].
final scanDocumentUseCaseProvider = Provider<ScanDocumentUseCase>((ref) {
  return ScanDocumentUseCase(ref.watch(scannerRepositoryProvider));
});

/// Provides the [CropImageUseCase].
final cropImageUseCaseProvider = Provider<CropImageUseCase>((ref) {
  return CropImageUseCase(ref.watch(scannerRepositoryProvider));
});

/// Provides the [EnhanceImageUseCase].
final enhanceImageUseCaseProvider = Provider<EnhanceImageUseCase>((ref) {
  return EnhanceImageUseCase(ref.watch(scannerRepositoryProvider));
});

/// Provides the [BatchScanUseCase].
final batchScanUseCaseProvider = Provider<BatchScanUseCase>((ref) {
  return BatchScanUseCase(ref.watch(scannerRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════
//  Scanner State
// ═══════════════════════════════════════════════════════════════════

/// Possible states for the scanner.
enum ScannerStatus {
  idle,
  scanning,
  processing,
  success,
  error,
}

/// State holder for the scanner feature.
class ScannerState {
  final ScannerStatus status;
  final ScannedDocument? currentDocument;
  final List<ScannedDocument> documents;
  final String? errorMessage;
  final bool isFlashOn;
  final bool isBatchMode;
  final int batchPageCount;
  final String selectedFilter;
  final List<double>? cropArea;

  const ScannerState({
    this.status = ScannerStatus.idle,
    this.currentDocument,
    this.documents = const [],
    this.errorMessage,
    this.isFlashOn = false,
    this.isBatchMode = false,
    this.batchPageCount = 1,
    this.selectedFilter = 'original',
    this.cropArea,
  });

  ScannerState copyWith({
    ScannerStatus? status,
    ScannedDocument? currentDocument,
    List<ScannedDocument>? documents,
    String? errorMessage,
    bool? isFlashOn,
    bool? isBatchMode,
    int? batchPageCount,
    String? selectedFilter,
    List<double>? cropArea,
  }) {
    return ScannerState(
      status: status ?? this.status,
      currentDocument: currentDocument ?? this.currentDocument,
      documents: documents ?? this.documents,
      errorMessage: errorMessage,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isBatchMode: isBatchMode ?? this.isBatchMode,
      batchPageCount: batchPageCount ?? this.batchPageCount,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      cropArea: cropArea ?? this.cropArea,
    );
  }
}

/// State notifier for the scanner feature.
class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier({
    required ScanDocumentUseCase scanDocumentUseCase,
    required CropImageUseCase cropImageUseCase,
    required EnhanceImageUseCase enhanceImageUseCase,
    required BatchScanUseCase batchScanUseCase,
    required ScannerRepository repository,
  })  : _scanDocumentUseCase = scanDocumentUseCase,
        _cropImageUseCase = cropImageUseCase,
        _enhanceImageUseCase = enhanceImageUseCase,
        _batchScanUseCase = batchScanUseCase,
        _repository = repository,
        super(const ScannerState());

  final ScanDocumentUseCase _scanDocumentUseCase;
  final CropImageUseCase _cropImageUseCase;
  final EnhanceImageUseCase _enhanceImageUseCase;
  final BatchScanUseCase _batchScanUseCase;
  final ScannerRepository _repository;

  /// Scans a single document page.
  Future<void> scanDocument() async {
    state = state.copyWith(status: ScannerStatus.scanning);

    final result = await _scanDocumentUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ScannerStatus.error,
          errorMessage: failure.message,
        );
      },
      (document) {
        state = state.copyWith(
          status: ScannerStatus.success,
          currentDocument: document,
        );
      },
    );
  }

  /// Crops the current document image.
  Future<void> cropImage({
    required String filePath,
    required List<double> cropArea,
  }) async {
    if (state.currentDocument == null) return;

    state = state.copyWith(status: ScannerStatus.processing);

    final result = await _cropImageUseCase(
      filePath: filePath,
      cropArea: cropArea,
      document: state.currentDocument!,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ScannerStatus.error,
          errorMessage: failure.message,
        );
      },
      (document) {
        state = state.copyWith(
          status: ScannerStatus.success,
          currentDocument: document,
          cropArea: cropArea,
        );
      },
    );
  }

  /// Enhances the current document image.
  Future<void> enhanceImage({required String filePath}) async {
    if (state.currentDocument == null) return;

    state = state.copyWith(status: ScannerStatus.processing);

    final result = await _enhanceImageUseCase(
      filePath: filePath,
      document: state.currentDocument!,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ScannerStatus.error,
          errorMessage: failure.message,
        );
      },
      (document) {
        state = state.copyWith(
          status: ScannerStatus.success,
          currentDocument: document,
        );
      },
    );
  }

  /// Applies a filter to the current document image.
  Future<void> applyFilter({
    required String filePath,
    required String filterName,
  }) async {
    if (state.currentDocument == null) return;

    state = state.copyWith(
      status: ScannerStatus.processing,
      selectedFilter: filterName,
    );

    final result = await _repository.applyFilter(
      filePath: filePath,
      filterName: filterName,
      document: state.currentDocument!,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ScannerStatus.error,
          errorMessage: failure.message,
        );
      },
      (document) {
        state = state.copyWith(
          status: ScannerStatus.success,
          currentDocument: document,
        );
      },
    );
  }

  /// Rotates the current document image.
  Future<void> rotateImage({
    required String filePath,
    required int degrees,
  }) async {
    if (state.currentDocument == null) return;

    state = state.copyWith(status: ScannerStatus.processing);

    final result = await _repository.rotateImage(
      filePath: filePath,
      degrees: degrees,
      document: state.currentDocument!,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ScannerStatus.error,
          errorMessage: failure.message,
        );
      },
      (document) {
        state = state.copyWith(
          status: ScannerStatus.success,
          currentDocument: document,
        );
      },
    );
  }

  /// Starts a batch scan.
  Future<void> batchScan({required int pageCount}) async {
    state = state.copyWith(
      status: ScannerStatus.scanning,
      isBatchMode: true,
      batchPageCount: pageCount,
    );

    final result = await _batchScanUseCase(pageCount: pageCount);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ScannerStatus.error,
          errorMessage: failure.message,
        );
      },
      (document) {
        state = state.copyWith(
          status: ScannerStatus.success,
          currentDocument: document,
        );
      },
    );
  }

  /// Saves the current document permanently.
  Future<void> saveDocument() async {
    if (state.currentDocument == null) return;

    state = state.copyWith(status: ScannerStatus.processing);

    final result = await _repository.saveDocument(state.currentDocument!);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ScannerStatus.error,
          errorMessage: failure.message,
        );
      },
      (document) {
        final updatedDocs = [document, ...state.documents];
        state = state.copyWith(
          status: ScannerStatus.success,
          documents: updatedDocs,
          currentDocument: null,
          selectedFilter: 'original',
          cropArea: null,
        );
      },
    );
  }

  /// Discards the current scan without saving.
  void discardScan() {
    state = state.copyWith(
      status: ScannerStatus.idle,
      currentDocument: null,
      selectedFilter: 'original',
      cropArea: null,
    );
  }

  /// Toggles the flash on/off.
  void toggleFlash() {
    state = state.copyWith(isFlashOn: !state.isFlashOn);
  }

  /// Toggles batch mode on/off.
  void toggleBatchMode() {
    state = state.copyWith(isBatchMode: !state.isBatchMode);
  }

  /// Loads all documents from storage.
  Future<void> loadDocuments() async {
    final result = await _repository.getDocuments();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ScannerStatus.error,
          errorMessage: failure.message,
        );
      },
      (documents) {
        state = state.copyWith(documents: documents);
      },
    );
  }

  /// Resets the scanner to idle state.
  void reset() {
    state = const ScannerState();
  }
}

/// Provider for the [ScannerNotifier].
final scannerProvider =
    StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  return ScannerNotifier(
    scanDocumentUseCase: ref.watch(scanDocumentUseCaseProvider),
    cropImageUseCase: ref.watch(cropImageUseCaseProvider),
    enhanceImageUseCase: ref.watch(enhanceImageUseCaseProvider),
    batchScanUseCase: ref.watch(batchScanUseCaseProvider),
    repository: ref.watch(scannerRepositoryProvider),
  );
});

/// Provider for the current scan operation status.
final scanOperationStatusProvider = Provider<ScannerStatus>((ref) {
  return ref.watch(scannerProvider).status;
});

/// Provider for the selected filter name.
final selectedFilterProvider = Provider<String>((ref) {
  return ref.watch(scannerProvider).selectedFilter;
});

/// Provider for whether flash is on.
final isFlashOnProvider = Provider<bool>((ref) {
  return ref.watch(scannerProvider).isFlashOn;
});

/// Provider for batch mode status.
final isBatchModeProvider = Provider<bool>((ref) {
  return ref.watch(scannerProvider).isBatchMode;
});
