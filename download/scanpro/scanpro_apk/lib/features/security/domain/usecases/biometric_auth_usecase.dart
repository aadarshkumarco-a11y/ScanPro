import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/security/domain/entities/security_settings.dart';
import 'package:scanpro/features/security/domain/repositories/security_repository.dart';

/// Use case for biometric authentication.
///
/// First checks whether biometrics are enabled in the current
/// [SecuritySettings], then delegates to [SecurityRepository]
/// for the actual platform biometric prompt.
class BiometricAuthUseCase {
  const BiometricAuthUseCase(this._repository);

  final SecurityRepository _repository;

  /// Checks whether biometric auth can be used on this device.
  ///
  /// Returns the current security settings so the caller can inspect
  /// [SecuritySettings.isBiometricEnabled].
  Future<Either<Failure, SecuritySettings>> canUseBiometric() async {
    return _repository.getSecuritySettings();
  }

  /// Enables or disables biometric authentication.
  ///
  /// [enabled] – whether biometric auth should be active.
  Future<Either<Failure, SecuritySettings>> enableBiometric({
    required bool enabled,
  }) async {
    return _repository.enableBiometric(enabled);
  }

  /// Shows the biometric prompt and authenticates the user.
  ///
  /// Returns `true` if authentication succeeded, or a [SecurityFailure].
  Future<Either<Failure, bool>> authenticate() async {
    // First, verify biometric is enabled.
    final settingsResult = await _repository.getSecuritySettings();

    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) async {
        if (!settings.isBiometricEnabled) {
          return const Left(SecurityFailure(
            message: 'Biometric authentication is not enabled. '
                'Enable it in Security Settings first.',
            code: 5003,
          ));
        }
        return _repository.authenticateBiometric();
      },
    );
  }
}
