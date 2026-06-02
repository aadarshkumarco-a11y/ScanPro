import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_summary.dart';
import 'package:scanpro/features/ai_features/domain/repositories/ai_repository.dart';
import 'package:scanpro/features/ai_features/domain/usecases/summarize_document.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';

class MockAIRepository extends Mock implements AIRepository {}

void main() {
  late SummarizeDocument useCase;
  late MockAIRepository mockRepository;

  setUp(() {
    mockRepository = MockAIRepository();
    useCase = SummarizeDocument(mockRepository);
  });

  final tDocument = ScanDocument(
    id: 'doc-1',
    title: 'Invoice March 2025',
    filePath: '/docs/invoice.pdf',
    ocrText: 'Invoice #1234 Total: \$450.00 Due date: April 1, 2025',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
    fileSize: 245000,
  );

  final tAISummary = AISummary(
    id: 'summary-1',
    documentId: 'doc-1',
    summary: 'This is an invoice for \$450.00 due on April 1, 2025.',
    keyPoints: const [
      'Invoice number: 1234',
      'Total amount: \$450.00',
      'Due date: April 1, 2025',
    ],
    category: 'invoice',
    suggestedTags: const ['finance', 'invoice', 'payment'],
    confidence: 0.92,
    createdAt: DateTime(2025, 1, 1),
  );

  group('SummarizeDocument', () {
    test('should return AISummary on successful summary generation', () async {
      // arrange
      when(() => mockRepository.summarizeDocument(any()))
          .thenAnswer((_) async => Right(tAISummary));

      // act
      final result = await useCase(SummarizeDocumentParams(
        document: tDocument,
        maxWords: 150,
        includeKeyPoints: true,
      ));

      // assert
      expect(result.isRight(), isTrue);
      final summary = result.getOrElse(() => throw StateError('Expected Right'));
      expect(summary.summary, isNotEmpty);
      expect(summary.category, 'invoice');
      expect(summary.keyPoints.length, 3);
      expect(summary.suggestedTags, contains('finance'));
      expect(summary.isHighConfidence, isTrue);
      verify(() => mockRepository.summarizeDocument(tDocument)).called(1);
    });

    test('should return ValidationFailure when document file path is empty',
        () async {
      // arrange
      final emptyDoc = tDocument.copyWith(filePath: '');

      // act
      final result = await useCase(SummarizeDocumentParams(
        document: emptyDoc,
      ));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Document file path cannot be empty');
      verifyNever(() => mockRepository.summarizeDocument(any()));
    });

    test('should return ValidationFailure when maxWords is zero or negative',
        () async {
      // act
      final result = await useCase(SummarizeDocumentParams(
        document: tDocument,
        maxWords: 0,
      ));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Max words must be greater than 0');
    });

    test('should return AIFailure when API request fails', () async {
      // arrange
      when(() => mockRepository.summarizeDocument(any())).thenAnswer(
        (_) async => const Left(
          AIFailure(message: 'AI request failed', code: 'AI_001'),
        ),
      );

      // act
      final result = await useCase(SummarizeDocumentParams(
        document: tDocument,
      ));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<AIFailure>());
    });

    test('should return AIFailure on rate limit', () async {
      // arrange
      when(() => mockRepository.summarizeDocument(any())).thenAnswer(
        (_) async => Left(AIFailure.rateLimited()),
      );

      // act
      final result = await useCase(SummarizeDocumentParams(
        document: tDocument,
      ));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<AIFailure>());
      expect(failure.code, 'AI_001');
    });

    test('should return AIFailure on timeout', () async {
      // arrange
      when(() => mockRepository.summarizeDocument(any())).thenAnswer(
        (_) async => Left(AIFailure.timeout()),
      );

      // act
      final result = await useCase(SummarizeDocumentParams(
        document: tDocument,
      ));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure.message, contains('timed out'));
    });

    test('should handle low confidence summaries', () async {
      // arrange
      final lowConfidenceSummary = tAISummary.copyWith(confidence: 0.45);
      when(() => mockRepository.summarizeDocument(any()))
          .thenAnswer((_) async => Right(lowConfidenceSummary));

      // act
      final result = await useCase(SummarizeDocumentParams(
        document: tDocument,
      ));

      // assert
      expect(result.isRight(), isTrue);
      final summary = result.getOrElse(() => throw StateError('Expected Right'));
      expect(summary.isHighConfidence, isFalse);
      expect(summary.confidence, lessThan(0.8));
    });
  });
}
