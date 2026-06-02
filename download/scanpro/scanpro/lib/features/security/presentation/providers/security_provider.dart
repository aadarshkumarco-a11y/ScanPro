import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LockStatus { locked, unlocked, settingUp }

enum AuthState { idle, authenticating, success, failed }

class LockState {
  final LockStatus status;
  final AuthState authState;
  final String errorMessage;
  final int failedAttempts;

  const LockState({
    this.status = LockStatus.locked,
    this.authState = AuthState.idle,
    this.errorMessage = '',
    this.failedAttempts = 0,
  });

  LockState copyWith({
    LockStatus? status,
    AuthState? authState,
    String? errorMessage,
    int? failedAttempts,
  }) {
    return LockState(
      status: status ?? this.status,
      authState: authState ?? this.authState,
      errorMessage: errorMessage ?? this.errorMessage,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }
}

class PinState {
  final String enteredPin;
  final String confirmedPin;
  final bool isConfirming;
  final bool isSet;
  final String errorMessage;
  final bool isVerifying;

  const PinState({
    this.enteredPin = '',
    this.confirmedPin = '',
    this.isConfirming = false,
    this.isSet = false,
    this.errorMessage = '',
    this.isVerifying = false,
  });

  PinState copyWith({
    String? enteredPin,
    String? confirmedPin,
    bool? isConfirming,
    bool? isSet,
    String? errorMessage,
    bool? isVerifying,
  }) {
    return PinState(
      enteredPin: enteredPin ?? this.enteredPin,
      confirmedPin: confirmedPin ?? this.confirmedPin,
      isConfirming: isConfirming ?? this.isConfirming,
      isSet: isSet ?? this.isSet,
      errorMessage: errorMessage ?? this.errorMessage,
      isVerifying: isVerifying ?? this.isVerifying,
    );
  }
}

class BiometricState {
  final bool isAvailable;
  final bool isEnrolled;
  final bool isEnabled;
  final bool faceUnlockAvailable;
  final bool faceUnlockEnabled;
  final bool isAuthenticating;
  final String errorMessage;

  const BiometricState({
    this.isAvailable = false,
    this.isEnrolled = false,
    this.isEnabled = false,
    this.faceUnlockAvailable = false,
    this.faceUnlockEnabled = false,
    this.isAuthenticating = false,
    this.errorMessage = '',
  });

  BiometricState copyWith({
    bool? isAvailable,
    bool? isEnrolled,
    bool? isEnabled,
    bool? faceUnlockAvailable,
    bool? faceUnlockEnabled,
    bool? isAuthenticating,
    String? errorMessage,
  }) {
    return BiometricState(
      isAvailable: isAvailable ?? this.isAvailable,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      isEnabled: isEnabled ?? this.isEnabled,
      faceUnlockAvailable: faceUnlockAvailable ?? this.faceUnlockAvailable,
      faceUnlockEnabled: faceUnlockEnabled ?? this.faceUnlockEnabled,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class EncryptionState {
  final bool isEncrypting;
  final bool isDecrypting;
  final double progress;
  final String currentFile;
  final int totalFiles;
  final int processedFiles;
  final String errorMessage;

  const EncryptionState({
    this.isEncrypting = false,
    this.isDecrypting = false,
    this.progress = 0.0,
    this.currentFile = '',
    this.totalFiles = 0,
    this.processedFiles = 0,
    this.errorMessage = '',
  });

  EncryptionState copyWith({
    bool? isEncrypting,
    bool? isDecrypting,
    double? progress,
    String? currentFile,
    int? totalFiles,
    int? processedFiles,
    String? errorMessage,
  }) {
    return EncryptionState(
      isEncrypting: isEncrypting ?? this.isEncrypting,
      isDecrypting: isDecrypting ?? this.isDecrypting,
      progress: progress ?? this.progress,
      currentFile: currentFile ?? this.currentFile,
      totalFiles: totalFiles ?? this.totalFiles,
      processedFiles: processedFiles ?? this.processedFiles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LockNotifier extends StateNotifier<LockState> {
  LockNotifier() : super(const LockState());

  void unlock() {
    state = state.copyWith(
      status: LockStatus.unlocked,
      authState: AuthState.success,
      failedAttempts: 0,
      errorMessage: '',
    );
  }

  void lock() {
    state = const LockState();
  }

  void authenticationFailed() {
    state = state.copyWith(
      authState: AuthState.failed,
      failedAttempts: state.failedAttempts + 1,
      errorMessage: 'Incorrect PIN. Try again.',
    );
  }

  void resetAuthState() {
    state = state.copyWith(
      authState: AuthState.idle,
      errorMessage: '',
    );
  }

  void startAuthentication() {
    state = state.copyWith(authState: AuthState.authenticating);
  }
}

class PinNotifier extends StateNotifier<PinState> {
  PinNotifier() : super(const PinState());

  void addDigit(String digit) {
    if (state.enteredPin.length >= 6) return;
    final newPin = state.enteredPin + digit;
    state = state.copyWith(enteredPin: newPin, errorMessage: '');

    if (newPin.length == 6 && !state.isConfirming) {
      state = state.copyWith(isConfirming: true, confirmedPin: newPin, enteredPin: '');
    } else if (newPin.length == 6 && state.isConfirming) {
      _verifyPin();
    }
  }

  void removeDigit() {
    if (state.enteredPin.isEmpty) return;
    state = state.copyWith(
      enteredPin: state.enteredPin.substring(0, state.enteredPin.length - 1),
      errorMessage: '',
    );
  }

  void _verifyPin() {
    if (state.enteredPin == state.confirmedPin) {
      state = state.copyWith(isSet: true, errorMessage: '');
    } else {
      state = state.copyWith(
        enteredPin: '',
        confirmedPin: '',
        isConfirming: false,
        errorMessage: 'PINs do not match. Please try again.',
      );
    }
  }

  void reset() {
    state = const PinState();
  }

  void verifyPin(String pin) {
    state = state.copyWith(isVerifying: true, errorMessage: '');
    // In production, verify against secure storage
    // For now, simulate verification
    Future.delayed(const Duration(milliseconds: 300), () {
      state = state.copyWith(isVerifying: false);
    });
  }
}

class BiometricNotifier extends StateNotifier<BiometricState> {
  BiometricNotifier() : super(const BiometricState());

  Future<void> checkAvailability() async {
    // In production, use local_auth package
    state = state.copyWith(
      isAvailable: true,
      isEnrolled: true,
      faceUnlockAvailable: false,
    );
  }

  void toggleFingerprint(bool enabled) {
    state = state.copyWith(isEnabled: enabled);
  }

  void toggleFaceUnlock(bool enabled) {
    state = state.copyWith(faceUnlockEnabled: enabled);
  }

  Future<void> authenticate() async {
    state = state.copyWith(isAuthenticating: true, errorMessage: '');
    try {
      // In production, use local_auth authenticate()
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isAuthenticating: false);
    } catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: 'Biometric authentication failed',
      );
    }
  }
}

class EncryptionNotifier extends StateNotifier<EncryptionState> {
  EncryptionNotifier() : super(const EncryptionState());

  Future<void> encryptFiles(List<String> filePaths) async {
    state = state.copyWith(
      isEncrypting: true,
      totalFiles: filePaths.length,
      processedFiles: 0,
      progress: 0.0,
    );
    for (int i = 0; i < filePaths.length; i++) {
      state = state.copyWith(
        currentFile: filePaths[i],
        processedFiles: i,
        progress: (i + 1) / filePaths.length,
      );
      await Future.delayed(const Duration(milliseconds: 200));
    }
    state = state.copyWith(
      isEncrypting: false,
      processedFiles: filePaths.length,
      progress: 1.0,
      currentFile: '',
    );
  }

  Future<void> decryptFiles(List<String> filePaths) async {
    state = state.copyWith(
      isDecrypting: true,
      totalFiles: filePaths.length,
      processedFiles: 0,
      progress: 0.0,
    );
    for (int i = 0; i < filePaths.length; i++) {
      state = state.copyWith(
        currentFile: filePaths[i],
        processedFiles: i,
        progress: (i + 1) / filePaths.length,
      );
      await Future.delayed(const Duration(milliseconds: 200));
    }
    state = state.copyWith(
      isDecrypting: false,
      processedFiles: filePaths.length,
      progress: 1.0,
      currentFile: '',
    );
  }
}

final lockStateProvider = StateNotifierProvider<LockNotifier, LockState>(
  (ref) => LockNotifier(),
);

final pinProvider = StateNotifierProvider<PinNotifier, PinState>(
  (ref) => PinNotifier(),
);

final biometricProvider = StateNotifierProvider<BiometricNotifier, BiometricState>(
  (ref) => BiometricNotifier()..checkAvailability(),
);

final encryptionProvider = StateNotifierProvider<EncryptionNotifier, EncryptionState>(
  (ref) => EncryptionNotifier(),
);
