import 'package:equatable/equatable.dart';

/// Domain entity representing the user's security and privacy settings.
///
/// Holds all security-related configuration including biometric auth,
/// PIN lock, app lock behaviour, vault settings, and encryption state.
class SecuritySettings extends Equatable {
  const SecuritySettings({
    this.isBiometricEnabled = false,
    this.isPinEnabled = false,
    this.pin,
    this.isAppLockEnabled = false,
    this.autoLockDuration = const Duration(minutes: 5),
    this.isVaultEnabled = false,
    this.encryptionKey,
    this.lastUnlockedAt,
  });

  /// Whether biometric authentication (fingerprint / face) is enabled.
  final bool isBiometricEnabled;

  /// Whether PIN lock is enabled.
  final bool isPinEnabled;

  /// The hashed PIN value, stored securely. `null` when PIN is not set.
  final String? pin;

  /// Whether the app locks when sent to the background.
  final bool isAppLockEnabled;

  /// Duration of inactivity before the app auto-locks.
  final Duration autoLockDuration;

  /// Whether the secure vault feature is enabled for locked documents.
  final bool isVaultEnabled;

  /// AES-256 encryption key for the vault. Stored in flutter_secure_storage.
  final String? encryptionKey;

  /// Timestamp of the last successful unlock.
  final DateTime? lastUnlockedAt;

  /// Whether the user has completed any security setup.
  bool get hasSecuritySetup => isPinEnabled || isBiometricEnabled;

  /// Whether the app should currently be locked based on auto-lock timeout.
  bool get shouldAutoLock {
    if (!isAppLockEnabled || lastUnlockedAt == null) return isAppLockEnabled;
    final elapsed = DateTime.now().difference(lastUnlockedAt!);
    return elapsed >= autoLockDuration;
  }

  /// Creates a copy with optional field overrides.
  SecuritySettings copyWith({
    bool? isBiometricEnabled,
    bool? isPinEnabled,
    String? pin,
    bool? isAppLockEnabled,
    Duration? autoLockDuration,
    bool? isVaultEnabled,
    String? encryptionKey,
    DateTime? lastUnlockedAt,
  }) {
    return SecuritySettings(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      pin: pin ?? this.pin,
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      autoLockDuration: autoLockDuration ?? this.autoLockDuration,
      isVaultEnabled: isVaultEnabled ?? this.isVaultEnabled,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      lastUnlockedAt: lastUnlockedAt ?? this.lastUnlockedAt,
    );
  }

  @override
  List<Object?> get props => [
        isBiometricEnabled,
        isPinEnabled,
        pin,
        isAppLockEnabled,
        autoLockDuration,
        isVaultEnabled,
        encryptionKey,
        lastUnlockedAt,
      ];
}
