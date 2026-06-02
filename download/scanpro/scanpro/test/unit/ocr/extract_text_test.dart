import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/ocr/domain/entities/ocr_result.dart';
import 'package:scanpro/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:scanpro/features/ocr/domain/usecases/extract_text.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';

class MockOCRRepository extends Mock implements OCRRepository {}

void main() {
  late ExtractText useCase;
  late MockOCRRepository mockRepository;

  setUp(() {
    mockRepository = MockOCRRepository();
    useCase = ExtractText(mockRepository);
  });

  final tDocument = ScanDocument(
    id: 'doc-1',
    title: 'Test Document',
    filePath: '/tmp/test_doc.jpg',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
    fileSize: 1024,
  );

  final tOCRResult = OCRResult(
    id: 'ocr-1',
    documentId: 'doc-1',
    text: 'Hello, this is extracted text from the document.',
    language: 'en',
    confidence: 0.95,
    paragraphs: const ['Hello, this is extracted text from the document.'],
    createdAt: DateTime(2025, 1, 1),
  );

  final tOCRResultWithActions = OCRResult(
    id: 'ocr-1',
    documentId: 'doc-1',
    text: 'Call us at +1-555-0123 or email test@example.com',
    language: 'en',
    confidence: 0.92,
    paragraphs: const ['Call us at +1-555-0123 or email test@example.com'],
    smartActions: const [
      SmartAction(
        type: SmartActionType.phone,
        value: '+1-555-0123',
        startIndex: 11,
        endIndex: 22,
      ),
      SmartAction(
        type: SmartActionType.email,
        value: 'test@example.com',
        startIndex: 32,
        endIndex: 48,
      ),
    ],
    createdAt: DateTime(2025, 1, 1),
  );

  group('ExtractText', () {
    test('should return OCRResult on successful text extraction', () async {
      // arrange
      when(() => mockRepository.extractText(any()))
          .thenAnswer((_) async => Right(tOCRResult));
      when(() => mockRepository.detectSmartActions(any()))
          .thenAnswer((_) async => Right(tOCRResult));

      // act
      final result = await useCase(
        ExtractTextParams(document: tDocument, detectActions: false),
      );

      // assert
      expect(result.isRight(), isTrue);
      final ocrResult =
          result.getOrElse(() => throw StateError('Expected Right'));
      expect(ocrResult.text, 'Hello, this is extracted text from the document.');
      expect(ocrResult.language, 'en');
      expect(ocrResult.confidence, 0.95);
      verify(() => mockRepository.extractText(tDocument)).called(1);
      verifyNever(() => mockRepository.detectSmartActions(any()));
    });

    test('should return ValidationFailure when document file path is empty',
        () async {
      // arrange
      final emptyDoc = tDocument.copyWith(filePath: '');

      // act
      final result = await useCase(
        ExtractTextParams(document: emptyDoc),
      );

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Document file path cannot be empty');
      verifyNever(() => mockRepository.extractText(any()));
    });

    test('should detect language and smart actions when detectActions is true',
        () async {
      // arrange
      when(() => mockRepository.extractText(any()))
          .thenAnswer((_) async => Right(tOCRResultWithActions));
      when(() => mockRepository.detectSmartActions(any()))
          .thenAnswer((_) async => Right(tOCRResultWithActions));

      // act
      final result = await useCase(
        ExtractTextParams(document: tDocument, detectActions: true),
      );

      // assert
      expect(result.isRight(), isTrue);
      final ocrResult =
          result.getOrElse(() => throw StateError('Expected Right'));
      expect(ocrResult.language, 'en');
      expect(ocrResult.hasSmartActions, isTrue);
      expect(ocrResult.phoneNumbers.length, 1);
      expect(ocrResult.emails.length, 1);
      verify(() => mockRepository.detectSmartActions(any())).called(1);
    });

    test('should return OCRFailure when repository fails', () async {
      // arrange
      when(() => mockRepository.extractText(any())).thenAnswer(
        (_) async => const Left(
          OCRFailure(message: 'Text recognition failed', code: 'OCR_001'),
        ),
      );

      // act
      final result = await useCase(
        ExtractTextParams(document: tDocument, detectActions: false),
      );

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<OCRFailure>());
    });

    test('should skip smart actions when text is empty', () async {
      // arrange
      final emptyOCRResult = OCRResult(
        id: 'ocr-empty',
        documentId: 'doc-1',
        text: '',
        language: 'en',
        confidence: 0.0,
        createdAt: DateTime(2025, 1, 1),
      );
      when(() => mockRepository.extractText(any()))
          .thenAnswer((_) async => Right(emptyOCRResult));

      // act
      final result = await useCase(
        ExtractTextParams(document: tDocument, detectActions: true),
      );

      // assert
      expect(result.isRight(), isTrue);
      final ocrResult =
          result.getOrElse(() => throw StateError('Expected Right'));
      expect(ocrResult.text, isEmpty);
      // Smart actions should not be called for empty text
      verifyNever(() => mockRepository.detectSmartActions(any()));
    });
  });
}
