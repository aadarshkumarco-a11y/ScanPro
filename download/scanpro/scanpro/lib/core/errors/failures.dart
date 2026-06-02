/// Failure classes representing domain-level errors in ScanPro.
///
/// Each failure wraps a descriptive [message] and an optional [code]
/// for programmatic error handling. Failures are returned from use cases
/// instead of throwing exceptions, following Clean Architecture conventions.
library;

import 'package:equatable/equatable.dart';

/// Base failure class from which all specific failures derive.
abstract class Failure extends Equatable {
  /// Human-readable description of the failure.
  final String message;

  /// Optional machine-readable error code for programmatic handling.
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure during document scanning (camera, edge detection, cropping).
class ScannerFailure extends Failure {
  const ScannerFailure({required super.message, super.code});
}

/// Failure during OCR text extraction.
class OCRFailure extends Failure {
  const OCRFailure({required super.message, super.code});
}

/// Failure during PDF generation or manipulation.
class PDFFailure extends Failure {
  const PDFFailure({required super.message, super.code});
}

/// Failure during cloud sync operations.
class SyncFailure extends Failure {
  const SyncFailure({required super.message, super.code});
}

/// Failure during authentication (sign-in, sign-up, token refresh).
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});

  factory AuthFailure.invalidCredentials() =>
      const AuthFailure(message: 'Invalid email or password.', code: 'AUTH_001');

  factory AuthFailure.userNotFound() =>
      const AuthFailure(message: 'No user found with this email.', code: 'AUTH_002');

  factory AuthFailure.emailAlreadyInUse() =>
      const AuthFailure(message: 'This email is already registered.', code: 'AUTH_003');

  factory AuthFailure.tooManyRequests() =>
      const AuthFailure(message: 'Too many attempts. Please try again later.', code: 'AUTH_004');

  factory AuthFailure.networkError() =>
      const AuthFailure(message: 'Network error. Check your connection.', code: 'AUTH_005');

  factory AuthFailure.sessionExpired() =>
      const AuthFailure(message: 'Session expired. Please sign in again.', code: 'AUTH_006');
}

/// Failure during AI-powered operations (Gemini summarization, categorization).
class AIFailure extends Failure {
  const AIFailure({required super.message, super.code});

  factory AIFailure.rateLimited() =>
      const AIFailure(message: 'AI request limit reached. Try again later.', code: 'AI_001');

  factory AIFailure.quotaExceeded() =>
      const AIFailure(message: 'AI quota exceeded for today.', code: 'AI_002');

  factory AIFailure.invalidResponse() =>
      const AIFailure(message: 'Received an invalid AI response.', code: 'AI_003');

  factory AIFailure.timeout() =>
      const AIFailure(message: 'AI request timed out.', code: 'AI_004');
}

/// Failure related to security (biometric, pin lock, encryption).
class SecurityFailure extends Failure {
  const SecurityFailure({required super.message, super.code});

  factory SecurityFailure.biometricNotAvailable() =>
      const SecurityFailure(
          message: 'Biometric authentication is not available on this device.',
          code: 'SEC_001');

  factory SecurityFailure.biometricNotEnrolled() =>
      const SecurityFailure(
          message: 'No biometrics enrolled. Set up fingerprint or face ID first.',
          code: 'SEC_002');

  factory SecurityFailure.authenticationFailed() =>
      const SecurityFailure(
          message: 'Authentication failed. Please try again.',
          code: 'SEC_003');

  factory SecurityFailure.encryptionError() =>
      const SecurityFailure(
          message: 'Failed to encrypt or decrypt data.',
          code: 'SEC_004');
}

/// Generic server-side failure for unexpected HTTP errors.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Failure when the device has no network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});

  factory NetworkFailure.noConnection() =>
      const NetworkFailure(message: 'No internet connection available.', code: 'NET_001');
}

/// Failure when a requested resource or cache entry is not found.
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}
