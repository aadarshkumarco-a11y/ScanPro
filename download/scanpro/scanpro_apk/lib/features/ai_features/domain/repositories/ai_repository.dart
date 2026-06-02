import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/ai_features/domain/entities/ai_result.dart';

/// Abstract repository contract for AI feature operations.
///
/// Defines the domain-level API for document summarization,
/// categorization, smart rename, key info extraction, and Q&A.
/// Implementations must convert data-layer exceptions into [Failure]s.
abstract class AiRepository {
  /// Summarizes the document at [documentId] or with [text].
  ///
  /// [maxWords] caps the summary length (default 200).
  /// Returns an [AiResult] of type [AiFeatureType.summary].
  Future<Either<Failure, AiResult>> summarizeDocument({
    required String text,
    String? documentId,
    int maxWords = 200,
  });

  /// Categorizes the document and returns suggested categories.
  ///
  /// Returns an [AiResult] of type [AiFeatureType.categorize]
  /// with categories in the metadata map.
  Future<Either<Failure, AiResult>> categorizeDocument({
    required String text,
    String? documentId,
  });

  /// Generates smart rename suggestions for the document.
  ///
  /// Returns an [AiResult] of type [AiFeatureType.rename]
  /// with suggested names in the metadata map.
  Future<Either<Failure, AiResult>> smartRename({
    required String text,
    String currentName,
    String? documentId,
  });

  /// Extracts key information and data points from the document.
  ///
  /// Returns an [AiResult] of type [AiFeatureType.extract]
  /// with structured key-value pairs in the metadata map.
  Future<Either<Failure, AiResult>> extractKeyInfo({
    required String text,
    String? documentId,
  });

  /// Answers a user question about the document content.
  ///
  /// Returns an [AiResult] of type [AiFeatureType.qa].
  Future<Either<Failure, AiResult>> askQuestion({
    required String text,
    required String question,
    String? documentId,
  });

  /// Retrieves all cached AI results, optionally filtered by [type].
  ///
  /// Returns a list of [AiResult] ordered by most recent first.
  Future<Either<Failure, List<AiResult>>> getAiResults({
    AiFeatureType? type,
  });
}
