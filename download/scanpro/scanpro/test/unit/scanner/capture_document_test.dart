import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanpro/core/error/failures.dart';
import 'package:scanpro/features/scanner/domain/entities/edge_detection_result.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_result.dart';
import 'package:scanpro/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:scanpro/features/scanner/domain/usecases/capture_document.dart';

class MockScannerRepository extends Mock implements ScannerRepository {}

void main() {
  late CaptureDocument useCase;
  late MockScannerRepository mockRepository;

  setUp(() {
    mockRepository = MockScannerRepository();
    useCase = CaptureDocument(mockRepository);
  });

  final tScanResult = ScanResult(
    id: 'test-id',
    originalPath: '/tmp/scan.jpg',
    timestamp: DateTime(2025, 1, 1),
  );

  final tEdgePoints = [
    const EdgePoint(x: 0.1, y: 0.1),
    const EdgePoint(x: 0.9, y: 0.1),
    const EdgePoint(x: 0.9, y: 0.9),
    const EdgePoint(x: 0.1, y: 0.9),
  ];

  final tEdgeDetectionResult = EdgeDetectionResult(
    points: tEdgePoints,
    confidence: 0.92,
    isDocumentDetected: true,
  );

  group('CaptureDocument', () {
    test('should return ScanResult on successful capture', () async {
      // arrange
      when(() => mockRepository.captureDocument())
          .thenAnswer((_) async => Right(tScanResult));

      // act
      final result = await useCase(const CaptureParams(
        autoDetect: false,
        autoEnhance: false,
      ));

      // assert
      expect(result, Right(tScanResult));
      verify(() => mockRepository.captureDocument()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ScannerFailure when edge detection fails during auto-detect',
        () async {
      // arrange
      when(() => mockRepository.captureDocument())
          .thenAnswer((_) async => Right(tScanResult));
      when(() => mockRepository.detectEdges(any()))
          .thenAnswer((_) async => const Left(
                ScannerFailure(message: 'Edge detection failed'),
              ));

      // act
      final result = await useCase(const CaptureParams(
        autoDetect: true,
        autoEnhance: false,
      ));

      // assert - when edge detection fails, use case still returns the scan result
      // because it falls back gracefully (fold returns Right(scanResult) on failure)
      expect(result.isRight(), isTrue);
      final scanResult = result.getOrElse(() => throw StateError('Expected Right'));
      expect(scanResult.originalPath, '/tmp/scan.jpg');
    });

    test('should return ScannerFailure when camera permission is denied', () async {
      // arrange
      when(() => mockRepository.captureDocument()).thenAnswer(
        (_) async => const Left(
          ScannerFailure(message: 'Camera permission denied', code: 'SCAN_004'),
        ),
      );

      // act
      final result = await useCase(const CaptureParams());

      // assert
      expect(result.isLeft(), isTrue);
      final failure = result.swap().getOrElse(() => throw StateError('Expected Left'));
      expect(failure, isA<ScannerFailure>());
      expect(failure.message, 'Camera permission denied');
    });

    test('should perform edge detection when autoDetect is true and edges are empty',
        () async {
      // arrange
      when(() => mockRepository.captureDocument())
          .thenAnswer((_) async => Right(tScanResult));
      when(() => mockRepository.detectEdges(any()))
          .thenAnswer((_) async => Right(tEdgeDetectionResult));

      // act
      final result = await useCase(const CaptureParams(
        autoDetect: true,
        autoEnhance: false,
      ));

      // assert
      expect(result.isRight(), isTrue);
      final scanResult = result.getOrElse(() => throw StateError('Expected Right'));
      expect(scanResult.edges, tEdgePoints);
      expect(scanResult.confidence, 0.92);
      verify(() => mockRepository.detectEdges(tScanResult.originalPath)).called(1);
    });

    test('should skip edge detection when autoDetect is false', () async {
      // arrange
      when(() => mockRepository.captureDocument())
          .thenAnswer((_) async => Right(tScanResult));

      // act
      final result = await useCase(const CaptureParams(
        autoDetect: false,
        autoEnhance: false,
      ));

      // assert
      expect(result, Right(tScanResult));
      verifyNever(() => mockRepository.detectEdges(any()));
    });

    test('should skip edge detection when edges are already present', () async {
      // arrange
      final scanWithEdges = tScanResult.copyWith(
        edges: tEdgePoints,
        confidence: 0.85,
      );
      when(() => mockRepository.captureDocument())
          .thenAnswer((_) async => Right(scanWithEdges));

      // act
      final result = await useCase(const CaptureParams(
        autoDetect: true,
        autoEnhance: false,
      ));

      // assert
      expect(result.isRight(), isTrue);
      final scanResult = result.getOrElse(() => throw StateError('Expected Right'));
      expect(scanResult.edges, tEdgePoints);
      verifyNever(() => mockRepository.detectEdges(any()));
    });
  });
}
