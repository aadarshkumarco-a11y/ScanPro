import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/pdf_tools/domain/entities/pdf_operation.dart';
import 'package:scanpro/features/pdf_tools/domain/repositories/pdf_repository.dart';
import 'package:scanpro/features/pdf_tools/domain/usecases/merge_pdfs.dart';

class MockPDFRepository extends Mock implements PDFRepository {}

void main() {
  late MergePDFs useCase;
  late MockPDFRepository mockRepository;

  setUp(() {
    mockRepository = MockPDFRepository();
    useCase = MergePDFs(mockRepository);
  });

  const tMergeResult = PDFOperationResult(
    operation: PDFOperation.merge,
    outputPaths: ['/tmp/merged.pdf'],
    originalSize: 102400,
    resultSize: 92160,
  );

  group('MergePDFs', () {
    test('should return PDFOperationResult on successful merge', () async {
      // arrange
      when(() => mockRepository.mergePDFs(any(),
              outputTitle: any(named: 'outputTitle')))
          .thenAnswer((_) async => const Right(tMergeResult));

      // act
      final result = await useCase(const MergePDFsParams(
        pdfPaths: ['/tmp/doc1.pdf', '/tmp/doc2.pdf'],
        outputTitle: 'Merged Document',
      ));

      // assert
      expect(result.isRight(), isTrue);
      final opResult =
          result.getOrElse(() => throw StateError('Expected Right'));
      expect(opResult.operation, PDFOperation.merge);
      expect(opResult.outputPath, '/tmp/merged.pdf');
      expect(opResult.wasCompressed, isTrue);
      expect(opResult.spaceSavedPercent, closeTo(10.0, 0.1));
      verify(() => mockRepository.mergePDFs(
            ['/tmp/doc1.pdf', '/tmp/doc2.pdf'],
            outputTitle: 'Merged Document',
          )).called(1);
    });

    test('should return ValidationFailure when only one PDF is provided',
        () async {
      // act
      final result = await useCase(const MergePDFsParams(
        pdfPaths: ['/tmp/doc1.pdf'],
      ));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'At least two PDF files are required to merge');
      verifyNever(() => mockRepository.mergePDFs(any()));
    });

    test('should return ValidationFailure when no PDFs are provided',
        () async {
      // act
      final result = await useCase(const MergePDFsParams(
        pdfPaths: [],
      ));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<ValidationFailure>());
    });

    test('should return PDFFailure when repository fails on invalid PDF path',
        () async {
      // arrange
      when(() => mockRepository.mergePDFs(any(),
              outputTitle: any(named: 'outputTitle')))
          .thenAnswer(
        (_) async => const Left(
          PDFFailure(message: 'Corrupted PDF file: /tmp/invalid.pdf', code: 'PDF_003'),
        ),
      );

      // act
      final result = await useCase(const MergePDFsParams(
        pdfPaths: ['/tmp/invalid.pdf', '/tmp/doc2.pdf'],
      ));

      // assert
      expect(result.isLeft(), isTrue);
      final failure =
          result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<PDFFailure>());
      expect(failure.message, contains('Corrupted'));
    });

    test('should merge more than two PDFs successfully', () async {
      // arrange
      const multiMergeResult = PDFOperationResult(
        operation: PDFOperation.merge,
        outputPaths: ['/tmp/merged_all.pdf'],
        originalSize: 307200,
        resultSize: 276480,
      );

      when(() => mockRepository.mergePDFs(any(),
              outputTitle: any(named: 'outputTitle')))
          .thenAnswer((_) async => const Right(multiMergeResult));

      // act
      final result = await useCase(const MergePDFsParams(
        pdfPaths: ['/tmp/a.pdf', '/tmp/b.pdf', '/tmp/c.pdf'],
        outputTitle: 'All Merged',
      ));

      // assert
      expect(result.isRight(), isTrue);
      final opResult =
          result.getOrElse(() => throw StateError('Expected Right'));
      expect(opResult.outputPath, '/tmp/merged_all.pdf');
      expect(opResult.wasCompressed, isTrue);
    });
  });
}
