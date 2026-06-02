/// Input validation utilities for ScanPro.
///
/// Provides static validators for email, password, name, and
/// file name inputs. Each validator returns `null` for valid
/// input or an error message string for invalid input.
library;

import '../constants/app_constants.dart';

/// Utility class for form field validation.
class Validators {
  Validators._();

  /// Validates an email address.
  ///
  /// Returns `null` if valid, or an error message.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  /// Validates a password.
  ///
  /// Requires at least 8 characters, one letter, and one digit.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Password must contain at least one letter.';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one digit.';
    }
    return null;
  }

  /// Validates a confirm-password field against the original password.
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != originalPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }

  /// Validates a person's name.
  ///
  /// Allows letters, spaces, hyphens, and apostrophes.
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    if (value.trim().length > 60) {
      return 'Name must be at most 60 characters.';
    }
    final regex = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ' -]{2,60}$");
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid name.';
    }
    return null;
  }

  /// Validates a document or folder name.
  static String? documentName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.trim().length > AppConstants.maxDocumentNameLength) {
      return 'Name must be at most ${AppConstants.maxDocumentNameLength} characters.';
    }
    final forbidden = RegExp(r'[<>:"/\\|?*\x00-\x1F]');
    if (forbidden.hasMatch(value)) {
      return 'Name contains invalid characters.';
    }
    return null;
  }

  /// Validates a folder name.
  static String? folderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Folder name is required.';
    }
    if (value.trim().length > 80) {
      return 'Folder name must be at most 80 characters.';
    }
    final forbidden = RegExp(r'[<>:"/\\|?*\x00-\x1F]');
    if (forbidden.hasMatch(value)) {
      return 'Folder name contains invalid characters.';
    }
    if (value.trim() == '.' || value.trim() == '..') {
      return 'Invalid folder name.';
    }
    return null;
  }

  /// Validates a tag name.
  static String? tagName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tag name is required.';
    }
    if (value.trim().length > AppConstants.maxTagNameLength) {
      return 'Tag must be at most ${AppConstants.maxTagNameLength} characters.';
    }
    return null;
  }

  /// Validates a file name (not a full path).
  static String? fileName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'File name is required.';
    }
    final forbidden = RegExp(r'[<>:"/\\|?*\x00-\x1F]');
    if (forbidden.hasMatch(value)) {
      return 'File name contains invalid characters.';
    }
    if (value.endsWith('.') || value.endsWith(' ')) {
      return 'File name cannot end with a dot or space.';
    }
    return null;
  }

  /// Validates a required (non-empty) field.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// Validates a PIN code (4–6 digits).
  static String? pinCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required.';
    }
    if (!RegExp(r'^\d{4,6}$').hasMatch(value)) {
      return 'PIN must be 4 to 6 digits.';
    }
    return null;
  }

  /// Composes multiple validators, returning the first error or null.
  static String? compose(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}
