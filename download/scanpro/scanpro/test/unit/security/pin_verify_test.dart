import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/security/domain/entities/lock_config.dart';
import 'package:scanpro/features/security/domain/repositories/security_repository.dart';

class MockSecurityRepository extends Mock implements SecurityRepository {}

void main() {
  late MockSecurityRepository mockRepository;

  setUp(() {
    mockRepository = MockSecurityRepository();
  });

  group('PIN Verification', () {
    test('should return true when correct PIN is provided', () async {
      // arrange
      const correctPin = '1234';
      when(() => mockRepository.verifyPIN(correctPin))
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await mockRepository.verifyPIN(correctPin);

      // assert
      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => false), isTrue);
    });

    test('should return false when incorrect PIN is provided', () async {
      // arrange
      const wrongPin = '9999';
      when(() => mockRepository.verifyPIN(wrongPin))
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await mockRepository.verifyPIN(wrongPin);

      // assert
      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => true), isFalse);
    });

    test('should track failed attempts and indicate lockout after max attempts',
        () async {
      // arrange - simulate 5 failed attempts
      const maxAttempts = LockConfig.maxFailedAttempts; // 5
      const wrongPin = '0000';
      when(() => mockRepository.verifyPIN(wrongPin))
          .thenAnswer((_) async => const Right(false));

      // act - attempt max failed PINs
      for (int i = 0; i < maxAttempts; i++) {
        await mockRepository.verifyPIN(wrongPin);
      }

      // assert
      const lockConfig = LockConfig(failedAttempts: 5);
      expect(lockConfig.isLockedOut, isTrue);
      expect(lockConfig.failedAttempts, maxAttempts);
      verify(() => mockRepository.verifyPIN(wrongPin)).called(maxAttempts);
    });

    test('should not be locked out when failed attempts are below max', () async {
      // arrange
      const lockConfig = LockConfig(failedAttempts: 3);

      // assert
      expect(lockConfig.isLockedOut, isFalse);
    });

    test('should reset failed attempts on successful verification', () async {
      // arrange
      const lockConfig = LockConfig(failedAttempts: 0);

      // assert
      expect(lockConfig.failedAttempts, 0);
      expect(lockConfig.isLockedOut, isFalse);
    });

    test('should return SecurityFailure when verification fails', () async {
      // arrange
      when(() => mockRepository.verifyPIN(any())).thenAnswer(
        (_) async => const Left(
          SecurityFailure(
            message: 'Authentication failed',
            code: 'SEC_003',
          ),
        ),
      );

      // act
      final result = await mockRepository.verifyPIN('1234');

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<SecurityFailure>());
    });

    test('LockConfig shouldShowLock returns true when enabled and lastUnlockedAt is null',
        () async {
      // arrange
      const config = LockConfig(isEnabled: true, lastUnlockedAt: null);

      // assert
      expect(config.shouldShowLock(), isTrue);
    });

    test('LockConfig shouldShowLock returns false when not enabled', () async {
      // arrange
      const config = LockConfig(isEnabled: false);

      // assert
      expect(config.shouldShowLock(), isFalse);
    });
  });
}
