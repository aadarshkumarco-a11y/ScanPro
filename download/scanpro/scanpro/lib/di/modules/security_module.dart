/// Security feature module — provides all Riverpod providers related to
/// app-level authentication, biometric verification, data encryption,
/// and PIN management.
///
/// This module powers the app lock screen, biometric sign-in, document
/// encryption at rest, and secure credential storage.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/security_repository.dart';
import '../../data/datasources/security_local_data_source.dart';
import '../../data/repositories/security_repository_impl.dart';
import '../injection.dart';

// ---------------------------------------------------------------------------
// Data Sources
// ---------------------------------------------------------------------------

/// Local data source that persists security settings, encrypted PIN
/// hashes, and biometric enrollment state in a secure Hive box.
final securityLocalDataSourceProvider = Provider<SecurityLocalDataSource>(
  (ref) {
    final box = ref.watch(hiveBoxProvider);
    return SecurityLocalDataSource(box: box);
  },
);

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

/// Biometric authentication service wrapping local_auth.
///
/// Checks device capability and performs fingerprint / Face ID
/// verification. Returns `true` on successful authentication.
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// AES-256 encryption service for securing document files and
/// sensitive metadata at rest.
///
/// Uses a key derived from the user's PIN via PBKDF2 with a
/// per-document salt stored in the local data source.
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Primary [SecurityRepository] implementation backed by the biometric
/// service, encryption service, and secure local storage.
final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  final localDataSource = ref.watch(securityLocalDataSourceProvider);
  final biometricService = ref.watch(biometricServiceProvider);
  final encryptionService = ref.watch(encryptionServiceProvider);
  return SecurityRepositoryImpl(
    localDataSource: localDataSource,
    biometricService: biometricService,
    encryptionService: encryptionService,
  );
});

// ---------------------------------------------------------------------------
// Reactive Security State
// ---------------------------------------------------------------------------

/// Whether app lock (PIN or biometric) is currently enabled.
/// The router guard watches this to redirect to the lock screen.
final isAppLockEnabledProvider = StateProvider<bool>((ref) {
  final repository = ref.watch(securityRepositoryProvider);
  return repository.isAppLockEnabled();
});

/// Whether the user has enrolled at least one biometric method
/// (fingerprint or Face ID) for app authentication.
final isBiometricEnrolledProvider = StateProvider<bool>((ref) {
  final repository = ref.watch(securityRepositoryProvider);
  return repository.isBiometricEnrolled();
});

/// Whether the app is currently in a locked state. When `true`,
/// the security guard redirects all routes to [LockScreen].
///
/// Reset to `false` after successful PIN or biometric verification.
final isAppLockedProvider = StateProvider<bool>((ref) {
  final lockEnabled = ref.watch(isAppLockEnabledProvider);
  return lockEnabled; // locked by default when lock is enabled
});

/// The auto-lock timeout duration. After this period of inactivity
/// the app re-locks itself. Defaults to 5 minutes.
final autoLockDurationProvider = StateProvider<Duration>((ref) {
  final repository = ref.watch(securityRepositoryProvider);
  final minutes = repository.getAutoLockMinutes();
  return Duration(minutes: minutes);
});

// ---------------------------------------------------------------------------
// Service Classes (inline for DI wiring)
// ---------------------------------------------------------------------------

/// Wraps the local_auth plugin for biometric authentication.
class BiometricService {
  /// Checks whether the device supports biometric authentication.
  Future<bool> isDeviceSupported() async {
    throw UnimplementedError(
      'BiometricService.isDeviceSupported must be implemented',
    );
  }

  /// Returns the list of available biometric types on this device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    throw UnimplementedError(
      'BiometricService.getAvailableBiometrics must be implemented',
    );
  }

  /// Prompts the user for biometric authentication with [reason].
  /// Returns `true` if authentication succeeds.
  Future<bool> authenticate({required String reason}) async {
    throw UnimplementedError(
      'BiometricService.authenticate must be implemented',
    );
  }
}

/// Supported biometric authentication types.
enum BiometricType { fingerprint, face, iris, weak, strong }

/// AES-256 encryption service for securing documents and metadata.
class EncryptionService {
  /// Encrypts the file at [filePath] using a key derived from [pin]
  /// with a randomly generated salt. Returns the encrypted file path.
  Future<String> encryptFile(String filePath, String pin) async {
    throw UnimplementedError(
      'EncryptionService.encryptFile must be implemented',
    );
  }

  /// Decrypts the file at [encryptedFilePath] using [pin]. Returns
  /// the decrypted file path. Throws on wrong PIN.
  Future<String> decryptFile(String encryptedFilePath, String pin) async {
    throw UnimplementedError(
      'EncryptionService.decryptFile must be implemented',
    );
  }

  /// Encrypts a plaintext [string] and returns the base64-encoded
  /// ciphertext with the salt prepended.
  Future<String> encryptString(String plaintext, String pin) async {
    throw UnimplementedError(
      'EncryptionService.encryptString must be implemented',
    );
  }

  /// Decrypts a base64-encoded [ciphertext] that was encrypted with
  /// [pin]. Returns the original plaintext.
  Future<String> decryptString(String ciphertext, String pin) async {
    throw UnimplementedError(
      'EncryptionService.decryptString must be implemented',
    );
  }
}
