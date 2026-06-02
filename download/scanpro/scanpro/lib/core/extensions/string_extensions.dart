/// String extension methods for validation, formatting, and manipulation.
///
/// Provides reusable string operations commonly needed throughout
/// the ScanPro application for input validation and display formatting.
library;

extension StringExtensions on String {
  // ── Validation ────────────────────────────────────────────────

  /// Whether this string is a valid email address.
  bool get isValidEmail {
    final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');
    return regex.hasMatch(this);
  }

  /// Whether this string is a reasonably strong password
  /// (8+ chars, at least one letter and one digit).
  bool get isValidPassword {
    if (length < 8) return false;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(this);
    final hasDigit = RegExp(r'\d').hasMatch(this);
    return hasLetter && hasDigit;
  }

  /// Whether this string is a valid person name (letters, spaces, hyphens).
  bool get isValidName {
    final regex = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ' -]{2,60}$");
    return regex.hasMatch(this.trim());
  }

  /// Whether this string is a valid file name (no forbidden characters).
  bool get isValidFileName {
    final regex = RegExp(r'[<>:"/\\|?*\x00-\x1F]');
    return isNotEmpty && !regex.hasMatch(this);
  }

  /// Whether this string contains only digits.
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);

  // ── Formatting ────────────────────────────────────────────────

  /// Capitalizes the first letter of this string.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of every word.
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Converts this string to snake_case.
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// Converts this string to camelCase.
  String get toCamelCase {
    final parts = split(RegExp(r'[_\s]+'));
    if (parts.isEmpty) return this;
    return parts.first.toLowerCase() +
        parts.skip(1).map((p) => p.capitalize).join();
  }

  // ── Truncation ────────────────────────────────────────────────

  /// Truncates this string to [maxLength], appending an ellipsis if needed.
  String truncate(int maxLength, {String suffix = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Truncates in the middle, preserving start and end.
  String truncateMiddle(int maxLength, {String separator = '…'}) {
    if (length <= maxLength) return this;
    final available = maxLength - separator.length;
    final headLength = (available / 2).ceil();
    final tailLength = (available / 2).floor();
    return '${substring(0, headLength)}$separator${substring(length - tailLength)}';
  }

  // ── File Utilities ────────────────────────────────────────────

  /// The file extension without the dot (e.g., 'pdf').
  String get fileExtension {
    final dotIndex = lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == length - 1) return '';
    return substring(dotIndex + 1).toLowerCase();
  }

  /// The file name without extension.
  String get fileNameWithoutExtension {
    final dotIndex = lastIndexOf('.');
    final slashIndex = lastIndexOf('/');
    final name = slashIndex >= 0 ? substring(slashIndex + 1) : this;
    if (dotIndex <= slashIndex) return name;
    return name.substring(0, dotIndex - slashIndex - 1);
  }

  /// The file name including extension from a path.
  String get fileName {
    final slashIndex = lastIndexOf('/');
    if (slashIndex < 0) return this;
    return substring(slashIndex + 1);
  }

  // ── Conversion ────────────────────────────────────────────────

  /// Parses this string as a [double], returning [fallback] on failure.
  double toDoubleOrDefault([double fallback = 0.0]) {
    return double.tryParse(this) ?? fallback;
  }

  /// Parses this string as an [int], returning [fallback] on failure.
  int toIntOrDefault([int fallback = 0]) {
    return int.tryParse(this) ?? fallback;
  }

  /// Removes all whitespace from this string.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Whether this string is null or empty after trimming.
  bool get isBlank => trim().isEmpty;

  /// Whether this string is not blank.
  bool get isNotBlank => !isBlank;
}

/// Nullable string extension for safe access.
extension NullableStringExtensions on String? {
  /// Returns the string or [defaultValue] if null or empty.
  String orDefault([String defaultValue = '']) {
    if (this == null || this!.isEmpty) return defaultValue;
    return this!;
  }
}
