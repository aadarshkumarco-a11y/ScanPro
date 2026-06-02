import 'package:equatable/equatable.dart';

/// Enumeration of supported lock types.
enum LockType {
  /// Numeric PIN code authentication.
  pin,

  /// Biometric authentication (fingerprint, face).
  biometric,

  /// Requires both PIN and biometric.
  both,
}

/// Entity representing the security lock configuration.
///
/// Controls the app-level authentication requirements including
/// lock type, failed attempt tracking, and timing.
class LockConfig extends Equatable {
  /// Whether the app lock feature is enabled.
  final bool isEnabled;

  /// Type of lock authentication required.
  final LockType lockType;

  /// Number of consecutive failed authentication attempts.
  final int failedAttempts;

  /// Timestamp of the last successful unlock, null if never unlocked.
  final DateTime? lastUnlockedAt;

  const LockConfig({
    this.isEnabled = false,
    this.lockType = LockType.pin,
    this.failedAttempts = 0,
    this.lastUnlockedAt,
  });

  /// Maximum allowed failed attempts before lockout.
  static const int maxFailedAttempts = 5;

  /// Whether the app is currently in a lockout state due to too many failures.
  bool get isLockedOut => failedAttempts >= maxFailedAttempts;

  /// Whether biometric authentication is available for this config.
  bool get usesBiometric =>
      lockType == LockType.biometric || lockType == LockType.both;

  /// Whether PIN authentication is required for this config.
  bool get usesPin =>
      lockType == LockType.pin || lockType == LockType.both;

  /// Duration since the last successful unlock.
  /// Returns null if never unlocked.
  Duration? get timeSinceLastUnlock {
    if (lastUnlockedAt == null) return null;
    return DateTime.now().difference(lastUnlockedAt!);
  }

  /// Whether the lock should be shown based on the timeout duration.
  bool shouldShowLock({Duration timeout = const Duration(minutes: 5}) {
    if (!isEnabled) return false;
    if (lastUnlockedAt == null) return true;
    return DateTime.now().difference(lastUnlockedAt!) > timeout;
  }

  /// Creates a copy with optional field overrides.
  LockConfig copyWith({
    bool? isEnabled,
    LockType? lockType,
    int? failedAttempts,
    DateTime? lastUnlockedAt,
  }) {
    return LockConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      lockType: lockType ?? this.lockType,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lastUnlockedAt: lastUnlockedAt ?? this.lastUnlockedAt,
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        lockType,
        failedAttempts,
        lastUnlockedAt,
      ];
}
