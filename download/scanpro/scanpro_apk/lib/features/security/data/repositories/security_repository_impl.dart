import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/security_settings.dart';
import '../../domain/repositories/security_repository.dart';
import '../datasources/security_local_datasource.dart';
import '../models/security_settings_model.dart';

/// Concrete implementation of [SecurityRepository].
///
/// Delegates secure storage, biometric auth, and encryption to
/// [SecurityLocalDatasource]. All exceptions are caught and
/// converted to the appropriate [Failure] subclass.
class SecurityRepositoryImpl implements SecurityRepository {
  SecurityRepositoryImpl({
    required SecurityLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  final SecurityLocalDatasource _localDatasource;

  // ── Setup PIN ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, SecuritySettings>> setupPin(String pin) async {
    try {
      await _localDatasource.savePinHash(pin);

      final settings = await _localDatasource.getSecuritySettings();
      final updated = SecuritySettingsModel.fromEntity(
        settings.toEntity().copyWith(
              isPinEnabled: true,
              pin: _localDatasource.hashPin(pin),
            ),
      );

      await _localDatasource.saveSecuritySettings(updated);
      await _localDatasource.resetFailedAttempts();

      return Right(updated.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } on SecurityException catch (e) {
      return Left(SecurityFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SecurityFailure(
        message: 'Failed to set up PIN: ${e.toString()}',
        code: 5006,
      ));
    }
  }

  // ── Verify PIN ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> verifyPin(String pin) async {
    try {
      // Check lockout first.
      final isLockedOut = await _localDatasource.isLockedOut();
      if (isLockedOut) {
        return Left(SecurityFailure.pinLockedOut());
      }

      final storedHash = await _localDatasource.getPinHash();
      if (storedHash == null) {
        return Left(SecurityFailure.pinNotSet());
      }

      final inputHash = _localDatasource.hashPin(pin);
      final isCorrect = inputHash == storedHash;

      if (isCorrect) {
        await _localDatasource.resetFailedAttempts();
      } else {
        await _localDatasource.recordFailedAttempt();
      }

      return Right(isCorrect);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } on SecurityException catch (e) {
      return Left(SecurityFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SecurityFailure(
        message: 'Failed to verify PIN: ${e.toString()}',
        code: 5006,
      ));
    }
  }

  // ── Biometric ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, SecuritySettings>> enableBiometric(
    bool enabled,
  ) async {
    try {
      if (enabled) {
        final isAvailable = await _localDatasource.isBiometricAvailable();
        if (!isAvailable) {
          return Left(SecurityFailure.biometricNotAvailable());
        }

        final biometrics =
            await _localDatasource.getAvailableBiometrics();
        if (biometrics.isEmpty) {
          return Left(SecurityFailure.biometricNotEnrolled());
        }
      }

      await _localDatasource.setBiometricEnabled(enabled);

      final settings = await _localDatasource.getSecuritySettings();
      final updated = SecuritySettingsModel.fromEntity(
        settings.toEntity().copyWith(isBiometricEnabled: enabled),
      );

      await _localDatasource.saveSecuritySettings(updated);

      return Right(updated.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } on SecurityException catch (e) {
      return Left(SecurityFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SecurityFailure(
        message: 'Failed to update biometric setting: ${e.toString()}',
        code: 5006,
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateBiometric() async {
    try {
      final result = await _localDatasource.authenticateWithBiometric();
      return Right(result);
    } on SecurityException catch (e) {
      return Left(SecurityFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SecurityFailure.biometricFailed());
    }
  }

  // ── App Lock ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> lockApp() async {
    try {
      await _localDatasource.setAppLocked(true);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SecurityFailure(
        message: 'Failed to lock app: ${e.toString()}',
        code: 5006,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> unlockApp() async {
    try {
      await _localDatasource.setAppLocked(false);

      final settings = await _localDatasource.getSecuritySettings();
      final updated = SecuritySettingsModel.fromEntity(
        settings.toEntity().copyWith(lastUnlockedAt: DateTime.now()),
      );
      await _localDatasource.saveSecuritySettings(updated);

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SecurityFailure(
        message: 'Failed to unlock app: ${e.toString()}',
        code: 5006,
      ));
    }
  }

  // ── Encryption ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> encryptData(String plainText) async {
    try {
      final cipherText = await _localDatasource.encryptData(plainText);
      return Right(cipherText);
    } on SecurityException catch (e) {
      return Left(SecurityFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SecurityFailure.encryptionError());
    }
  }

  @override
  Future<Either<Failure, String>> decryptData(String cipherText) async {
    try {
      final plainText = await _localDatasource.decryptData(cipherText);
      return Right(plainText);
    } on SecurityException catch (e) {
      return Left(SecurityFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(SecurityFailure.encryptionError());
    }
  }

  // ── Settings ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, SecuritySettings>> updateSecuritySettings(
    SecuritySettings settings,
  ) async {
    try {
      final model = SecuritySettingsModel.fromEntity(settings);
      await _localDatasource.saveSecuritySettings(model);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to update settings: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, SecuritySettings>> getSecuritySettings() async {
    try {
      final model = await _localDatasource.getSecuritySettings();
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get security settings: ${e.toString()}',
        code: 1003,
      ));
    }
  }
}
