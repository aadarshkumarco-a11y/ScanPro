import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/documents/domain/repositories/document_repository.dart';
import 'package:scanpro/features/documents/domain/usecases/get_documents.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';

class MockDocumentRepository extends Mock implements DocumentRepository {}

void main() {
  late GetDocuments useCase;
  late MockDocumentRepository mockRepository;

  setUp(() {
    mockRepository = MockDocumentRepository();
    useCase = GetDocuments(mockRepository);
  });

  final now = DateTime(2025, 3, 4);

  final tDocuments = [
    ScanDocument(
      id: '1',
      title: 'Invoice',
      filePath: '/docs/invoice.pdf',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 1)),
      fileSize: 245000,
      isFavorite: true,
    ),
    ScanDocument(
      id: '2',
      title: 'Contract',
      filePath: '/docs/contract.pdf',
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now.subtract(const Duration(days: 5)),
      fileSize: 890000,
      isArchived: true,
    ),
    ScanDocument(
      id: '3',
      title: 'Receipt',
      filePath: '/docs/receipt.jpg',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 30)),
      fileSize: 340000,
      isDeleted: true,
    ),
    ScanDocument(
      id: '4',
      title: 'Notes',
      filePath: '/docs/notes.jpg',
      folderId: 'f1',
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now,
      fileSize: 120000,
    ),
  ];

  group('GetDocuments', () {
    test('should return list of documents on successful retrieval', () async {
      // arrange
      when(() => mockRepository.getDocuments())
          .thenAnswer((_) async => Right(tDocuments));

      // act
      final result = await useCase(const GetDocumentsParams());

      // assert
      expect(result.isRight(), isTrue);
      final docs = result.getOrElse(() => throw StateError('Expected Right'));
      expect(docs.length, 3); // excludes archived and deleted by default
      verify(() => mockRepository.getDocuments()).called(1);
    });

    test('should return empty list when no documents exist', () async {
      // arrange
      when(() => mockRepository.getDocuments())
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await useCase(const GetDocumentsParams());

      // assert
      expect(result.isRight(), isTrue);
      final docs = result.getOrElse(() => throw StateError('Expected Right'));
      expect(docs, isEmpty);
    });

    test('should exclude archived documents when includeArchived is false',
        () async {
      // arrange
      when(() => mockRepository.getDocuments())
          .thenAnswer((_) async => Right(tDocuments));

      // act
      final result = await useCase(
        const GetDocumentsParams(includeArchived: false),
      );

      // assert
      expect(result.isRight(), isTrue);
      final docs = result.getOrElse(() => throw StateError('Expected Right'));
      expect(docs.every((doc) => !doc.isArchived), isTrue);
    });

    test('should include archived documents when includeArchived is true',
        () async {
      // arrange
      when(() => mockRepository.getDocuments())
          .thenAnswer((_) async => Right(tDocuments));

      // act
      final result = await useCase(
        const GetDocumentsParams(includeArchived: true, includeDeleted: true),
      );

      // assert
      expect(result.isRight(), isTrue);
      final docs = result.getOrElse(() => throw StateError('Expected Right'));
      expect(docs.any((doc) => doc.isArchived), isTrue);
    });

    test('should exclude deleted documents when includeDeleted is false',
        () async {
      // arrange
      when(() => mockRepository.getDocuments())
          .thenAnswer((_) async => Right(tDocuments));

      // act
      final result = await useCase(
        const GetDocumentsParams(includeDeleted: false),
      );

      // assert
      expect(result.isRight(), isTrue);
      final docs = result.getOrElse(() => throw StateError('Expected Right'));
      expect(docs.every((doc) => !doc.isDeleted), isTrue);
    });

    test('should filter by folder when folderId is provided', () async {
      // arrange
      final folderDocs = tDocuments.where((d) => d.folderId == 'f1').toList();
      when(() => mockRepository.getByFolder('f1'))
          .thenAnswer((_) async => Right(folderDocs));

      // act
      final result = await useCase(
        const GetDocumentsParams(folderId: 'f1'),
      );

      // assert
      expect(result.isRight(), isTrue);
      final docs = result.getOrElse(() => throw StateError('Expected Right'));
      expect(docs.length, 1);
      expect(docs.first.folderId, 'f1');
      verify(() => mockRepository.getByFolder('f1')).called(1);
      verifyNever(() => mockRepository.getDocuments());
    });

    test('should filter by tag when tagId is provided', () async {
      // arrange
      final taggedDocs = [tDocuments.first];
      when(() => mockRepository.getByTag('t1'))
          .thenAnswer((_) async => Right(taggedDocs));

      // act
      final result = await useCase(
        const GetDocumentsParams(tagId: 't1'),
      );

      // assert
      expect(result.isRight(), isTrue);
      final docs = result.getOrElse(() => throw StateError('Expected Right'));
      expect(docs.length, 1);
      verify(() => mockRepository.getByTag('t1')).called(1);
      verifyNever(() => mockRepository.getDocuments());
    });

    test('should return CacheFailure when repository fails', () async {
      // arrange
      when(() => mockRepository.getDocuments()).thenAnswer(
        (_) async => const Left(
          CacheFailure(message: 'Failed to read documents from cache'),
        ),
      );

      // act
      final result = await useCase(const GetDocumentsParams());

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<CacheFailure>());
    });
  });
}
