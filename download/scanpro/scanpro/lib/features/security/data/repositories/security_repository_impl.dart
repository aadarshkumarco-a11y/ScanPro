import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/security/domain/entities/lock_config.dart';
import 'package:scanpro/features/security/domain/repositories/security_repository.dart';
import 'package:scanpro/features/security/data/models/lock_config_model.dart';
import 'package:scanpro/features/security/data/services/biometric_service.dart';
import 'package:scanpro/features/security/data/services/encryption_service.dart';
import 'package:hive/hive.dart';

/// Implementation of [SecurityRepository] using biometric auth and AES encryption.
///
/// Manages app lock state, PIN verification, biometric authentication,
/// and file encryption using platform security services.
class SecurityRepositoryImpl implements SecurityRepository {
  final BiometricService _biometricService;
  final EncryptionService _encryptionService;
  final Box<LockConfigModel> _lockConfigBox;

  static const String _pinKey = 'app_pin_hash';
  static const String _lockConfigKey = 'lock_config';

  SecurityRepositoryImpl({
    required BiometricService biometricService,
    required EncryptionService encryptionService,
    required Box<LockConfigModel> lockConfigBox,
  })  : _biometricService = biometricService,
        _encryptionService = encryptionService,
        _lockConfigBox = lockConfigBox;

  @override
  Future<Either<Failure, bool>> authenticate() async {
    try {
      final config = await _getLockConfig();

      if (!config.isEnabled) {
        return const Right(true);
      }

      bool authenticated = false;

      if (config.usesBiometric) {
        final bioResult = await _biometricService.authenticate();
        authenticated = bioResult;
      }

      if (!authenticated && config.usesPin) {
        return Right(false);
      }

      if (authenticated) {
        await _updateLockConfig(
          config.copyWith(
            failedAttempts: 0,
            lastUnlockedAt: DateTime.now(),
          ),
        );
      }

      return Right(authenticated);
    } on BiometricException catch (e) {
      return Left(SecurityFailure(message: e.message));
    } catch (e) {
      return Left(SecurityFailure(message: 'Authentication failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setPIN(String pin) async {
    try {
      if (pin.length < 4 || pin.length > 6) {
        return const Left(
          ValidationFailure(message: 'PIN must be 4-6 digits'),
        );
      }
      if (!RegExp(r'^\d+$').hasMatch(pin)) {
        return const Left(
          ValidationFailure(message: 'PIN must contain only digits'),
        );
      }

      final hashedPin = _encryptionService.hashPIN(pin);
      await _lockConfigBox.put(_pinKey, hashedPin);

      final config = await _getLockConfig();
      await _updateLockConfig(
        config.copyWith(isEnabled: true),
      );

      return const Right(unit);
    } catch (e) {
      return Left(SecurityFailure(message: 'Failed to set PIN: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPIN(String pin) async {
    try {
      final storedHash = _lockConfigBox.get(_pinKey);
      if (storedHash == null) {
        return const Left(
          SecurityFailure(message: 'No PIN has been set'),
        );
      }

      final inputHash = _encryptionService.hashPIN(pin);
      final isMatch = inputHash == storedHash;

      final config = await _getLockConfig();
      if (isMatch) {
        await _updateLockConfig(
          config.copyWith(
            failedAttempts: 0,
            lastUnlockedAt: DateTime.now(),
          ),
        );
      } else {
        await _updateLockConfig(
          config.copyWith(
            failedAttempts: config.failedAttempts + 1,
          ),
        );
      }

      return Right(isMatch);
    } catch (e) {
      return Left(SecurityFailure(message: 'PIN verification failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> enableBiometric() async {
    try {
      final isAvailable = await _biometricService.isAvailable();
      if (!isAvailable) {
        return const Left(
          SecurityFailure(
            message: 'Biometric authentication is not available on this device',
          ),
        );
      }

      final config = await _getLockConfig();
      final newLockType = config.usesPin
          ? LockType.both
          : LockType.biometric;

      await _updateLockConfig(
        config.copyWith(
          isEnabled: true,
          lockType: newLockType,
        ),
      );

      return const Right(unit);
    } on BiometricException catch (e) {
      return Left(SecurityFailure(message: e.message));
    } catch (e) {
      return Left(
        SecurityFailure(message: 'Failed to enable biometric: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isLocked() async {
    try {
      final config = await _getLockConfig();
      return Right(config.shouldShowLock());
    } catch (e) {
      return Left(
        SecurityFailure(message: 'Failed to check lock status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> lockApp() async {
    try {
      final config = await _getLockConfig();
      await _updateLockConfig(
        config.copyWith(lastUnlockedAt: null),
      );
      return const Right(unit);
    } catch (e) {
      return Left(SecurityFailure(message: 'Failed to lock app: $e'));
    }
  }

  @override
  Future<Either<Failure, LockConfig>> unlockApp() async {
    try {
      final config = await _getLockConfig();
      final updatedConfig = config.copyWith(
        failedAttempts: 0,
        lastUnlockedAt: DateTime.now(),
      );
      await _updateLockConfig(updatedConfig);
      return Right(updatedConfig);
    } catch (e) {
      return Left(SecurityFailure(message: 'Failed to unlock app: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> encryptFile(String filePath) async {
    try {
      final encryptedPath = await _encryptionService.encryptFile(filePath);
      return Right(encryptedPath);
    } on EncryptionException catch (e) {
      return Left(SecurityFailure(message: e.message));
    } catch (e) {
      return Left(
        SecurityFailure(message: 'Failed to encrypt file: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> decryptFile(String filePath) async {
    try {
      final decryptedPath = await _encryptionService.decryptFile(filePath);
      return Right(decryptedPath);
    } on EncryptionException catch (e) {
      return Left(SecurityFailure(message: e.message));
    } catch (e) {
      return Left(
        SecurityFailure(message: 'Failed to decrypt file: $e'),
      );
    }
  }

  /// Retrieves the current lock configuration from Hive.
  Future<LockConfig> _getLockConfig() async {
    final model = _lockConfigBox.get(_lockConfigKey);
    if (model == null) {
      return const LockConfig();
    }
    return model.toEntity();
  }

  /// Persists the lock configuration to Hive.
  Future<void> _updateLockConfig(LockConfig config) async {
    await _lockConfigBox.put(
      _lockConfigKey,
      LockConfigModel.fromEntity(config),
    );
  }
}
