import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/di/app_module.dart';
import 'package:scanpro/features/security/data/datasources/security_local_datasource.dart';
import 'package:scanpro/features/security/data/repositories/security_repository_impl.dart';
import 'package:scanpro/features/security/domain/entities/security_settings.dart';
import 'package:scanpro/features/security/domain/repositories/security_repository.dart';
import 'package:scanpro/features/security/domain/usecases/biometric_auth_usecase.dart';
import 'package:scanpro/features/security/domain/usecases/setup_pin_usecase.dart';
import 'package:scanpro/features/security/domain/usecases/verify_pin_usecase.dart';

// ═══════════════════════════════════════════════════════════════════
//  Repository Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the [SecurityRepository] implementation.
final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final localDatasource = SecurityLocalDatasource(
    prefs: prefs,
  );
  return SecurityRepositoryImpl(localDatasource: localDatasource);
});

// ═══════════════════════════════════════════════════════════════════
//  Use Case Providers
// ═══════════════════════════════════════════════════════════════════

/// Provides the [SetupPinUseCase].
final setupPinUseCaseProvider = Provider<SetupPinUseCase>((ref) {
  return SetupPinUseCase(ref.watch(securityRepositoryProvider));
});

/// Provides the [VerifyPinUseCase].
final verifyPinUseCaseProvider = Provider<VerifyPinUseCase>((ref) {
  return VerifyPinUseCase(ref.watch(securityRepositoryProvider));
});

/// Provides the [BiometricAuthUseCase].
final biometricAuthUseCaseProvider = Provider<BiometricAuthUseCase>((ref) {
  return BiometricAuthUseCase(ref.watch(securityRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════════
//  Security State
// ═══════════════════════════════════════════════════════════════════

/// Possible states for security operations.
enum SecurityStatus {
  initial,
  loading,
  success,
  error,
}

/// State holder for the security feature.
class SecurityState {
  final SecurityStatus status;
  final SecuritySettings settings;
  final String? errorMessage;
  final bool isAppLocked;
  final bool isAuthenticated;
  final int failedPinAttempts;

  const SecurityState({
    this.status = SecurityStatus.initial,
    this.settings = const SecuritySettings(),
    this.errorMessage,
    this.isAppLocked = false,
    this.isAuthenticated = true,
    this.failedPinAttempts = 0,
  });

  SecurityState copyWith({
    SecurityStatus? status,
    SecuritySettings? settings,
    String? errorMessage,
    bool? isAppLocked,
    bool? isAuthenticated,
    int? failedPinAttempts,
  }) {
    return SecurityState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
      isAppLocked: isAppLocked ?? this.isAppLocked,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      failedPinAttempts: failedPinAttempts ?? this.failedPinAttempts,
    );
  }
}

/// State notifier for the security feature.
class SecurityNotifier extends StateNotifier<SecurityState> {
  SecurityNotifier({
    required SecurityRepository repository,
    required SetupPinUseCase setupPinUseCase,
    required VerifyPinUseCase verifyPinUseCase,
    required BiometricAuthUseCase biometricAuthUseCase,
  })  : _repository = repository,
        _setupPinUseCase = setupPinUseCase,
        _verifyPinUseCase = verifyPinUseCase,
        _biometricAuthUseCase = biometricAuthUseCase,
        super(const SecurityState());

  final SecurityRepository _repository;
  final SetupPinUseCase _setupPinUseCase;
  final VerifyPinUseCase _verifyPinUseCase;
  final BiometricAuthUseCase _biometricAuthUseCase;

  /// Loads the current security settings from storage.
  Future<void> loadSettings() async {
    state = state.copyWith(status: SecurityStatus.loading);

    final result = await _repository.getSecuritySettings();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SecurityStatus.error,
          errorMessage: failure.message,
        );
      },
      (settings) {
        state = state.copyWith(
          status: SecurityStatus.success,
          settings: settings,
        );
      },
    );
  }

  /// Sets up a new PIN.
  Future<bool> setupPin(String pin) async {
    state = state.copyWith(status: SecurityStatus.loading);

    final result = await _setupPinUseCase(pin);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: SecurityStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (settings) {
        state = state.copyWith(
          status: SecurityStatus.success,
          settings: settings,
        );
        return true;
      },
    );
  }

  /// Verifies a PIN.
  Future<bool> verifyPin(String pin) async {
    final result = await _verifyPinUseCase(pin);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: SecurityStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (isCorrect) {
        if (isCorrect) {
          state = state.copyWith(
            status: SecurityStatus.success,
            isAuthenticated: true,
            failedPinAttempts: 0,
          );
        } else {
          state = state.copyWith(
            status: SecurityStatus.error,
            errorMessage: 'Incorrect PIN',
            failedPinAttempts: state.failedPinAttempts + 1,
          );
        }
        return isCorrect;
      },
    );
  }

  /// Toggles biometric authentication.
  Future<bool> toggleBiometric(bool enabled) async {
    state = state.copyWith(status: SecurityStatus.loading);

    final result = await _biometricAuthUseCase.enableBiometric(
      enabled: enabled,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: SecurityStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (settings) {
        state = state.copyWith(
          status: SecurityStatus.success,
          settings: settings,
        );
        return true;
      },
    );
  }

  /// Authenticates using biometrics.
  Future<bool> authenticateBiometric() async {
    final result = await _biometricAuthUseCase.authenticate();

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: SecurityStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (isAuthenticated) {
        if (isAuthenticated) {
          state = state.copyWith(
            status: SecurityStatus.success,
            isAuthenticated: true,
          );
        }
        return isAuthenticated;
      },
    );
  }

  /// Toggles app lock.
  Future<void> toggleAppLock(bool enabled) async {
    state = state.copyWith(status: SecurityStatus.loading);

    final updatedSettings = state.settings.copyWith(
      isAppLockEnabled: enabled,
    );

    final result = await _repository.updateSecuritySettings(updatedSettings);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SecurityStatus.error,
          errorMessage: failure.message,
        );
      },
      (settings) {
        state = state.copyWith(
          status: SecurityStatus.success,
          settings: settings,
        );
      },
    );
  }

  /// Updates auto-lock duration.
  Future<void> updateAutoLockDuration(Duration duration) async {
    final updatedSettings = state.settings.copyWith(
      autoLockDuration: duration,
    );

    final result = await _repository.updateSecuritySettings(updatedSettings);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SecurityStatus.error,
          errorMessage: failure.message,
        );
      },
      (settings) {
        state = state.copyWith(
          status: SecurityStatus.success,
          settings: settings,
        );
      },
    );
  }

  /// Toggles vault.
  Future<void> toggleVault(bool enabled) async {
    final updatedSettings = state.settings.copyWith(
      isVaultEnabled: enabled,
    );

    final result = await _repository.updateSecuritySettings(updatedSettings);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SecurityStatus.error,
          errorMessage: failure.message,
        );
      },
      (settings) {
        state = state.copyWith(
          status: SecurityStatus.success,
          settings: settings,
        );
      },
    );
  }

  /// Locks the app.
  Future<void> lockApp() async {
    final result = await _repository.lockApp();

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(
          isAppLocked: true,
          isAuthenticated: false,
        );
      },
    );
  }

  /// Unlocks the app.
  Future<void> unlockApp() async {
    final result = await _repository.unlockApp();

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(
          isAppLocked: false,
          isAuthenticated: true,
        );
      },
    );
  }

  /// Clears any error message.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for the [SecurityNotifier].
final securityProvider =
    StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier(
    repository: ref.watch(securityRepositoryProvider),
    setupPinUseCase: ref.watch(setupPinUseCaseProvider),
    verifyPinUseCase: ref.watch(verifyPinUseCaseProvider),
    biometricAuthUseCase: ref.watch(biometricAuthUseCaseProvider),
  );
});

/// Provider for whether PIN is set up.
final isPinSetUpProvider = Provider<bool>((ref) {
  return ref.watch(securityProvider).settings.isPinEnabled;
});

/// Provider for whether biometric is enabled.
final isBiometricEnabledProvider = Provider<bool>((ref) {
  return ref.watch(securityProvider).settings.isBiometricEnabled;
});

/// Provider for whether the app is locked.
final isSecurityLockedProvider = Provider<bool>((ref) {
  return ref.watch(securityProvider).isAppLocked;
});
