import 'package:dartz/dartz.dart';
import 'package:scanpro/core/constants/app_constants.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/security/domain/repositories/security_repository.dart';

/// Use case for verifying a user-entered PIN.
///
/// Validates the PIN format before delegating to
/// [SecurityRepository.verifyPin]. Handles lockout tracking
/// after too many failed attempts.
class VerifyPinUseCase {
  VerifyPinUseCase(this._repository);

  final SecurityRepository _repository;

  /// The number of consecutive failed attempts.
  int _failedAttempts = 0;

  /// Timestamp of the last failed attempt (for lockout calculation).
  DateTime? _lastFailedAt;

  /// Executes PIN verification.
  ///
  /// [pin] – the raw 6-digit PIN string entered by the user.
  /// Returns `true` if the PIN is correct, or a [Failure].
  Future<Either<Failure, bool>> call(String pin) async {
    // Check lockout status.
    if (_isLockedOut) {
      return Left(SecurityFailure.pinLockedOut());
    }

    // Validate format.
    if (pin.length != AppConstants.pinLength) {
      return Left(ValidationFailure.tooShort('PIN', AppConstants.pinLength));
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return Left(ValidationFailure.invalidFormat('PIN'));
    }

    final result = await _repository.verifyPin(pin);

    return result.fold(
      (failure) {
        _recordFailedAttempt();
        return Left(failure);
      },
      (isCorrect) {
        if (isCorrect) {
          _resetFailedAttempts();
        } else {
          _recordFailedAttempt();
        }
        return Right(isCorrect);
      },
    );
  }

  /// Whether the user is currently locked out due to too many attempts.
  bool get _isLockedOut {
    if (_failedAttempts < AppConstants.maxPinAttempts) return false;
    if (_lastFailedAt == null) return false;

    final elapsed = DateTime.now().difference(_lastFailedAt!);
    final lockoutDuration =
        Duration(minutes: AppConstants.lockoutDurationMinutes);

    if (elapsed >= lockoutDuration) {
      // Lockout period has expired; reset.
      _failedAttempts = 0;
      _lastFailedAt = null;
      return false;
    }
    return true;
  }

  /// Records a failed PIN attempt.
  void _recordFailedAttempt() {
    _failedAttempts++;
    _lastFailedAt = DateTime.now();
  }

  /// Resets the failed attempt counter on success.
  void _resetFailedAttempts() {
    _failedAttempts = 0;
    _lastFailedAt = null;
  }

  /// Returns the number of remaining attempts before lockout.
  int get remainingAttempts =>
      AppConstants.maxPinAttempts - _failedAttempts;
}
