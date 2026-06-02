import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_record.dart';
import 'package:scanpro/features/cloud_sync/domain/entities/sync_status.dart';
import 'package:scanpro/features/cloud_sync/domain/repositories/sync_repository.dart';
import 'package:scanpro/features/cloud_sync/domain/usecases/sync_documents.dart';

class MockSyncRepository extends Mock implements SyncRepository {}

void main() {
  late SyncDocuments useCase;
  late MockSyncRepository mockRepository;

  setUp(() {
    mockRepository = MockSyncRepository();
    useCase = SyncDocuments(mockRepository);
  });

  final tSyncRecords = [
    SyncRecord(
      id: 'sync-1',
      documentId: 'doc-1',
      operation: SyncOperation.create,
      timestamp: DateTime(2025, 3, 1),
      status: SyncRecordStatus.completed,
    ),
    SyncRecord(
      id: 'sync-2',
      documentId: 'doc-2',
      operation: SyncOperation.update,
      timestamp: DateTime(2025, 3, 2),
      status: SyncRecordStatus.completed,
    ),
  ];

  group('SyncDocuments', () {
    test('should return list of SyncRecords on successful sync', () async {
      // arrange
      when(() => mockRepository.syncAll())
          .thenAnswer((_) async => Right(tSyncRecords));

      // act
      final result = await useCase(const SyncDocumentsParams());

      // assert
      expect(result.isRight(), isTrue);
      final records = result.getOrElse(() => throw StateError('Expected Right'));
      expect(records.length, 2);
      expect(records.first.status, SyncRecordStatus.completed);
      verify(() => mockRepository.syncAll()).called(1);
    });

    test('should return empty list when there is nothing to sync', () async {
      // arrange
      when(() => mockRepository.syncAll())
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await useCase(const SyncDocumentsParams());

      // assert
      expect(result.isRight(), isTrue);
      final records = result.getOrElse(() => throw StateError('Expected Right'));
      expect(records, isEmpty);
    });

    test('should return SyncFailure when network is unavailable', () async {
      // arrange
      when(() => mockRepository.syncAll()).thenAnswer(
        (_) async => const Left(
          SyncFailure(message: 'Upload failed.', code: 'SYNC_001'),
        ),
      );

      // act
      final result = await useCase(const SyncDocumentsParams());

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<SyncFailure>());
    });

    test('should return ValidationFailure when batchSize is zero or negative',
        () async {
      // act
      final result = await useCase(const SyncDocumentsParams(batchSize: 0));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Batch size must be greater than 0');
      verifyNever(() => mockRepository.syncAll());
    });

    test('should detect conflicts in sync records', () async {
      // arrange
      final conflictRecord = SyncRecord(
        id: 'sync-conflict',
        documentId: 'doc-3',
        operation: SyncOperation.update,
        timestamp: DateTime(2025, 3, 3),
        status: SyncRecordStatus.conflict,
        conflictData: {'localVersion': 2, 'remoteVersion': 3},
      );

      when(() => mockRepository.syncAll())
          .thenAnswer((_) async => Right([conflictRecord]));

      // act
      final result = await useCase(const SyncDocumentsParams());

      // assert
      expect(result.isRight(), isTrue);
      final records = result.getOrElse(() => throw StateError('Expected Right'));
      expect(records.first.hasConflict, isTrue);
      expect(records.first.conflictData, isNotNull);
      expect(records.first.canRetry, isFalse);
    });

    test('should detect failed records that can be retried', () async {
      // arrange
      final failedRecord = SyncRecord(
        id: 'sync-failed',
        documentId: 'doc-4',
        operation: SyncOperation.create,
        timestamp: DateTime(2025, 3, 3),
        status: SyncRecordStatus.failed,
        retryCount: 1,
      );

      when(() => mockRepository.syncAll())
          .thenAnswer((_) async => Right([failedRecord]));

      // act
      final result = await useCase(const SyncDocumentsParams());

      // assert
      expect(result.isRight(), isTrue);
      final records = result.getOrElse(() => throw StateError('Expected Right'));
      expect(records.first.canRetry, isTrue);
      expect(records.first.status, SyncRecordStatus.failed);
    });

    test('should indicate no retry after max retries', () async {
      // arrange
      final maxRetriedRecord = SyncRecord(
        id: 'sync-max-retry',
        documentId: 'doc-5',
        operation: SyncOperation.create,
        timestamp: DateTime(2025, 3, 3),
        status: SyncRecordStatus.failed,
        retryCount: 3,
      );

      // assert
      expect(maxRetriedRecord.canRetry, isFalse);
    });

    test('should return NetworkFailure when there is no connectivity',
        () async {
      // arrange
      when(() => mockRepository.syncAll()).thenAnswer(
        (_) async => Left(NetworkFailure.noConnection()),
      );

      // act
      final result = await useCase(const SyncDocumentsParams());

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<NetworkFailure>());
    });
  });
}
