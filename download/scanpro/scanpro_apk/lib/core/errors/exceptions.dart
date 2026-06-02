/// Exception classes for ScanPro.
///
/// Exceptions represent data-layer / platform-level errors.
/// Repository implementations catch these and convert them to
/// the corresponding [Failure] subclass for the domain layer.
///
/// Convention: each Exception mirrors a Failure with the same prefix.
/// For example, [ServerException] → `ServerFailure`.

// ── Server ────────────────────────────────────────────────────────

/// Exception thrown when a remote API call fails.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseBody;

  const ServerException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() =>
      'ServerException(message: $message, statusCode: $statusCode)';
}

// ── Cache ─────────────────────────────────────────────────────────

/// Exception thrown when a local cache / storage operation fails.
class CacheException implements Exception {
  final String message;
  final int? code;

  const CacheException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'CacheException(message: $message, code: $code)';
}

// ── Network ───────────────────────────────────────────────────────

/// Exception thrown when there is no network connectivity or
/// a network-level error occurs (timeouts, DNS, SSL, etc.).
class NetworkException implements Exception {
  final String message;
  final int? code;
  final bool isTimeout;
  final bool isNoConnection;

  const NetworkException({
    required this.message,
    this.code,
    this.isTimeout = false,
    this.isNoConnection = false,
  });

  /// Convenience factory for when the device has no connectivity.
  factory NetworkException.noConnection() => const NetworkException(
        message: 'No internet connection available.',
        isNoConnection: true,
        code: 2001,
      );

  /// Convenience factory for connection timeouts.
  factory NetworkException.timeout() => const NetworkException(
        message: 'Connection timed out.',
        isTimeout: true,
        code: 2002,
      );

  @override
  String toString() =>
      'NetworkException(message: $message, code: $code, '
      'isTimeout: $isTimeout, isNoConnection: $isNoConnection)';
}

// ── OCR ───────────────────────────────────────────────────────────

/// Exception thrown during OCR text extraction or processing.
class OcrException implements Exception {
  final String message;
  final int? code;
  final double? confidence;

  const OcrException({
    required this.message,
    this.code,
    this.confidence,
  });

  /// Factory when no text is detected in the image.
  factory OcrException.noTextDetected() => const OcrException(
        message: 'No text could be detected in the image.',
        code: 3001,
      );

  /// Factory when detected text confidence is below threshold.
  factory OcrException.lowConfidence(double confidence) => OcrException(
        message: 'Text detection confidence is too low.',
        code: 3002,
        confidence: confidence,
      );

  @override
  String toString() =>
      'OcrException(message: $message, code: $code, confidence: $confidence)';
}

// ── PDF ───────────────────────────────────────────────────────────

/// Exception thrown during PDF operations (create, merge, split, compress).
class PdfException implements Exception {
  final String message;
  final int? code;
  final String? filePath;

  const PdfException({
    required this.message,
    this.code,
    this.filePath,
  });

  /// Factory for invalid / corrupted PDF files.
  factory PdfException.invalidFile([String? path]) => PdfException(
        message: 'The PDF file is invalid or corrupted.',
        code: 4005,
        filePath: path,
      );

  /// Factory for password-protected PDFs.
  factory PdfException.passwordProtected([String? path]) => PdfException(
        message: 'The PDF is password protected.',
        code: 4006,
        filePath: path,
      );

  /// Factory when a requested page index is out of range.
  factory PdfException.pageOutOfRange(int page, int total) => PdfException(
        message: 'Page $page is out of range (total: $total).',
        code: 4007,
      );

  @override
  String toString() =>
      'PdfException(message: $message, code: $code, filePath: $filePath)';
}

// ── Security ──────────────────────────────────────────────────────

/// Exception thrown during security-related operations
/// (PIN, biometrics, encryption, secure storage).
class SecurityException implements Exception {
  final String message;
  final int? code;

  const SecurityException({
    required this.message,
    this.code,
  });

  /// Factory for incorrect PIN attempts.
  factory SecurityException.incorrectPin() => const SecurityException(
        message: 'Incorrect PIN entered.',
        code: 5001,
      );

  /// Factory when the user is locked out after too many attempts.
  factory SecurityException.lockedOut() => const SecurityException(
        message: 'Too many failed attempts. Please try again later.',
        code: 5002,
      );

  /// Factory when biometric hardware is unavailable.
  factory SecurityException.biometricNotAvailable() => const SecurityException(
        message: 'Biometric authentication is not available on this device.',
        code: 5003,
      );

  /// Factory when biometric authentication fails.
  factory SecurityException.biometricFailed() => const SecurityException(
        message: 'Biometric authentication failed.',
        code: 5005,
      );

  /// Factory for encryption / decryption failures.
  factory SecurityException.encryptionError() => const SecurityException(
        message: 'Failed to encrypt or decrypt data.',
        code: 5006,
      );

  @override
  String toString() => 'SecurityException(message: $message, code: $code)';
}

// ── Scanner ───────────────────────────────────────────────────────

/// Exception thrown during document scanning or camera operations.
class ScannerException implements Exception {
  final String message;
  final int? code;

  const ScannerException({
    required this.message,
    this.code,
  });

  /// Factory when camera permission is denied.
  factory ScannerException.cameraPermissionDenied() => const ScannerException(
        message: 'Camera permission is required to scan documents.',
        code: 6001,
      );

  /// Factory when the camera cannot be accessed.
  factory ScannerException.cameraError() => const ScannerException(
        message: 'Failed to access the camera.',
        code: 6002,
      );

  /// Factory when edge detection fails.
  factory ScannerException.edgeDetectionFailed() => const ScannerException(
        message: 'Could not detect document edges.',
        code: 6003,
      );

  @override
  String toString() => 'ScannerException(message: $message, code: $code)';
}

// ── Sync ──────────────────────────────────────────────────────────

/// Exception thrown during cloud synchronisation operations.
class SyncException implements Exception {
  final String message;
  final int? code;

  const SyncException({
    required this.message,
    this.code,
  });

  /// Factory when a conflict is detected between local and remote.
  factory SyncException.conflict() => const SyncException(
        message: 'A sync conflict was detected.',
        code: 7001,
      );

  /// Factory when an upload fails.
  factory SyncException.uploadFailed() => const SyncException(
        message: 'Failed to upload document to cloud.',
        code: 7002,
      );

  @override
  String toString() => 'SyncException(message: $message, code: $code)';
}

// ── Auth ──────────────────────────────────────────────────────────

/// Exception thrown during authentication operations.
class AuthException implements Exception {
  final String message;
  final int? code;

  const AuthException({
    required this.message,
    this.code,
  });

  /// Factory for invalid credentials.
  factory AuthException.invalidCredentials() => const AuthException(
        message: 'Invalid email or password.',
        code: 8001,
      );

  /// Factory when the session / token has expired.
  factory AuthException.tokenExpired() => const AuthException(
        message: 'Session has expired. Please sign in again.',
        code: 8004,
      );

  @override
  String toString() => 'AuthException(message: $message, code: $code)';
}

// ── AI ────────────────────────────────────────────────────────────

/// Exception thrown during AI feature requests.
class AIException implements Exception {
  final String message;
  final int? code;

  const AIException({
    required this.message,
    this.code,
  });

  /// Factory for when the AI request fails entirely.
  factory AIException.requestFailed() => const AIException(
        message: 'AI request failed. Please try again.',
        code: 9001,
      );

  /// Factory for rate-limit responses.
  factory AIException.rateLimited() => const AIException(
        message: 'AI request rate limit exceeded.',
        code: 9002,
      );

  /// Factory for request timeouts.
  factory AIException.timeout() => const AIException(
        message: 'AI request timed out.',
        code: 9003,
      );

  /// Factory for unexpected / malformed responses.
  factory AIException.invalidResponse() => const AIException(
        message: 'Received an invalid response from the AI service.',
        code: 9004,
      );

  @override
  String toString() => 'AIException(message: $message, code: $code)';
}

// ── Validation ────────────────────────────────────────────────────

/// Exception thrown when input validation fails.
class ValidationException implements Exception {
  final String message;
  final String? fieldName;
  final int? code;

  const ValidationException({
    required this.message,
    this.fieldName,
    this.code,
  });

  @override
  String toString() =>
      'ValidationException(message: $message, fieldName: $fieldName, '
      'code: $code)';
}
