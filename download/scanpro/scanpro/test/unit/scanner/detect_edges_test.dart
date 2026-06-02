import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/edge_detection_result.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:scanpro/features/scanner/domain/usecases/detect_edges.dart';

class MockScannerRepository extends Mock implements ScannerRepository {}

void main() {
  late DetectEdges useCase;
  late MockScannerRepository mockRepository;

  setUp(() {
    mockRepository = MockScannerRepository();
    useCase = DetectEdges(mockRepository);
  });

  final tEdgePoints = [
    const EdgePoint(x: 0.1, y: 0.1),
    const EdgePoint(x: 0.9, y: 0.1),
    const EdgePoint(x: 0.9, y: 0.9),
    const EdgePoint(x: 0.1, y: 0.9),
  ];

  group('DetectEdges', () {
    test('should return EdgeDetectionResult on successful edge detection',
        () async {
      // arrange
      const tResult = EdgeDetectionResult(
        points: [
          EdgePoint(x: 0.1, y: 0.1),
          EdgePoint(x: 0.9, y: 0.1),
          EdgePoint(x: 0.9, y: 0.9),
          EdgePoint(x: 0.1, y: 0.9),
        ],
        confidence: 0.95,
        isDocumentDetected: true,
      );

      when(() => mockRepository.detectEdges(any()))
          .thenAnswer((_) async => const Right(tResult));

      // act
      final result = await useCase(
        const DetectEdgesParams(imagePath: '/tmp/document.jpg'),
      );

      // assert
      expect(result.isRight(), isTrue);
      final edgeResult =
          result.getOrElse(() => throw StateError('Expected Right'));
      expect(edgeResult.isDocumentDetected, isTrue);
      expect(edgeResult.confidence, 0.95);
      expect(edgeResult.points.length, 4);
      expect(edgeResult.hasValidPoints, isTrue);
    });

    test('should return not-detected result when no document found', () async {
      // arrange
      const tResult = EdgeDetectionResult.notDetected();

      when(() => mockRepository.detectEdges(any()))
          .thenAnswer((_) async => const Right(tResult));

      // act
      final result = await useCase(
        const DetectEdgesParams(imagePath: '/tmp/blank.jpg'),
      );

      // assert
      expect(result.isRight(), isTrue);
      final edgeResult =
          result.getOrElse(() => throw StateError('Expected Right'));
      expect(edgeResult.isDocumentDetected, isFalse);
      expect(edgeResult.confidence, 0.0);
      expect(edgeResult.points, isEmpty);
      expect(edgeResult.hasValidPoints, isFalse);
    });

    test('should return result with low confidence when detection is uncertain',
        () async {
      // arrange
      const tResult = EdgeDetectionResult(
        points: [
          EdgePoint(x: 0.15, y: 0.15),
          EdgePoint(x: 0.85, y: 0.12),
          EdgePoint(x: 0.88, y: 0.88),
          EdgePoint(x: 0.12, y: 0.85),
        ],
        confidence: 0.35,
        isDocumentDetected: true,
      );

      when(() => mockRepository.detectEdges(any()))
          .thenAnswer((_) async => const Right(tResult));

      // act
      final result = await useCase(
        const DetectEdgesParams(imagePath: '/tmp/blurry.jpg'),
      );

      // assert
      expect(result.isRight(), isTrue);
      final edgeResult =
          result.getOrElse(() => throw StateError('Expected Right'));
      expect(edgeResult.isDocumentDetected, isTrue);
      expect(edgeResult.confidence, lessThan(0.7));
      expect(edgeResult.hasValidPoints, isTrue);
    });

    test('should return ValidationFailure when image path is empty', () async {
      // act
      final result = await useCase(
        const DetectEdgesParams(imagePath: ''),
      );

      // assert
      expect(result.isLeft(), isTrue);
      final failure = result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Image path cannot be empty');
      verifyNever(() => mockRepository.detectEdges(any()));
    });

    test('should return ScannerFailure when repository fails', () async {
      // arrange
      when(() => mockRepository.detectEdges(any())).thenAnswer(
        (_) async => const Left(
          ScannerFailure(message: 'Edge detection error', code: 'SCAN_002'),
        ),
      );

      // act
      final result = await useCase(
        const DetectEdgesParams(imagePath: '/tmp/corrupt.jpg'),
      );

      // assert
      expect(result.isLeft(), isTrue);
      final failure = result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<ScannerFailure>());
    });
  });
}
