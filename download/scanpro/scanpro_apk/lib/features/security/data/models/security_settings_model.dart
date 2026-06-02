import 'package:scanpro/features/security/domain/entities/security_settings.dart';

/// Data model for [SecuritySettings], extending the domain entity with
/// JSON and Hive serialization support.
class SecuritySettingsModel extends SecuritySettings {
  const SecuritySettingsModel({
    super.isBiometricEnabled = false,
    super.isPinEnabled = false,
    super.pin,
    super.isAppLockEnabled = false,
    super.autoLockDuration = const Duration(minutes: 5),
    super.isVaultEnabled = false,
    super.encryptionKey,
    super.lastUnlockedAt,
  });

  /// Creates a [SecuritySettingsModel] from a domain [SecuritySettings] entity.
  factory SecuritySettingsModel.fromEntity(SecuritySettings entity) {
    return SecuritySettingsModel(
      isBiometricEnabled: entity.isBiometricEnabled,
      isPinEnabled: entity.isPinEnabled,
      pin: entity.pin,
      isAppLockEnabled: entity.isAppLockEnabled,
      autoLockDuration: entity.autoLockDuration,
      isVaultEnabled: entity.isVaultEnabled,
      encryptionKey: entity.encryptionKey,
      lastUnlockedAt: entity.lastUnlockedAt,
    );
  }

  /// Creates a [SecuritySettingsModel] from a JSON map.
  factory SecuritySettingsModel.fromJson(Map<String, dynamic> json) {
    return SecuritySettingsModel(
      isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
      isPinEnabled: json['isPinEnabled'] as bool? ?? false,
      pin: json['pin'] as String?,
      isAppLockEnabled: json['isAppLockEnabled'] as bool? ?? false,
      autoLockDuration: json['autoLockDurationMinutes'] != null
          ? Duration(minutes: json['autoLockDurationMinutes'] as int)
          : const Duration(minutes: 5),
      isVaultEnabled: json['isVaultEnabled'] as bool? ?? false,
      encryptionKey: json['encryptionKey'] as String?,
      lastUnlockedAt: json['lastUnlockedAt'] != null
          ? DateTime.parse(json['lastUnlockedAt'] as String)
          : null,
    );
  }

  /// Creates a [SecuritySettingsModel] from a Hive box entry.
  factory SecuritySettingsModel.fromHive(Map<dynamic, dynamic> map) {
    return SecuritySettingsModel(
      isBiometricEnabled: map['isBiometricEnabled'] as bool? ?? false,
      isPinEnabled: map['isPinEnabled'] as bool? ?? false,
      pin: map['pin'] as String?,
      isAppLockEnabled: map['isAppLockEnabled'] as bool? ?? false,
      autoLockDuration: map['autoLockDurationMinutes'] != null
          ? Duration(minutes: map['autoLockDurationMinutes'] as int)
          : const Duration(minutes: 5),
      isVaultEnabled: map['isVaultEnabled'] as bool? ?? false,
      encryptionKey: map['encryptionKey'] as String?,
      lastUnlockedAt: map['lastUnlockedAt'] != null
          ? (map['lastUnlockedAt'] is String
              ? DateTime.parse(map['lastUnlockedAt'] as String)
              : DateTime.fromMillisecondsSinceEpoch(map['lastUnlockedAt'] as int))
          : null,
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'isBiometricEnabled': isBiometricEnabled,
      'isPinEnabled': isPinEnabled,
      'pin': pin,
      'isAppLockEnabled': isAppLockEnabled,
      'autoLockDurationMinutes': autoLockDuration.inMinutes,
      'isVaultEnabled': isVaultEnabled,
      'encryptionKey': encryptionKey,
      'lastUnlockedAt': lastUnlockedAt?.toIso8601String(),
    };
  }

  /// Converts this model to a Hive-compatible map.
  Map<String, dynamic> toHive() {
    return {
      'isBiometricEnabled': isBiometricEnabled,
      'isPinEnabled': isPinEnabled,
      'pin': pin,
      'isAppLockEnabled': isAppLockEnabled,
      'autoLockDurationMinutes': autoLockDuration.inMinutes,
      'isVaultEnabled': isVaultEnabled,
      'encryptionKey': encryptionKey,
      'lastUnlockedAt': lastUnlockedAt?.toIso8601String(),
    };
  }

  /// Converts this model back to a domain [SecuritySettings] entity.
  @override
  SecuritySettings toEntity() {
    return SecuritySettings(
      isBiometricEnabled: isBiometricEnabled,
      isPinEnabled: isPinEnabled,
      pin: pin,
      isAppLockEnabled: isAppLockEnabled,
      autoLockDuration: autoLockDuration,
      isVaultEnabled: isVaultEnabled,
      encryptionKey: encryptionKey,
      lastUnlockedAt: lastUnlockedAt,
    );
  }
}
