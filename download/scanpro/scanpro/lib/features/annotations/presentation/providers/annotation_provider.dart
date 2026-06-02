import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AnnotationType { highlight, underline, draw, shape, note, text }

class AnnotationModel {
  final String id;
  final AnnotationType type;
  final int pageIndex;
  final Rect? bounds;
  final String? text;
  final String color;
  final List<Offset>? points;
  final DateTime createdAt;

  const AnnotationModel({
    required this.id,
    required this.type,
    required this.pageIndex,
    this.bounds,
    this.text,
    this.color = '#FFFF00',
    this.points,
    required this.createdAt,
  });

  AnnotationModel copyWith({
    String? id,
    AnnotationType? type,
    int? pageIndex,
    Rect? bounds,
    String? text,
    String? color,
    List<Offset>? points,
    DateTime? createdAt,
  }) {
    return AnnotationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      pageIndex: pageIndex ?? this.pageIndex,
      bounds: bounds ?? this.bounds,
      text: text ?? this.text,
      color: color ?? this.color,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AnnotationState {
  final List<AnnotationModel> annotations;
  final AnnotationType? activeTool;
  final String activeColor;
  final bool isLoading;
  final List<AnnotationModel> undoStack;
  final List<AnnotationModel> redoStack;

  const AnnotationState({
    this.annotations = const [],
    this.activeTool,
    this.activeColor = '#FFFF00',
    this.isLoading = false,
    this.undoStack = const [],
    this.redoStack = const [],
  });

  AnnotationState copyWith({
    List<AnnotationModel>? annotations,
    AnnotationType? activeTool,
    String? activeColor,
    bool? isLoading,
    List<AnnotationModel>? undoStack,
    List<AnnotationModel>? redoStack,
    bool clearActiveTool = false,
  }) {
    return AnnotationState(
      annotations: annotations ?? this.annotations,
      activeTool: clearActiveTool ? null : (activeTool ?? this.activeTool),
      activeColor: activeColor ?? this.activeColor,
      isLoading: isLoading ?? this.isLoading,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }
}

class AnnotationNotifier extends StateNotifier<AnnotationState> {
  AnnotationNotifier() : super(const AnnotationState());

  void setActiveTool(AnnotationType type) {
    state = state.copyWith(activeTool: type);
  }

  void clearActiveTool() {
    state = state.copyWith(clearActiveTool: true);
  }

  void setActiveColor(String color) {
    state = state.copyWith(activeColor: color);
  }

  void addAnnotation(AnnotationModel annotation) {
    state = state.copyWith(
      annotations: [...state.annotations, annotation],
      undoStack: [...state.undoStack, annotation],
      redoStack: const [],
    );
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    final last = state.undoStack.last;
    state = state.copyWith(
      annotations: state.annotations.where((a) => a.id != last.id).toList(),
      undoStack: state.undoStack.where((a) => a.id != last.id).toList(),
      redoStack: [...state.redoStack, last],
    );
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final last = state.redoStack.last;
    state = state.copyWith(
      annotations: [...state.annotations, last],
      undoStack: [...state.undoStack, last],
      redoStack: state.redoStack.where((a) => a.id != last.id).toList(),
    );
  }

  void deleteAnnotation(String id) {
    state = state.copyWith(
      annotations: state.annotations.where((a) => a.id != id).toList(),
    );
  }

  void clearAll() {
    state = state.copyWith(
      annotations: const [],
      undoStack: const [],
      redoStack: const [],
    );
  }
}

final annotationProvider =
    StateNotifierProvider<AnnotationNotifier, AnnotationState>(
  (ref) => AnnotationNotifier(),
);
