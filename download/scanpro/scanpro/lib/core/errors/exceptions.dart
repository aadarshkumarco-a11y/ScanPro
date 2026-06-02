/// Exception classes for data-layer errors in ScanPro.
///
/// Exceptions are thrown in the data layer and caught by repository
/// implementations, which convert them into the corresponding
/// [Failure] objects for the domain layer.
library;

/// Base exception class for all ScanPro-specific exceptions.
abstract class AppException implements Exception {
  /// Human-readable description of the exception.
  final String message;

  /// Optional machine-readable error code.
  final String? code;

  /// Optional original error that caused this exception.
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => '$runtimeType: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception during document scanning operations.
class ScannerException extends AppException {
  const ScannerException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory ScannerException.cameraError([dynamic error]) =>
      ScannerException(message: 'Camera error occurred.', code: 'SCAN_001', originalError: error);

  factory ScannerException.edgeDetectionFailed([dynamic error]) =>
      ScannerException(message: 'Edge detection failed.', code: 'SCAN_002', originalError: error);

  factory ScannerException.cropFailed([dynamic error]) =>
      ScannerException(message: 'Image cropping failed.', code: 'SCAN_003', originalError: error);

  factory ScannerException.permissionDenied() =>
      const ScannerException(message: 'Camera permission denied.', code: 'SCAN_004');
}

/// Exception during OCR text extraction.
class OCRException extends AppException {
  const OCRException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory OCRException.recognitionFailed([dynamic error]) =>
      OCRException(message: 'Text recognition failed.', code: 'OCR_001', originalError: error);

  factory OCRException.noTextFound() =>
      const OCRException(message: 'No text detected in the image.', code: 'OCR_002');

  factory OCRException.languageNotSupported(String language) =>
      OCRException(message: 'Language "$language" is not supported.', code: 'OCR_003');
}

/// Exception during PDF generation or manipulation.
class PDFException extends AppException {
  const PDFException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory PDFException.generationFailed([dynamic error]) =>
      PDFException(message: 'PDF generation failed.', code: 'PDF_001', originalError: error);

  factory PDFException.mergeFailed([dynamic error]) =>
      PDFException(message: 'PDF merge failed.', code: 'PDF_002', originalError: error);

  factory PDFException.corruptedFile(String path) =>
      PDFException(message: 'Corrupted PDF file: $path', code: 'PDF_003');

  factory PDFException.passwordProtected(String path) =>
      PDFException(message: 'Password-protected PDF: $path', code: 'PDF_004');
}

/// Exception during cloud sync operations.
class SyncException extends AppException {
  const SyncException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory SyncException.uploadFailed([dynamic error]) =>
      SyncException(message: 'Upload failed.', code: 'SYNC_001', originalError: error);

  factory SyncException.downloadFailed([dynamic error]) =>
      SyncException(message: 'Download failed.', code: 'SYNC_002', originalError: error);

  factory SyncException.conflictDetected() =>
      const SyncException(message: 'Sync conflict detected.', code: 'SYNC_003');

  factory SyncException.quotaExceeded() =>
      const SyncException(message: 'Cloud storage quota exceeded.', code: 'SYNC_004');
}

/// Exception during authentication operations.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AuthException.invalidCredentials([dynamic error]) =>
      AuthException(message: 'Invalid credentials.', code: 'AUTH_001', originalError: error);

  factory AuthException.userNotFound([dynamic error]) =>
      AuthException(message: 'User not found.', code: 'AUTH_002', originalError: error);

  factory AuthException.emailInUse([dynamic error]) =>
      AuthException(message: 'Email already in use.', code: 'AUTH_003', originalError: error);
}

/// Exception during AI-powered operations.
class AIException extends AppException {
  const AIException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AIException.requestFailed([dynamic error]) =>
      AIException(message: 'AI request failed.', code: 'AI_001', originalError: error);

  factory AIException.invalidResponse([dynamic error]) =>
      AIException(message: 'Invalid AI response.', code: 'AI_002', originalError: error);

  factory AIException.rateLimited() =>
      const AIException(message: 'AI rate limit exceeded.', code: 'AI_003');
}

/// Exception during security operations.
class SecurityException extends AppException {
  const SecurityException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory SecurityException.biometricFailed([dynamic error]) =>
      SecurityException(message: 'Biometric auth failed.', code: 'SEC_001', originalError: error);

  factory SecurityException.encryptionFailed([dynamic error]) =>
      SecurityException(message: 'Encryption failed.', code: 'SEC_002', originalError: error);
}

/// Exception for server-side errors.
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });
}

/// Exception for network connectivity issues.
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory NetworkException.noConnection() =>
      const NetworkException(message: 'No internet connection.', code: 'NET_001');
}

/// Exception for local cache read/write failures.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory CacheException.readError([dynamic error]) =>
      CacheException(message: 'Cache read error.', code: 'CACHE_001', originalError: error);

  factory CacheException.writeError([dynamic error]) =>
      CacheException(message: 'Cache write error.', code: 'CACHE_002', originalError: error);
}
