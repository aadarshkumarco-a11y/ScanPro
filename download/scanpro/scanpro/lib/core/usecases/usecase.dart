import 'package:dartz/dartz.dart';
import 'package:scanpro/core/error/failures.dart';

/// Base use case interface following Clean Architecture pattern.
///
/// Every use case in the application implements this interface,
/// ensuring consistent input/output handling with [Either] for
/// error propagation.
///
/// [Type] is the return type on success.
/// [Params] is the input parameter type.
abstract class UseCase<Type, Params> {
  /// Executes the use case with the provided [params].
  ///
  /// Returns [Either] a [Failure] on the left or [Type] on the right.
  Future<Either<Failure, Type>> call(Params params);
}

/// Marker class for use cases that require no parameters.
class NoParams {
  const NoParams();
}
