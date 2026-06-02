import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// ── Domain Models ──────────────────────────────────────────────

class PdfDocument {
  final String id;
  final String name;
  final String path;
  final int pageCount;
  final int fileSizeBytes;
  final DateTime lastModified;

  const PdfDocument({
    required this.id,
    required this.name,
    required this.path,
    required this.pageCount,
    required this.fileSizeBytes,
    required this.lastModified,
  });

  String get fileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class PdfPageInfo {
  final int pageNumber;
  final double width;
  final double height;
  final double rotation;
  final bool isBookmarked;

  const PdfPageInfo({
    required this.pageNumber,
    this.width = 595,
    this.height = 842,
    this.rotation = 0,
    this.isBookmarked = false,
  });

  PdfPageInfo copyWith({double? rotation, bool? isBookmarked}) => PdfPageInfo(
        pageNumber: pageNumber,
        width: width,
        height: height,
        rotation: rotation ?? this.rotation,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );
}

enum CompressionQuality { low, medium, high }

class CompressionResult {
  final int originalSize;
  final int compressedSize;
  final CompressionQuality quality;

  const CompressionResult({
    required this.originalSize,
    required this.compressedSize,
    required this.quality,
  });

  double get reductionPercent => ((1 - compressedSize / originalSize) * 100);

  String get originalSizeFormatted {
    if (originalSize < 1024 * 1024) return '${(originalSize / 1024).toStringAsFixed(1)} KB';
    return '${(originalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get compressedSizeFormatted {
    if (compressedSize < 1024 * 1024) return '${(compressedSize / 1024).toStringAsFixed(1)} KB';
    return '${(compressedSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class SplitOption {
  final String name;
  final List<List<int>> pageRanges;

  const SplitOption({required this.name, required this.pageRanges});
}

// ── State Classes ──────────────────────────────────────────────

class PdfCreationState {
  final List<String> imagePaths;
  final bool isCreating;
  final double progress;
  final String? outputPath;
  final String? error;

  const PdfCreationState({
    this.imagePaths = const [],
    this.isCreating = false,
    this.progress = 0.0,
    this.outputPath,
    this.error,
  });

  PdfCreationState copyWith({
    List<String>? imagePaths,
    bool? isCreating,
    double? progress,
    String? outputPath,
    String? error,
  }) =>
      PdfCreationState(
        imagePaths: imagePaths ?? this.imagePaths,
        isCreating: isCreating ?? this.isCreating,
        progress: progress ?? this.progress,
        outputPath: outputPath ?? this.outputPath,
        error: error,
      );
}

class PdfMergeState {
  final List<PdfDocument> documents;
  final bool isMerging;
  final double progress;
  final String? outputPath;
  final String? error;

  const PdfMergeState({
    this.documents = const [],
    this.isMerging = false,
    this.progress = 0.0,
    this.outputPath,
    this.error,
  });

  PdfMergeState copyWith({
    List<PdfDocument>? documents,
    bool? isMerging,
    double? progress,
    String? outputPath,
    String? error,
  }) =>
      PdfMergeState(
        documents: documents ?? this.documents,
        isMerging: isMerging ?? this.isMerging,
        progress: progress ?? this.progress,
        outputPath: outputPath ?? this.outputPath,
        error: error,
      );
}

class PdfSplitState {
  final PdfDocument? document;
  final List<SplitOption> splitOptions;
  final bool isSplitting;
  final double progress;
  final List<String> outputPaths;
  final String? error;

  const PdfSplitState({
    this.document,
    this.splitOptions = const [],
    this.isSplitting = false,
    this.progress = 0.0,
    this.outputPaths = const [],
    this.error,
  });

  PdfSplitState copyWith({
    PdfDocument? document,
    List<SplitOption>? splitOptions,
    bool? isSplitting,
    double? progress,
    List<String>? outputPaths,
    String? error,
  }) =>
      PdfSplitState(
        document: document ?? this.document,
        splitOptions: splitOptions ?? this.splitOptions,
        isSplitting: isSplitting ?? this.isSplitting,
        progress: progress ?? this.progress,
        outputPaths: outputPaths ?? this.outputPaths,
        error: error,
      );
}

class PdfCompressState {
  final PdfDocument? document;
  final CompressionQuality quality;
  final bool isCompressing;
  final double progress;
  final CompressionResult? result;
  final String? error;

  const PdfCompressState({
    this.document,
    this.quality = CompressionQuality.medium,
    this.isCompressing = false,
    this.progress = 0.0,
    this.result,
    this.error,
  });

  PdfCompressState copyWith({
    PdfDocument? document,
    CompressionQuality? quality,
    bool? isCompressing,
    double? progress,
    CompressionResult? result,
    String? error,
  }) =>
      PdfCompressState(
        document: document ?? this.document,
        quality: quality ?? this.quality,
        isCompressing: isCompressing ?? this.isCompressing,
        progress: progress ?? this.progress,
        result: result ?? this.result,
        error: error,
      );
}

class PdfPageState {
  final PdfDocument? document;
  final List<PdfPageInfo> pages;
  final Set<int> selectedPages;
  final bool isLoading;
  final bool hasUnsavedChanges;
  final String? error;

  const PdfPageState({
    this.document,
    this.pages = const [],
    this.selectedPages = const {},
    this.isLoading = false,
    this.hasUnsavedChanges = false,
    this.error,
  });

  PdfPageState copyWith({
    PdfDocument? document,
    List<PdfPageInfo>? pages,
    Set<int>? selectedPages,
    bool? isLoading,
    bool? hasUnsavedChanges,
    String? error,
  }) =>
      PdfPageState(
        document: document ?? this.document,
        pages: pages ?? this.pages,
        selectedPages: selectedPages ?? this.selectedPages,
        isLoading: isLoading ?? this.isLoading,
        hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
        error: error,
      );
}

// ── Notifiers ──────────────────────────────────────────────────

class PdfCreationNotifier extends StateNotifier<PdfCreationState> {
  PdfCreationNotifier() : super(const PdfCreationState());

  void addImage(String path) => state = state.copyWith(imagePaths: [...state.imagePaths, path]);
  void removeImage(int index) => state = state.copyWith(imagePaths: [...state.imagePaths]..removeAt(index));
  void reorderImages(int oldIndex, int newIndex) {
    final list = [...state.imagePaths];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    state = state.copyWith(imagePaths: list);
  }

  Future<String?> createPdf() async {
    if (state.imagePaths.isEmpty) return null;
    state = state.copyWith(isCreating: true, progress: 0.0);
    try {
      for (int i = 1; i <= state.imagePaths.length; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        state = state.copyWith(progress: i / state.imagePaths.length);
      }
      final path = '/storage/documents/scan_${DateTime.now().millisecondsSinceEpoch}.pdf';
      state = state.copyWith(isCreating: false, progress: 1.0, outputPath: path);
      return path;
    } catch (e) {
      state = state.copyWith(isCreating: false, error: e.toString());
      return null;
    }
  }
}

class PdfMergeNotifier extends StateNotifier<PdfMergeState> {
  PdfMergeNotifier() : super(const PdfMergeState());

  void addDocument(PdfDocument doc) => state = state.copyWith(documents: [...state.documents, doc]);
  void removeDocument(int index) => state = state.copyWith(documents: [...state.documents]..removeAt(index));
  void reorderDocuments(int oldIndex, int newIndex) {
    final list = [...state.documents];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    state = state.copyWith(documents: list);
  }

  Future<String?> merge() async {
    if (state.documents.length < 2) return null;
    state = state.copyWith(isMerging: true, progress: 0.0);
    try {
      for (int i = 1; i <= state.documents.length; i++) {
        await Future.delayed(const Duration(milliseconds: 400));
        state = state.copyWith(progress: i / state.documents.length);
      }
      final path = '/storage/documents/merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
      state = state.copyWith(isMerging: false, progress: 1.0, outputPath: path);
      return path;
    } catch (e) {
      state = state.copyWith(isMerging: false, error: e.toString());
      return null;
    }
  }
}

class PdfSplitNotifier extends StateNotifier<PdfSplitState> {
  PdfSplitNotifier() : super(const PdfSplitState());

  void setDocument(PdfDocument doc) => state = state.copyWith(document: doc, splitOptions: [], outputPaths: []);

  void addSplitOption(String name, List<List<int>> ranges) =>
      state = state.copyWith(splitOptions: [...state.splitOptions, SplitOption(name: name, pageRanges: ranges)]);

  void removeSplitOption(int index) =>
      state = state.copyWith(splitOptions: [...state.splitOptions]..removeAt(index));

  Future<List<String>> split() async {
    if (state.document == null || state.splitOptions.isEmpty) return [];
    state = state.copyWith(isSplitting: true, progress: 0.0);
    try {
      final totalSteps = state.splitOptions.length;
      for (int i = 1; i <= totalSteps; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        state = state.copyWith(progress: i / totalSteps);
      }
      final paths = state.splitOptions.map((opt) => '/storage/documents/${opt.name}_${DateTime.now().millisecondsSinceEpoch}.pdf').toList();
      state = state.copyWith(isSplitting: false, progress: 1.0, outputPaths: paths);
      return paths;
    } catch (e) {
      state = state.copyWith(isSplitting: false, error: e.toString());
      return [];
    }
  }
}

class PdfCompressNotifier extends StateNotifier<PdfCompressState> {
  PdfCompressNotifier() : super(const PdfCompressState());

  void setDocument(PdfDocument doc) => state = state.copyWith(document: doc, result: null);
  void setQuality(CompressionQuality q) => state = state.copyWith(quality: q, result: null);

  Future<CompressionResult?> compress() async {
    if (state.document == null) return null;
    state = state.copyWith(isCompressing: true, progress: 0.0);
    try {
      for (int i = 1; i <= 5; i++) {
        await Future.delayed(const Duration(milliseconds: 400));
        state = state.copyWith(progress: i / 5);
      }
      final factors = {CompressionQuality.low: 0.3, CompressionQuality.medium: 0.55, CompressionQuality.high: 0.75};
      final original = state.document!.fileSizeBytes;
      final compressed = (original * (1 - factors[state.quality]!)).round();
      final result = CompressionResult(originalSize: original, compressedSize: compressed, quality: state.quality);
      state = state.copyWith(isCompressing: false, progress: 1.0, result: result);
      return result;
    } catch (e) {
      state = state.copyWith(isCompressing: false, error: e.toString());
      return null;
    }
  }
}

class PdfPageNotifier extends StateNotifier<PdfPageState> {
  PdfPageNotifier() : super(const PdfPageState());

  Future<void> loadDocument(PdfDocument doc) async {
    state = state.copyWith(isLoading: true, document: doc);
    await Future.delayed(const Duration(milliseconds: 500));
    final pages = List.generate(doc.pageCount, (i) => PdfPageInfo(pageNumber: i + 1));
    state = state.copyWith(isLoading: false, pages: pages, selectedPages: {});
  }

  void togglePageSelection(int pageNumber) {
    final selected = {...state.selectedPages};
    if (selected.contains(pageNumber)) {
      selected.remove(pageNumber);
    } else {
      selected.add(pageNumber);
    }
    state = state.copyWith(selectedPages: selected);
  }

  void selectAll() => state = state.copyWith(selectedPages: state.pages.map((p) => p.pageNumber).toSet());
  void clearSelection() => state = state.copyWith(selectedPages: {});

  void rotateSelected() {
    final pages = state.pages.map((p) {
      if (state.selectedPages.contains(p.pageNumber)) {
        return p.copyWith(rotation: (p.rotation + 90) % 360);
      }
      return p;
    }).toList();
    state = state.copyWith(pages: pages, hasUnsavedChanges: true);
  }

  void deleteSelected() {
    final pages = state.pages.where((p) => !state.selectedPages.contains(p.pageNumber)).toList();
    state = state.copyWith(pages: pages, selectedPages: {}, hasUnsavedChanges: true);
  }

  void reorderPages(int oldIndex, int newIndex) {
    final list = [...state.pages];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    state = state.copyWith(pages: list, hasUnsavedChanges: true);
  }

  Future<bool> saveChanges() async {
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(hasUnsavedChanges: false);
    return true;
  }
}

// ── Providers ──────────────────────────────────────────────────

final pdfCreationProvider = StateNotifierProvider<PdfCreationNotifier, PdfCreationState>(
  (ref) => PdfCreationNotifier(),
);

final pdfMergeProvider = StateNotifierProvider<PdfMergeNotifier, PdfMergeState>(
  (ref) => PdfMergeNotifier(),
);

final pdfSplitProvider = StateNotifierProvider<PdfSplitNotifier, PdfSplitState>(
  (ref) => PdfSplitNotifier(),
);

final pdfCompressProvider = StateNotifierProvider<PdfCompressNotifier, PdfCompressState>(
  (ref) => PdfCompressNotifier(),
);

final pdfPageProvider = StateNotifierProvider<PdfPageNotifier, PdfPageState>(
  (ref) => PdfPageNotifier(),
);

final currentPdfDocumentProvider = StateProvider<PdfDocument?>((ref) => null);
final pdfViewerPageProvider = StateProvider<int>((ref) => 1);
final pdfViewerZoomProvider = StateProvider<double>((ref) => 1.0);
final pdfShowThumbnailsProvider = StateProvider<bool>((ref) => false);
