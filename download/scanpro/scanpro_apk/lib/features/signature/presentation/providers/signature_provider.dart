import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/di/app_module.dart';
import 'package:scanpro/features/signature/data/datasources/signature_local_datasource.dart';
import 'package:scanpro/features/signature/data/repositories/signature_repository_impl.dart';
import 'package:scanpro/features/signature/domain/entities/signature.dart';
import 'package:scanpro/features/signature/domain/repositories/signature_repository.dart';
import 'package:scanpro/features/signature/domain/usecases/save_signature_usecase.dart';

// ═══════════════════════════════════════════════════════════════════
//  Repository Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the [SignatureRepository] implementation.
final signatureRepositoryProvider = Provider<SignatureRepository>((ref) {
  final signaturesBox = ref.watch(signaturesBoxProvider);
  final localDatasource = SignatureLocalDatasource(
    signaturesBox: signaturesBox,
  );
  return SignatureRepositoryImpl(localDatasource: localDatasource);
});

// ═══════════════════════════════════════════════════════════════════
//  Use Case Providers
// ═══════════════════════════════════════════════════════════════════

/// Provides the [SaveSignatureUseCase].
final saveSignatureUseCaseProvider = Provider<SaveSignatureUseCase>((ref) {
  return SaveSignatureUseCase(ref.watch(signatureRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════
//  Signature State
// ═══════════════════════════════════════════════════════════════════

/// Possible states for signature operations.
enum SignatureStatus {
  idle,
  loading,
  success,
  error,
}

/// State holder for the signature feature.
class SignatureState {
  final SignatureStatus status;
  final List<Signature> signatures;
  final String? errorMessage;

  const SignatureState({
    this.status = SignatureStatus.idle,
    this.signatures = const [],
    this.errorMessage,
  });

  SignatureState copyWith({
    SignatureStatus? status,
    List<Signature>? signatures,
    String? errorMessage,
  }) {
    return SignatureState(
      status: status ?? this.status,
      signatures: signatures ?? this.signatures,
      errorMessage: errorMessage,
    );
  }

  /// The default signature, if any.
  Signature? get defaultSignature {
    try {
      return signatures.firstWhere((s) => s.isDefault);
    } catch (_) {
      return null;
    }
  }
}

/// State notifier for the signature feature.
class SignatureNotifier extends StateNotifier<SignatureState> {
  SignatureNotifier({
    required SignatureRepository repository,
    required SaveSignatureUseCase saveSignatureUseCase,
  })  : _repository = repository,
        _saveSignatureUseCase = saveSignatureUseCase,
        super(const SignatureState());

  final SignatureRepository _repository;
  final SaveSignatureUseCase _saveSignatureUseCase;

  /// Loads all signatures from storage.
  Future<void> loadSignatures() async {
    state = state.copyWith(status: SignatureStatus.loading);

    final result = await _repository.getSignatures();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SignatureStatus.error,
          errorMessage: failure.message,
        );
      },
      (signatures) {
        state = state.copyWith(
          status: SignatureStatus.success,
          signatures: signatures,
        );
      },
    );
  }

  /// Saves a new signature.
  Future<bool> saveSignature(Signature signature) async {
    state = state.copyWith(status: SignatureStatus.loading);

    final result = await _saveSignatureUseCase(signature);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: SignatureStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (savedSignature) {
        state = state.copyWith(
          status: SignatureStatus.success,
          signatures: [savedSignature, ...state.signatures],
        );
        return true;
      },
    );
  }

  /// Deletes a signature.
  Future<void> deleteSignature(String signatureId) async {
    final result = await _repository.deleteSignature(signatureId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SignatureStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: SignatureStatus.success,
          signatures: state.signatures
              .where((s) => s.id != signatureId)
              .toList(),
        );
      },
    );
  }

  /// Sets a signature as the default.
  Future<void> setDefaultSignature(String signatureId) async {
    final result = await _repository.setDefaultSignature(signatureId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SignatureStatus.error,
          errorMessage: failure.message,
        );
      },
      (updatedSignature) {
        final updatedList = state.signatures.map((s) {
          if (s.id == signatureId) {
            return updatedSignature;
          }
          return s.copyWith(isDefault: false);
        }).toList();

        state = state.copyWith(
          status: SignatureStatus.success,
          signatures: updatedList,
        );
      },
    );
  }

  /// Clears any error message.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for the [SignatureNotifier].
final signatureProvider =
    StateNotifierProvider<SignatureNotifier, SignatureState>((ref) {
  return SignatureNotifier(
    repository: ref.watch(signatureRepositoryProvider),
    saveSignatureUseCase: ref.watch(saveSignatureUseCaseProvider),
  );
});
