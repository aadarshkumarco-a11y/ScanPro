import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignatureModel {
  final String id;
  final String name;
  final String? imagePath;
  final DateTime createdAt;
  final String color;
  final double strokeWidth;

  const SignatureModel({
    required this.id,
    required this.name,
    this.imagePath,
    required this.createdAt,
    this.color = '#000000',
    this.strokeWidth = 3.0,
  });

  SignatureModel copyWith({
    String? id,
    String? name,
    String? imagePath,
    DateTime? createdAt,
    String? color,
    double? strokeWidth,
  }) {
    return SignatureModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}

class SignatureState {
  final List<SignatureModel> signatures;
  final bool isLoading;
  final String errorMessage;
  final String? activeSignatureId;

  const SignatureState({
    this.signatures = const [],
    this.isLoading = false,
    this.errorMessage = '',
    this.activeSignatureId,
  });

  SignatureState copyWith({
    List<SignatureModel>? signatures,
    bool? isLoading,
    String? errorMessage,
    String? activeSignatureId,
  }) {
    return SignatureState(
      signatures: signatures ?? this.signatures,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      activeSignatureId: activeSignatureId ?? this.activeSignatureId,
    );
  }
}

class SignatureNotifier extends StateNotifier<SignatureState> {
  SignatureNotifier() : super(const SignatureState()) {
    _loadSignatures();
  }

  void _loadSignatures() {
    state = state.copyWith(isLoading: true);
    // In production, load from local database / secure storage
    Future.delayed(const Duration(milliseconds: 300), () {
      state = state.copyWith(
        isLoading: false,
        signatures: [
          SignatureModel(
            id: '1',
            name: 'My Signature',
            createdAt: DateTime(2024, 1, 15),
          ),
          SignatureModel(
            id: '2',
            name: 'Initials',
            createdAt: DateTime(2024, 2, 20),
            color: '#0000FF',
          ),
        ],
      );
    });
  }

  Future<void> addSignature(SignatureModel signature) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 200));
    state = state.copyWith(
      isLoading: false,
      signatures: [...state.signatures, signature],
    );
  }

  Future<void> deleteSignature(String id) async {
    state = state.copyWith(
      signatures: state.signatures.where((s) => s.id != id).toList(),
    );
  }

  void setActiveSignature(String id) {
    state = state.copyWith(activeSignatureId: id);
  }
}

final signatureProvider =
    StateNotifierProvider<SignatureNotifier, SignatureState>(
  (ref) => SignatureNotifier(),
);
