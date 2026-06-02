import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Custom exception for biometric service errors.
class BiometricException implements Exception {
  final String message;
  const BiometricException(this.message);
  @override
  String toString() => 'BiometricException: $message';
}

/// Service for biometric authentication using local_auth.
///
/// Provides fingerprint, face ID, and other biometric
/// authentication capabilities for app security.
class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  /// Checks whether the device supports biometric authentication.
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Checks whether the device has enrolled biometrics.
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Gets the list of available biometric types on the device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticates the user using biometrics.
  ///
  /// [reason] is the message displayed to the user explaining
  /// why authentication is needed.
  /// [stickyAuth] if true, the authentication persists across
  /// app lifecycle changes.
  ///
  /// Returns true if authentication succeeds.
  Future<bool> authenticate({
    String reason = 'Authenticate to access ScanPro',
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await this.isAvailable();
      if (!isAvailable) {
        throw const BiometricException(
          'Biometric authentication is not available on this device',
        );
      }

      final isAuthenticated = await _localAuth.authenticate(
        authOptions: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
          sensitiveTransaction: true,
        ),
        localizedReason: reason,
      );

      return isAuthenticated;
    } on BiometricException {
      rethrow;
    } catch (e) {
      final errorString = e.toString();

      if (errorString.contains(auth_error.notAvailable)) {
        throw const BiometricException(
          'Biometric authentication is not configured on this device',
        );
      }
      if (errorString.contains(auth_error.notEnrolled)) {
        throw const BiometricException(
          'No biometrics are enrolled on this device',
        );
      }
      if (errorString.contains(auth_error.lockedOut)) {
        throw const BiometricException(
          'Biometric authentication is temporarily locked out',
        );
      }
      if (errorString.contains(auth_error.permanentlyLockedOut)) {
        throw const BiometricException(
          'Biometric authentication is permanently locked out. '
          'Please use PIN instead.',
        );
      }

      throw BiometricException('Authentication failed: $e');
    }
  }

  /// Authenticates with a fallback to device credentials (PIN/pattern).
  ///
  /// Unlike [authenticate], this allows the user to fall back
  /// to their device lock screen credentials if biometrics fail.
  Future<bool> authenticateWithFallback({
    String reason = 'Authenticate to access ScanPro',
  }) async {
    try {
      return await _localAuth.authenticate(
        authOptions: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          sensitiveTransaction: true,
        ),
        localizedReason: reason,
      );
    } catch (e) {
      throw BiometricException(
        'Authentication with fallback failed: $e',
      );
    }
  }

  /// Stops any ongoing authentication process.
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (_) {
      // Ignore errors when stopping authentication
    }
  }
}
