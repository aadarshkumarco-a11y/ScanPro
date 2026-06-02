import 'package:hive/hive.dart';
import 'package:scanpro/features/security/domain/entities/lock_config.dart';

part 'lock_config_model.g.dart';

/// Hive-compatible data model for [LockConfig].
///
/// Provides serialization/deserialization for local storage with Hive,
/// and conversion methods between the domain entity and data model.
@HiveType(typeId: 7)
class LockConfigModel extends HiveObject {
  /// Whether the lock is enabled.
  @HiveField(0)
  final bool isEnabled;

  /// Lock type index.
  @HiveField(1)
  final int lockTypeIndex;

  /// Number of failed authentication attempts.
  @HiveField(2)
  final int failedAttempts;

  /// Last unlock timestamp as ISO 8601 string, or null.
  @HiveField(3)
  final String? lastUnlockedAt;

  LockConfigModel({
    this.isEnabled = false,
    this.lockTypeIndex = 0,
    this.failedAttempts = 0,
    this.lastUnlockedAt,
  });

  /// Creates a model from a domain entity.
  factory LockConfigModel.fromEntity(LockConfig entity) {
    return LockConfigModel(
      isEnabled: entity.isEnabled,
      lockTypeIndex: entity.lockType.index,
      failedAttempts: entity.failedAttempts,
      lastUnlockedAt: entity.lastUnlockedAt?.toIso8601String(),
    );
  }

  /// Converts this model to a domain entity.
  LockConfig toEntity() {
    return LockConfig(
      isEnabled: isEnabled,
      lockType: LockType.values[lockTypeIndex.clamp(
        0,
        LockType.values.length - 1,
      )],
      failedAttempts: failedAttempts,
      lastUnlockedAt: lastUnlockedAt != null
          ? DateTime.parse(lastUnlockedAt!)
          : null,
    );
  }

  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'lockTypeIndex': lockTypeIndex,
      'failedAttempts': failedAttempts,
      'lastUnlockedAt': lastUnlockedAt,
    };
  }

  /// Creates a model from a JSON map.
  factory LockConfigModel.fromJson(Map<String, dynamic> json) {
    return LockConfigModel(
      isEnabled: json['isEnabled'] as bool? ?? false,
      lockTypeIndex: json['lockTypeIndex'] as int? ?? 0,
      failedAttempts: json['failedAttempts'] as int? ?? 0,
      lastUnlockedAt: json['lastUnlockedAt'] as String?,
    );
  }
}
