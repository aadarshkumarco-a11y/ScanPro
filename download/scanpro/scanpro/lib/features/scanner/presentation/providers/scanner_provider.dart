/// Riverpod providers for the Scanner feature presentation layer.
///
/// Exposes state notifiers for camera control, capture workflow,
/// image enhancement, and batch scanning sessions.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/features/scanner/domain/entities/edge_detection_result.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_result.dart';

// ---------------------------------------------------------------------------
// Scanner State
// ---------------------------------------------------------------------------

/// Camera flash mode.
enum FlashMode { off, on, auto }

/// Overall camera / scanner UI state.
class ScannerState {
  final bool isCameraReady;
  final bool isProcessing;
  final EdgeDetectionResult? detectedEdges;
  final FlashMode flashMode;
  final bool autoCaptureEnabled;
  final bool documentDetected;
  final int autoCaptureCountdown;

  const ScannerState({
    this.isCameraReady = false,
    this.isProcessing = false,
    this.detectedEdges,
    this.flashMode = FlashMode.off,
    this.autoCaptureEnabled = false,
    this.documentDetected = false,
    this.autoCaptureCountdown = 0,
  });

  ScannerState copyWith({
    bool? isCameraReady,
    bool? isProcessing,
    EdgeDetectionResult? detectedEdges,
    bool clearEdges = false,
    FlashMode? flashMode,
    bool? autoCaptureEnabled,
    bool? documentDetected,
    int? autoCaptureCountdown,
  }) {
    return ScannerState(
      isCameraReady: isCameraReady ?? this.isCameraReady,
      isProcessing: isProcessing ?? this.isProcessing,
      detectedEdges: clearEdges ? null : (detectedEdges ?? this.detectedEdges),
      flashMode: flashMode ?? this.flashMode,
      autoCaptureEnabled: autoCaptureEnabled ?? this.autoCaptureEnabled,
      documentDetected: documentDetected ?? this.documentDetected,
      autoCaptureCountdown: autoCaptureCountdown ?? this.autoCaptureCountdown,
    );
  }
}

/// StateNotifier managing the live camera scanner state.
class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier() : super(const ScannerState());

  void setCameraReady(bool ready) =>
      state = state.copyWith(isCameraReady: ready);

  void setProcessing(bool processing) =>
      state = state.copyWith(isProcessing: processing);

  void updateEdges(EdgeDetectionResult? result) {
    if (result != null && result.isDocumentDetected) {
      state = state.copyWith(
        detectedEdges: result,
        documentDetected: true,
      );
    } else {
      state = state.copyWith(clearEdges: true, documentDetected: false);
    }
  }

  void toggleFlash() {
    final modes = FlashMode.values;
    final idx = modes.indexOf(state.flashMode);
    state = state.copyWith(flashMode: modes[(idx + 1) % modes.length]);
  }

  void toggleAutoCapture() =>
      state = state.copyWith(autoCaptureEnabled: !state.autoCaptureEnabled);

  void setAutoCaptureCountdown(int seconds) =>
      state = state.copyWith(autoCaptureCountdown: seconds);

  void reset() => state = const ScannerState();
}

/// Provides the current scanner camera state.
final scannerStateProvider =
    StateNotifierProvider<ScannerNotifier, ScannerState>(
  (ref) => ScannerNotifier(),
);

// ---------------------------------------------------------------------------
// Capture State
// ---------------------------------------------------------------------------

/// State for a single capture operation.
class CaptureState {
  final bool isCapturing;
  final ScanResult? result;
  final String? error;

  const CaptureState({this.isCapturing = false, this.result, this.error});

  CaptureState copyWith({bool? isCapturing, ScanResult? result, String? error}) {
    return CaptureState(
      isCapturing: isCapturing ?? this.isCapturing,
      result: result ?? this.result,
      error: error,
    );
  }
}

/// StateNotifier that handles image capture and edge detection.
class CaptureNotifier extends StateNotifier<CaptureState> {
  CaptureNotifier() : super(const CaptureState());

  Future<void> captureImage(String imagePath) async {
    state = state.copyWith(isCapturing: true, error: null);
    try {
      final result = ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalPath: imagePath,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(isCapturing: false, result: result);
    } catch (e) {
      state = state.copyWith(isCapturing: false, error: e.toString());
    }
  }

  void updateWithEdges(EdgeDetectionResult edges) {
    final current = state.result;
    if (current == null) return;
    state = state.copyWith(
      result: current.copyWith(
        edges: edges.points,
        confidence: edges.confidence,
      ),
    );
  }

  void clear() => state = const CaptureState();
}

/// Provides the current capture state.
final captureProvider =
    StateNotifierProvider<CaptureNotifier, CaptureState>(
  (ref) => CaptureNotifier(),
);

// ---------------------------------------------------------------------------
// Enhancement State
// ---------------------------------------------------------------------------

/// Available filter types presented in the UI.
enum FilterType { original, auto, bw, magicColor, grayscale }

/// State for the enhancement workflow.
class EnhancementState {
  final FilterType selectedFilter;
  final double brightness;
  final double contrast;
  final double sharpness;
  final bool isEnhancing;
  final String? enhancedImagePath;
  final String? error;
  final bool showComparison;

  const EnhancementState({
    this.selectedFilter = FilterType.original,
    this.brightness = 50.0,
    this.contrast = 50.0,
    this.sharpness = 50.0,
    this.isEnhancing = false,
    this.enhancedImagePath,
    this.error,
    this.showComparison = false,
  });

  EnhancementState copyWith({
    FilterType? selectedFilter,
    double? brightness,
    double? contrast,
    double? sharpness,
    bool? isEnhancing,
    String? enhancedImagePath,
    String? error,
    bool? showComparison,
  }) {
    return EnhancementState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      sharpness: sharpness ?? this.sharpness,
      isEnhancing: isEnhancing ?? this.isEnhancing,
      enhancedImagePath: enhancedImagePath ?? this.enhancedImagePath,
      error: error,
      showComparison: showComparison ?? this.showComparison,
    );
  }

  /// Maps [FilterType] to domain [EnhancementType].
  EnhancementType get enhancementType => switch (selectedFilter) {
        FilterType.original => EnhancementType.none,
        FilterType.auto => EnhancementType.auto,
        FilterType.bw => EnhancementType.sharp,
        FilterType.magicColor => EnhancementType.magic,
        FilterType.grayscale => EnhancementType.removeShadows,
      };
}

/// StateNotifier managing enhancement filter & adjustments.
class EnhancementNotifier extends StateNotifier<EnhancementState> {
  EnhancementNotifier() : super(const EnhancementState());

  void selectFilter(FilterType filter) =>
      state = state.copyWith(selectedFilter: filter);

  void setBrightness(double value) =>
      state = state.copyWith(brightness: value);

  void setContrast(double value) =>
      state = state.copyWith(contrast: value);

  void setSharpness(double value) =>
      state = state.copyWith(sharpness: value);

  Future<void> applyEnhancement(String imagePath) async {
    state = state.copyWith(isEnhancing: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(
        isEnhancing: false,
        enhancedImagePath: imagePath,
      );
    } catch (e) {
      state = state.copyWith(isEnhancing: false, error: e.toString());
    }
  }

  void toggleComparison() =>
      state = state.copyWith(showComparison: !state.showComparison);

  void reset() => state = const EnhancementState();
}

/// Provides the current enhancement state.
final enhancementProvider =
    StateNotifierProvider<EnhancementNotifier, EnhancementState>(
  (ref) => EnhancementNotifier(),
);

// ---------------------------------------------------------------------------
// Batch Scan State
// ---------------------------------------------------------------------------

/// A single page inside a batch scanning session.
class BatchScanPage {
  final String id;
  final String imagePath;
  final String? thumbnailPath;
  final DateTime timestamp;

  const BatchScanPage({
    required this.id,
    required this.imagePath,
    this.thumbnailPath,
    required this.timestamp,
  });
}

/// State for a multi-page batch scanning session.
class BatchScanState {
  final List<BatchScanPage> pages;
  final bool isCreatingPdf;
  final String? error;

  const BatchScanState({
    this.pages = const [],
    this.isCreatingPdf = false,
    this.error,
  });

  int get pageCount => pages.length;

  BatchScanState copyWith({
    List<BatchScanPage>? pages,
    bool? isCreatingPdf,
    String? error,
  }) {
    return BatchScanState(
      pages: pages ?? this.pages,
      isCreatingPdf: isCreatingPdf ?? this.isCreatingPdf,
      error: error,
    );
  }
}

/// StateNotifier managing a batch (multi-page) scan session.
class BatchScanNotifier extends StateNotifier<BatchScanState> {
  BatchScanNotifier() : super(const BatchScanState());

  void addPage(String imagePath) {
    final page = BatchScanPage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(pages: [...state.pages, page]);
  }

  void removePage(String pageId) {
    state = state.copyWith(
      pages: state.pages.where((p) => p.id != pageId).toList(),
    );
  }

  void reorderPages(int oldIndex, int newIndex) {
    final pages = List<BatchScanPage>.from(state.pages);
    final item = pages.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    pages.insert(insertAt, item);
    state = state.copyWith(pages: pages);
  }

  Future<void> createPdf() async {
    state = state.copyWith(isCreatingPdf: true, error: null);
    try {
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(isCreatingPdf: false);
    } catch (e) {
      state = state.copyWith(isCreatingPdf: false, error: e.toString());
    }
  }

  void clearSession() => state = const BatchScanState();
}

/// Provides the batch scan session state.
final batchScanProvider =
    StateNotifierProvider<BatchScanNotifier, BatchScanState>(
  (ref) => BatchScanNotifier(),
);
