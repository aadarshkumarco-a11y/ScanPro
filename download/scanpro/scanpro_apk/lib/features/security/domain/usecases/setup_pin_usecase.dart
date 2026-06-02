import 'package:dartz/dartz.dart';
import 'package:scanpro/core/constants/app_constants.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/security/domain/entities/security_settings.dart';
import 'package:scanpro/features/security/domain/repositories/security_repository.dart';

/// Use case for setting up a new PIN.
///
/// Validates the PIN before delegating to [SecurityRepository.setupPin].
/// PIN must be exactly [AppConstants.pinLength] digits and must not be
/// a trivial pattern (e.g. "123456", "000000").
class SetupPinUseCase {
  const SetupPinUseCase(this._repository);

  final SecurityRepository _repository;

  /// Executes the PIN setup.
  ///
  /// [pin] – the raw 6-digit PIN string entered by the user.
  /// Returns the updated [SecuritySettings] on success, or a [Failure].
  Future<Either<Failure, SecuritySettings>> call(String pin) async {
    // Validate length.
    if (pin.length != AppConstants.pinLength) {
      return Left(ValidationFailure.tooShort('PIN', AppConstants.pinLength));
    }

    // Validate numeric content.
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return Left(ValidationFailure.invalidFormat('PIN'));
    }

    // Reject trivial PINs.
    if (_isTrivialPin(pin)) {
      return Left(const ValidationFailure(
        message: 'This PIN is too easy to guess. Choose a stronger PIN.',
        code: 10002,
      ));
    }

    return _repository.setupPin(pin);
  }

  /// Checks whether the PIN is a trivial/weak pattern.
  bool _isTrivialPin(String pin) {
    // All same digit: "000000", "111111", …
    if (pin.split('').every((c) => c == pin[0])) return true;

    // Sequential ascending: "123456", "234567", …
    final ascending = List.generate(pin.length, (i) => (int.parse(pin[0]) + i) % 10).join();
    if (pin == ascending) return true;

    // Sequential descending: "987654", "876543", …
    final descending = List.generate(pin.length, (i) => (int.parse(pin[0]) - i) % 10).join();
    if (pin == descending) return true;

    return false;
  }
}
