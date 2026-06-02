import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_document.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';
import 'package:scanpro/features/pdf_tools/domain/usecases/create_pdf.dart';

class MockPDFRepository extends Mock implements PDFRepository {}

void main() {
  late CreatePDF useCase;
  late MockPDFRepository mockRepository;

  setUp(() {
    mockRepository = MockPDFRepository();
    useCase = CreatePDF(mockRepository);
  });

  final tPDFDocument = PDFDocument(
    id: 'pdf-1',
    title: 'Test PDF',
    filePath: '/tmp/test.pdf',
    fileSize: 51200,
    pageCount: 3,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  group('CreatePDF', () {
    test('should return PDFDocument on successful creation from images',
        () async {
      // arrange
      when(() => mockRepository.createPDF(any(), title: any(named: 'title')))
          .thenAnswer((_) async => Right(tPDFDocument));

      // act
      final result = await useCase(const CreatePDFParams(
        imagePaths: ['/tmp/img1.jpg', '/tmp/img2.jpg', '/tmp/img3.jpg'],
        title: 'Test PDF',
        quality: 85,
      ));

      // assert
      expect(result.isRight(), isTrue);
      final pdfDoc = result.getOrElse(() => throw StateError('Expected Right'));
      expect(pdfDoc.id, 'pdf-1');
      expect(pdfDoc.pageCount, 3);
      expect(pdfDoc.filePath, '/tmp/test.pdf');
      verify(() => mockRepository.createPDF(
            ['/tmp/img1.jpg', '/tmp/img2.jpg', '/tmp/img3.jpg'],
            title: 'Test PDF',
          )).called(1);
    });

    test('should return ValidationFailure when image list is empty', () async {
      // act
      final result = await useCase(const CreatePDFParams(
        imagePaths: [],
      ));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'At least one image is required');
      verifyNever(() => mockRepository.createPDF(any()));
    });

    test('should return PDFDocument with multiple pages from multiple images',
        () async {
      // arrange
      const multiPagePDF = PDFDocument(
        id: 'pdf-multi',
        title: 'Multi-page PDF',
        filePath: '/tmp/multi.pdf',
        fileSize: 204800,
        pageCount: 5,
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      );

      when(() => mockRepository.createPDF(any(), title: any(named: 'title')))
          .thenAnswer((_) async => const Right(multiPagePDF));

      // act
      final result = await useCase(const CreatePDFParams(
        imagePaths: [
          '/tmp/page1.jpg',
          '/tmp/page2.jpg',
          '/tmp/page3.jpg',
          '/tmp/page4.jpg',
          '/tmp/page5.jpg',
        ],
        title: 'Multi-page PDF',
        quality: 90,
      ));

      // assert
      expect(result.isRight(), isTrue);
      final pdfDoc = result.getOrElse(() => throw StateError('Expected Right'));
      expect(pdfDoc.pageCount, 5);
      expect(pdfDoc.formattedFileSize, contains('KB'));
    });

    test('should return ValidationFailure when quality is out of range',
        () async {
      // act
      final result = await useCase(const CreatePDFParams(
        imagePaths: ['/tmp/img1.jpg'],
        quality: 150,
      ));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Quality must be between 0 and 100');
    });

    test('should return PDFFailure when repository fails', () async {
      // arrange
      when(() => mockRepository.createPDF(any(), title: any(named: 'title')))
          .thenAnswer(
        (_) async => const Left(
          PDFFailure(message: 'PDF generation failed', code: 'PDF_001'),
        ),
      );

      // act
      final result = await useCase(const CreatePDFParams(
        imagePaths: ['/tmp/img1.jpg'],
      ));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<PDFFailure>());
    });
  });
}
