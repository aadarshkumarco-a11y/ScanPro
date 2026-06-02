/// Input validation utilities for ScanPro.
///
/// Every validator returns `null` when the value is valid,
/// or a localised error string when invalid – the convention
/// expected by Flutter's [TextFormField.validator].
class Validators {
  Validators._();

  // ── Email ───────────────────────────────────────────────────────

  /// Validates an email address.
  ///
  /// Returns `null` if valid, otherwise an error message.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Comprehensive RFC-5322-ish regex (covers 99 % of real-world addresses).
    final regex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@'
      r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?'
      r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
    );
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ── Password ────────────────────────────────────────────────────

  /// Validates a password with optional complexity rules.
  ///
  /// [minLength] – minimum number of characters (default 8).
  /// [requireUppercase] – at least one upper-case letter.
  /// [requireLowercase] – at least one lower-case letter.
  /// [requireDigit] – at least one digit.
  /// [requireSpecialChar] – at least one special character.
  static String? password(
    String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecialChar = true,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (requireDigit && !RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }
    if (requireSpecialChar &&
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validates that two passwords match.
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ── Phone ───────────────────────────────────────────────────────

  /// Validates a phone number.
  ///
  /// Accepts digits, spaces, hyphens, parentheses, and a leading `+`.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Strip formatting characters to count actual digits.
    final digitsOnly = value.replaceAll(RegExp(r'[^\d+]'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return 'Enter a valid phone number (7-15 digits)';
    }
    return null;
  }

  // ── Name ────────────────────────────────────────────────────────

  /// Validates a person's name.
  ///
  /// [minLength] – minimum number of characters (default 2).
  /// [maxLength] – maximum number of characters (default 50).
  static String? name(
    String? value, {
    int minLength = 2,
    int maxLength = 50,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < minLength) {
      return 'Name must be at least $minLength characters';
    }
    if (trimmed.length > maxLength) {
      return 'Name must be at most $maxLength characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(trimmed)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    return null;
  }

  // ── PIN ─────────────────────────────────────────────────────────

  /// Validates a numeric PIN code.
  ///
  /// [length] – expected PIN length (default 6 for ScanPro).
  static String? pin(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN must contain only digits';
    }
    if (value.length != length) {
      return 'PIN must be exactly $length digits';
    }
    // Reject trivially guessable PINs (all same digit, sequential).
    if (_isTrivialPin(value)) {
      return 'PIN is too simple. Choose a less obvious combination';
    }
    return null;
  }

  /// Returns `true` for trivially guessable PINs like 111111 or 123456.
  static bool _isTrivialPin(String pin) {
    // All digits the same (e.g. 000000, 111111).
    if (pin.split('').every((c) => c == pin[0])) return true;

    // Sequential ascending (012345, 123456, …).
    final ascending = List.generate(
      pin.length,
      (i) => ((int.parse(pin[0]) + i) % 10).toString(),
    ).join();
    if (pin == ascending) return true;

    // Sequential descending (987654, 543210, …).
    final descending = List.generate(
      pin.length,
      (i) => ((int.parse(pin[0]) - i) % 10).toString(),
    ).join();
    if (pin == descending) return true;

    return false;
  }

  // ── File Name ───────────────────────────────────────────────────

  /// Validates a file name for common issues.
  ///
  /// Checks for empty names, illegal characters, and reserved names.
  static String? fileName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'File name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length > 255) {
      return 'File name must be at most 255 characters';
    }
    // Illegal characters for most file systems.
    if (RegExp(r'[<>:"/\\|?*\x00-\x1F]').hasMatch(trimmed)) {
      return 'File name contains invalid characters';
    }
    // Reserved names on Windows (also avoided on mobile for compatibility).
    const reserved = {
      'CON', 'PRN', 'AUX', 'NUL',
      'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
      'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9',
    };
    if (reserved.contains(trimmed.toUpperCase().split('.').first)) {
      return 'This file name is reserved by the system';
    }
    // Cannot start or end with a space or period.
    if (trimmed.startsWith(' ') || trimmed.startsWith('.')) {
      return 'File name cannot start with a space or period';
    }
    if (trimmed.endsWith(' ') || trimmed.endsWith('.')) {
      return 'File name cannot end with a space or period';
    }
    return null;
  }

  // ── Folder Name ─────────────────────────────────────────────────

  /// Validates a folder name.
  static String? folderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Folder name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length > 100) {
      return 'Folder name must be at most 100 characters';
    }
    if (RegExp(r'[<>:"/\\|?*\x00-\x1F]').hasMatch(trimmed)) {
      return 'Folder name contains invalid characters';
    }
    if (trimmed == '.' || trimmed == '..') {
      return 'Invalid folder name';
    }
    return null;
  }

  // ── Required / Non-Empty ────────────────────────────────────────

  /// Generic non-empty validator.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ── URL ─────────────────────────────────────────────────────────

  /// Validates a URL (http / https).
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Enter a valid URL';
    }
    if (!['http', 'https'].contains(uri.scheme.toLowerCase())) {
      return 'URL must start with http:// or https://';
    }
    return null;
  }

  // ── Numeric ─────────────────────────────────────────────────────

  /// Validates that the value is a positive integer.
  static String? positiveInt(String? value, [String fieldName = 'Value']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final n = int.tryParse(value.trim());
    if (n == null) {
      return '$fieldName must be a whole number';
    }
    if (n <= 0) {
      return '$fieldName must be greater than zero';
    }
    return null;
  }

  /// Validates that the value is a number within [min] and [max].
  static String? numberRange(
    String? value, {
    required num min,
    required num max,
    String fieldName = 'Value',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final n = num.tryParse(value.trim());
    if (n == null) {
      return '$fieldName must be a number';
    }
    if (n < min || n > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }
}
