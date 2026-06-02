import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/security/domain/entities/security_settings.dart';

/// Abstract repository contract for security operations.
///
/// Defines the domain-level API for PIN management, biometric
/// authentication, app locking, and data encryption.
/// Implementations must convert data-layer exceptions into [Failure]s.
abstract class SecurityRepository {
  /// Sets up a new PIN for the user.
  ///
  /// [pin] is the raw 6-digit PIN string which will be hashed
  /// before being stored in secure storage.
  /// Returns the updated [SecuritySettings] on success.
  Future<Either<Failure, SecuritySettings>> setupPin(String pin);

  /// Verifies the user-entered [pin] against the stored hash.
  ///
  /// Returns `true` on success, or a [SecurityFailure] if incorrect
  /// or if the user is locked out after too many attempts.
  Future<Either<Failure, bool>> verifyPin(String pin);

  /// Enables biometric authentication on the device.
  ///
  /// Returns the updated [SecuritySettings] on success, or a
  /// [SecurityFailure] if biometrics are unavailable or not enrolled.
  Future<Either<Failure, SecuritySettings>> enableBiometric(bool enabled);

  /// Authenticates the user via biometric prompt.
  ///
  /// Returns `true` if authentication succeeded.
  Future<Either<Failure, bool>> authenticateBiometric();

  /// Locks the app, requiring re-authentication to access content.
  Future<Either<Failure, Unit>> lockApp();

  /// Unlocks the app and updates [lastUnlockedAt].
  Future<Either<Failure, Unit>> unlockApp();

  /// Encrypts the given [plainText] using AES-256 with the stored key.
  ///
  /// Returns the base64-encoded cipher text.
  Future<Either<Failure, String>> encryptData(String plainText);

  /// Decrypts the given [cipherText] using AES-256 with the stored key.
  ///
  /// Returns the original plain text.
  Future<Either<Failure, String>> decryptData(String cipherText);

  /// Updates security settings with the provided [settings].
  ///
  /// Persists the updated settings to secure storage.
  Future<Either<Failure, SecuritySettings>> updateSecuritySettings(
    SecuritySettings settings,
  );

  /// Retrieves the current security settings.
  ///
  /// Returns a default [SecuritySettings] instance if none are stored.
  Future<Either<Failure, SecuritySettings>> getSecuritySettings();
}
