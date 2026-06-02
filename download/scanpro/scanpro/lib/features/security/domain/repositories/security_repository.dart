import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/security/domain/entities/lock_config.dart';

/// Abstract repository defining the contract for security operations.
///
/// Provides authentication, lock management, and file encryption
/// capabilities for the application.
abstract class SecurityRepository {
  /// Authenticates the user using the configured lock method.
  ///
  /// Returns true if authentication succeeds, or a [SecurityFailure].
  Future<Either<Failure, bool>> authenticate();

  /// Sets a new PIN code for app lock.
  ///
  /// [pin] is the new PIN string (4-6 digits).
  /// Returns unit on success.
  Future<Either<Failure, Unit>> setPIN(String pin);

  /// Verifies the provided PIN against the stored value.
  ///
  /// [pin] is the PIN to verify.
  /// Returns true if the PIN matches.
  Future<Either<Failure, bool>> verifyPIN(String pin);

  /// Enables biometric authentication for app lock.
  ///
  /// Returns unit on success, or [SecurityFailure] if biometrics
  /// are not available on the device.
  Future<Either<Failure, Unit>> enableBiometric();

  /// Checks if the app is currently locked.
  ///
  /// Returns true if the lock is active and the timeout has elapsed.
  Future<Either<Failure, bool>> isLocked();

  /// Locks the app immediately, requiring authentication to unlock.
  ///
  /// Returns unit on success.
  Future<Either<Failure, Unit>> lockApp();

  /// Unlocks the app after successful authentication.
  ///
  /// Returns the updated [LockConfig] with the new unlock timestamp.
  Future<Either<Failure, LockConfig>> unlockApp();

  /// Encrypts a file using AES encryption.
  ///
  /// [filePath] is the path to the file to encrypt.
  /// Returns the path to the encrypted file.
  Future<Either<Failure, String>> encryptFile(String filePath);

  /// Decrypts a previously encrypted file.
  ///
  /// [filePath] is the path to the encrypted file.
  /// Returns the path to the decrypted file.
  Future<Either<Failure, String>> decryptFile(String filePath);
}
