import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/security_settings_model.dart';

/// Stub biometric type (replaces local_auth BiometricType).
enum BiometricType {
  fingerprint,
  face,
  iris,
  weak,
  strong,
}

/// Local data source for security settings and operations using
/// [SharedPreferences] for storage, simple base64 encoding instead
/// of AES encryption, and stub biometric authentication.
///
/// Handles PIN hashing, biometric availability checks, base64
/// encoding/decryption, and storage of all security data.
class SecurityLocalDatasource {
  SecurityLocalDatasource({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  final SharedPreferences _prefs;

  // ── Storage Keys ─────────────────────────────────────────────────────

  static const String _settingsKey = 'security_settings';
  static const String _pinHashKey = AppConstants.secureStoragePinKey;
  static const String _biometricKey = AppConstants.secureStorageBiometricKey;
  static const String _encryptionKeyKey =
      AppConstants.secureStorageEncryptionKey;
  static const String _failedAttemptsKey = 'pin_failed_attempts';
  static const String _lockoutTimestampKey = 'pin_lockout_timestamp';
  static const String _isLockedKey = 'app_is_locked';

  // ── Settings CRUD ───────────────────────────────────────────────────

  /// Retrieves the security settings from storage.
  ///
  /// Returns a default [SecuritySettingsModel] if none are stored.
  Future<SecuritySettingsModel> getSecuritySettings() async {
    try {
      final raw = _prefs.getString(_settingsKey);
      if (raw == null) {
        return const SecuritySettingsModel();
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return SecuritySettingsModel.fromJson(json);
    } catch (e) {
      throw CacheException(
        message: 'Failed to read security settings: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Persists [SecuritySettingsModel] to storage.
  Future<void> saveSecuritySettings(SecuritySettingsModel settings) async {
    try {
      final json = jsonEncode(settings.toJson());
      await _prefs.setString(_settingsKey, json);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save security settings: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── PIN Operations ──────────────────────────────────────────────────

  /// Hashes a PIN using base64 encoding (simple stub).
  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return base64Encode(bytes);
  }

  /// Stores a hashed PIN in storage.
  Future<void> savePinHash(String pin) async {
    try {
      final hash = hashPin(pin);
      await _prefs.setString(_pinHashKey, hash);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save PIN: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Reads the stored PIN hash.
  ///
  /// Returns `null` if no PIN is set.
  Future<String?> getPinHash() async {
    try {
      return _prefs.getString(_pinHashKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to read PIN: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Deletes the stored PIN hash.
  Future<void> deletePinHash() async {
    try {
      await _prefs.remove(_pinHashKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete PIN: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── Failed Attempts & Lockout ───────────────────────────────────────

  /// Records a failed PIN attempt.
  Future<void> recordFailedAttempt() async {
    try {
      final current = await getFailedAttempts();
      await _prefs.setInt(_failedAttemptsKey, current + 1);
      await _prefs.setString(
        _lockoutTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to record attempt: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Gets the number of consecutive failed PIN attempts.
  Future<int> getFailedAttempts() async {
    try {
      return _prefs.getInt(_failedAttemptsKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Resets the failed attempt counter.
  Future<void> resetFailedAttempts() async {
    try {
      await _prefs.remove(_failedAttemptsKey);
      await _prefs.remove(_lockoutTimestampKey);
    } catch (e) {
      // Silently ignore reset failures.
    }
  }

  /// Whether the user is currently locked out.
  Future<bool> isLockedOut() async {
    final attempts = await getFailedAttempts();
    if (attempts < AppConstants.maxPinAttempts) return false;

    final lockoutStr = _prefs.getString(_lockoutTimestampKey);
    if (lockoutStr == null) return false;

    final lockoutTime = DateTime.tryParse(lockoutStr);
    if (lockoutTime == null) return false;

    final elapsed = DateTime.now().difference(lockoutTime);
    return elapsed < Duration(minutes: AppConstants.lockoutDurationMinutes);
  }

  // ── Biometric Operations (stub – always returns true) ───────────────

  /// Checks whether the device supports biometric authentication.
  /// Stub: always returns true.
  Future<bool> isBiometricAvailable() async {
    return true;
  }

  /// Returns the list of available biometric types.
  /// Stub: returns fingerprint as available.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return [BiometricType.fingerprint];
  }

  /// Shows the biometric authentication prompt.
  /// Stub: always returns true.
  Future<bool> authenticateWithBiometric() async {
    return true;
  }

  /// Stores whether biometric is enabled.
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _prefs.setBool(_biometricKey, enabled);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save biometric setting: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ── App Lock ────────────────────────────────────────────────────────

  /// Sets the app lock state.
  Future<void> setAppLocked(bool locked) async {
    try {
      await _prefs.setBool(_isLockedKey, locked);
    } catch (e) {
      throw CacheException(
        message: 'Failed to set app lock state: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Gets the app lock state.
  Future<bool> isAppLocked() async {
    try {
      return _prefs.getBool(_isLockedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // ── Encoding Operations (base64 stub replacing AES-256) ──────────────

  /// Gets or creates the encoding key (stub – returns a fixed key).
  Future<String> getOrCreateEncryptionKey() async {
    try {
      var key = _prefs.getString(_encryptionKeyKey);
      if (key == null) {
        // Generate a simple base64 key.
        final bytes = List<int>.generate(32, (i) => i);
        key = base64Encode(bytes);
        await _prefs.setString(_encryptionKeyKey, key);
      }
      return key;
    } catch (e) {
      throw SecurityException.encryptionError();
    }
  }

  /// Encodes [plainText] using base64 (replaces AES-256 encryption).
  ///
  /// Returns a base64-encoded string.
  Future<String> encryptData(String plainText) async {
    try {
      final bytes = utf8.encode(plainText);
      return base64Encode(bytes);
    } catch (e) {
      throw SecurityException.encryptionError();
    }
  }

  /// Decodes [cipherText] using base64 (replaces AES-256 decryption).
  Future<String> decryptData(String cipherText) async {
    try {
      final decoded = base64Decode(cipherText);
      return utf8.decode(decoded);
    } catch (e) {
      throw SecurityException.encryptionError();
    }
  }

  /// Deletes the stored encoding key.
  Future<void> deleteEncryptionKey() async {
    try {
      await _prefs.remove(_encryptionKeyKey);
    } catch (e) {
      throw SecurityException.encryptionError();
    }
  }
}
