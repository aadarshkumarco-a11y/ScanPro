import 'package:equatable/equatable.dart';

/// Base failure class representing a domain-level error.
///
/// All specific failures extend this class, carrying a human-readable
/// [message] and an optional machine-readable [code].
/// Uses [Equatable] for value comparison in tests and Riverpod state.
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  bool get stringify => true;
}

/// Failure originating from a remote server / API call.
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });

  /// Convenience factory for generic server errors.
  factory ServerFailure.unexpected({int? code}) => ServerFailure(
        message: 'An unexpected server error occurred.',
        code: code ?? 500,
      );

  /// Factory for 401 / 403 style responses.
  factory ServerFailure.unauthorized() => const ServerFailure(
        message: 'Authentication required.',
        code: 401,
      );

  /// Factory for 404 responses.
  factory ServerFailure.notFound() => const ServerFailure(
        message: 'The requested resource was not found.',
        code: 404,
      );

  /// Factory for rate-limited responses (429).
  factory ServerFailure.rateLimited() => const ServerFailure(
        message: 'Too many requests. Please try again later.',
        code: 429,
      );

  /// Factory for request timeouts (408).
  factory ServerFailure.timeout() => const ServerFailure(
        message: 'The request timed out. Please try again.',
        code: 408,
      );
}

/// Failure originating from local cache / storage operations.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });

  factory CacheFailure.notFound() => const CacheFailure(
        message: 'Cached data not found.',
        code: 1001,
      );

  factory CacheFailure.writeError() => const CacheFailure(
        message: 'Failed to write data to cache.',
        code: 1002,
      );

  factory CacheFailure.readError() => const CacheFailure(
        message: 'Failed to read data from cache.',
        code: 1003,
      );

  factory CacheFailure.corrupted() => const CacheFailure(
        message: 'Cached data is corrupted.',
        code: 1004,
      );
}

/// Failure caused by network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });

  factory NetworkFailure.noConnection() => const NetworkFailure(
        message: 'No internet connection available.',
        code: 2001,
      );

  factory NetworkFailure.connectionTimeout() => const NetworkFailure(
        message: 'Connection timed out.',
        code: 2002,
      );

  factory NetworkFailure.serverUnreachable() => const NetworkFailure(
        message: 'Unable to reach the server.',
        code: 2003,
      );

  factory NetworkFailure.sslError() => const NetworkFailure(
        message: 'Secure connection failed.',
        code: 2004,
      );
}

/// Failure during OCR text extraction or processing.
class OcrFailure extends Failure {
  const OcrFailure({
    required super.message,
    super.code,
  });

  factory OcrFailure.noTextDetected() => const OcrFailure(
        message: 'No text could be detected in the image.',
        code: 3001,
      );

  factory OcrFailure.lowConfidence() => const OcrFailure(
        message: 'Text detection confidence is too low.',
        code: 3002,
      );

  factory OcrFailure.languageNotSupported() => const OcrFailure(
        message: 'The detected language is not supported.',
        code: 3003,
      );

  factory OcrFailure.processingError() => const OcrFailure(
        message: 'Failed to process the image for OCR.',
        code: 3004,
      );

  factory OcrFailure.fileTooLarge() => const OcrFailure(
        message: 'Image file is too large for OCR processing.',
        code: 3005,
      );
}

/// Failure during PDF creation, merge, split, or compression.
class PdfFailure extends Failure {
  const PdfFailure({
    required super.message,
    super.code,
  });

  factory PdfFailure.creationError() => const PdfFailure(
        message: 'Failed to create PDF document.',
        code: 4001,
      );

  factory PdfFailure.mergeError() => const PdfFailure(
        message: 'Failed to merge PDF documents.',
        code: 4002,
      );

  factory PdfFailure.splitError() => const PdfFailure(
        message: 'Failed to split PDF document.',
        code: 4003,
      );

  factory PdfFailure.compressionError() => const PdfFailure(
        message: 'Failed to compress PDF document.',
        code: 4004,
      );

  factory PdfFailure.invalidFile() => const PdfFailure(
        message: 'The PDF file is invalid or corrupted.',
        code: 4005,
      );

  factory PdfFailure.passwordProtected() => const PdfFailure(
        message: 'The PDF is password protected.',
        code: 4006,
      );

  factory PdfFailure.pageOutOfRange() => const PdfFailure(
        message: 'Requested page is out of range.',
        code: 4007,
      );
}

/// Failure related to security operations (PIN, biometrics, encryption).
class SecurityFailure extends Failure {
  const SecurityFailure({
    required super.message,
    super.code,
  });

  factory SecurityFailure.incorrectPin() => const SecurityFailure(
        message: 'Incorrect PIN entered.',
        code: 5001,
      );

  factory SecurityFailure.pinLockedOut() => const SecurityFailure(
        message: 'Too many failed attempts. Please try again later.',
        code: 5002,
      );

  factory SecurityFailure.biometricNotAvailable() => const SecurityFailure(
        message: 'Biometric authentication is not available on this device.',
        code: 5003,
      );

  factory SecurityFailure.biometricNotEnrolled() => const SecurityFailure(
        message: 'No biometrics enrolled on this device.',
        code: 5004,
      );

  factory SecurityFailure.biometricFailed() => const SecurityFailure(
        message: 'Biometric authentication failed.',
        code: 5005,
      );

  factory SecurityFailure.encryptionError() => const SecurityFailure(
        message: 'Failed to encrypt or decrypt data.',
        code: 5006,
      );

  factory SecurityFailure.keyNotFound() => const SecurityFailure(
        message: 'Encryption key not found.',
        code: 5007,
      );

  factory SecurityFailure.pinNotSet() => const SecurityFailure(
        message: 'PIN has not been set up.',
        code: 5008,
      );
}

/// Failure during document scanning or image processing.
class ScannerFailure extends Failure {
  const ScannerFailure({
    required super.message,
    super.code,
  });

  factory ScannerFailure.cameraPermissionDenied() => const ScannerFailure(
        message: 'Camera permission is required to scan documents.',
        code: 6001,
      );

  factory ScannerFailure.cameraError() => const ScannerFailure(
        message: 'Failed to access the camera.',
        code: 6002,
      );

  factory ScannerFailure.edgeDetectionFailed() => const ScannerFailure(
        message: 'Could not detect document edges.',
        code: 6003,
      );

  factory ScannerFailure.imageProcessingError() => const ScannerFailure(
        message: 'Failed to process the scanned image.',
        code: 6004,
      );

  factory ScannerFailure.noDocumentFound() => const ScannerFailure(
        message: 'No document detected in the frame.',
        code: 6005,
      );
}

/// Failure during cloud synchronisation.
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code,
  });

  factory SyncFailure.conflictDetected() => const SyncFailure(
        message: 'A sync conflict was detected.',
        code: 7001,
      );

  factory SyncFailure.uploadFailed() => const SyncFailure(
        message: 'Failed to upload document to cloud.',
        code: 7002,
      );

  factory SyncFailure.downloadFailed() => const SyncFailure(
        message: 'Failed to download document from cloud.',
        code: 7003,
      );

  factory SyncFailure.storageLimitExceeded() => const SyncFailure(
        message: 'Cloud storage limit exceeded.',
        code: 7004,
      );

  factory SyncFailure.authExpired() => const SyncFailure(
        message: 'Cloud authentication has expired.',
        code: 7005,
      );
}

/// Failure during authentication (sign in / sign up / token refresh).
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid email or password.',
        code: 8001,
      );

  factory AuthFailure.emailAlreadyInUse() => const AuthFailure(
        message: 'This email is already registered.',
        code: 8002,
      );

  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Password is too weak.',
        code: 8003,
      );

  factory AuthFailure.tokenExpired() => const AuthFailure(
        message: 'Session has expired. Please sign in again.',
        code: 8004,
      );

  factory AuthFailure.accountDisabled() => const AuthFailure(
        message: 'This account has been disabled.',
        code: 8005,
      );
}

/// Failure from AI feature requests (Gemini, summarization, extraction).
class AIFailure extends Failure {
  const AIFailure({
    required super.message,
    super.code,
  });

  factory AIFailure.requestFailed() => const AIFailure(
        message: 'AI request failed. Please try again.',
        code: 9001,
      );

  factory AIFailure.rateLimited() => const AIFailure(
        message: 'AI request rate limit exceeded. Please wait and retry.',
        code: 9002,
      );

  factory AIFailure.timeout() => const AIFailure(
        message: 'AI request timed out.',
        code: 9003,
      );

  factory AIFailure.invalidResponse() => const AIFailure(
        message: 'Received an invalid response from the AI service.',
        code: 9004,
      );

  factory AIFailure.quotaExceeded() => const AIFailure(
        message: 'AI usage quota has been exceeded.',
        code: 9005,
      );
}

/// Failure caused by invalid input that fails validation.
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });

  factory ValidationFailure.emptyField(String fieldName) =>
      ValidationFailure(
        message: '$fieldName cannot be empty.',
        code: 10001,
      );

  factory ValidationFailure.invalidFormat(String fieldName) =>
      ValidationFailure(
        message: '$fieldName has an invalid format.',
        code: 10002,
      );

  factory ValidationFailure.outOfRange(String fieldName) => ValidationFailure(
        message: '$fieldName is out of the allowed range.',
        code: 10003,
      );

  factory ValidationFailure.tooShort(String fieldName, int minLength) =>
      ValidationFailure(
        message: '$fieldName must be at least $minLength characters.',
        code: 10004,
      );

  factory ValidationFailure.tooLong(String fieldName, int maxLength) =>
      ValidationFailure(
        message: '$fieldName must be at most $maxLength characters.',
        code: 10005,
      );
}

/// Failure when a requested resource does not exist.
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
  });

  factory NotFoundFailure.document() => const NotFoundFailure(
        message: 'Document not found.',
        code: 11001,
      );

  factory NotFoundFailure.folder() => const NotFoundFailure(
        message: 'Folder not found.',
        code: 11002,
      );

  factory NotFoundFailure.file() => const NotFoundFailure(
        message: 'File not found.',
        code: 11003,
      );

  factory NotFoundFailure.user() => const NotFoundFailure(
        message: 'User not found.',
        code: 11004,
      );
}
