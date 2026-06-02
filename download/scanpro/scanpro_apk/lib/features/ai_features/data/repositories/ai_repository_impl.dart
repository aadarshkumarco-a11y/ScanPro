import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ai_result.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_local_datasource.dart';
import '../datasources/ai_remote_datasource.dart';
import '../models/ai_result_model.dart';

/// Concrete implementation of [AiRepository].
///
/// Implements a cache-first strategy:
/// 1. Check local cache for existing results.
/// 2. If not cached, call the Gemini API via [AiRemoteDatasource].
/// 3. Cache the remote result via [AiLocalDatasource].
/// 4. Return the result.
///
/// All exceptions are caught and converted to [Failure] subclasses.
class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl({
    required AiRemoteDatasource remoteDatasource,
    required AiLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  final AiRemoteDatasource _remoteDatasource;
  final AiLocalDatasource _localDatasource;
  static const _uuid = Uuid();

  // ── Summarize ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, AiResult>> summarizeDocument({
    required String text,
    String? documentId,
    int maxWords = 200,
  }) async {
    try {
      // Check cache first.
      final cached = _localDatasource.findCachedResult(
        type: AiFeatureType.summary,
        inputText: text,
      );
      if (cached != null) {
        return Right(cached.toEntity());
      }

      // Call Gemini API.
      final responseText = await _remoteDatasource.summarize(
        text: text,
        maxWords: maxWords,
      );

      final result = _createResult(
        type: AiFeatureType.summary,
        inputText: text,
        resultText: responseText,
        documentId: documentId,
      );

      // Cache the result.
      await _localDatasource.saveResult(AiResultModel.fromEntity(result));

      return Right(result);
    } on AIException catch (e) {
      return Left(_mapAiException(e));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AIFailure.requestFailed());
    }
  }

  // ── Categorize ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, AiResult>> categorizeDocument({
    required String text,
    String? documentId,
  }) async {
    try {
      // Check cache.
      final cached = _localDatasource.findCachedResult(
        type: AiFeatureType.categorize,
        inputText: text,
      );
      if (cached != null) {
        return Right(cached.toEntity());
      }

      final responseText = await _remoteDatasource.categorize(text: text);

      final metadata = _parseJsonResponse(responseText);
      final result = _createResult(
        type: AiFeatureType.categorize,
        inputText: text,
        resultText: responseText,
        documentId: documentId,
        metadata: metadata,
      );

      await _localDatasource.saveResult(AiResultModel.fromEntity(result));

      return Right(result);
    } on AIException catch (e) {
      return Left(_mapAiException(e));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AIFailure.requestFailed());
    }
  }

  // ── Smart Rename ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, AiResult>> smartRename({
    required String text,
    String currentName = '',
    String? documentId,
  }) async {
    try {
      final cached = _localDatasource.findCachedResult(
        type: AiFeatureType.rename,
        inputText: text,
      );
      if (cached != null) {
        return Right(cached.toEntity());
      }

      final responseText = await _remoteDatasource.smartRename(
        text: text,
        currentName: currentName,
      );

      final metadata = _parseJsonResponse(responseText);
      final result = _createResult(
        type: AiFeatureType.rename,
        inputText: text,
        resultText: responseText,
        documentId: documentId,
        metadata: metadata,
      );

      await _localDatasource.saveResult(AiResultModel.fromEntity(result));

      return Right(result);
    } on AIException catch (e) {
      return Left(_mapAiException(e));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AIFailure.requestFailed());
    }
  }

  // ── Extract Key Info ────────────────────────────────────────────────

  @override
  Future<Either<Failure, AiResult>> extractKeyInfo({
    required String text,
    String? documentId,
  }) async {
    try {
      final cached = _localDatasource.findCachedResult(
        type: AiFeatureType.extract,
        inputText: text,
      );
      if (cached != null) {
        return Right(cached.toEntity());
      }

      final responseText = await _remoteDatasource.extractKeyInfo(text: text);

      final metadata = _parseJsonResponse(responseText);
      final result = _createResult(
        type: AiFeatureType.extract,
        inputText: text,
        resultText: responseText,
        documentId: documentId,
        metadata: metadata,
      );

      await _localDatasource.saveResult(AiResultModel.fromEntity(result));

      return Right(result);
    } on AIException catch (e) {
      return Left(_mapAiException(e));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AIFailure.requestFailed());
    }
  }

  // ── Ask Question ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, AiResult>> askQuestion({
    required String text,
    required String question,
    String? documentId,
  }) async {
    try {
      final responseText = await _remoteDatasource.askQuestion(
        text: text,
        question: question,
      );

      final result = _createResult(
        type: AiFeatureType.qa,
        inputText: 'Q: $question\n\nDocument: ${text.substring(0, text.length.clamp(0, 500))}',
        resultText: responseText,
        documentId: documentId,
      );

      await _localDatasource.saveResult(AiResultModel.fromEntity(result));

      return Right(result);
    } on AIException catch (e) {
      return Left(_mapAiException(e));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(AIFailure.requestFailed());
    }
  }

  // ── Get Results ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<AiResult>>> getAiResults({
    AiFeatureType? type,
  }) async {
    try {
      final models = _localDatasource.getResults(type: type);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get AI results: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Creates an [AiResult] with a unique ID and current timestamp.
  AiResult _createResult({
    required AiFeatureType type,
    required String inputText,
    required String resultText,
    String? documentId,
    Map<String, dynamic> metadata = const {},
  }) {
    final enrichedMetadata = {
      ...metadata,
      if (documentId != null) 'documentId': documentId,
    };

    return AiResult(
      id: _uuid.v4(),
      type: type,
      inputText: inputText,
      resultText: resultText,
      createdAt: DateTime.now(),
      metadata: enrichedMetadata,
    );
  }

  /// Attempts to parse a JSON response from the AI.
  ///
  /// If the response is not valid JSON, returns an empty map.
  Map<String, dynamic> _parseJsonResponse(String response) {
    try {
      // Try to extract JSON from markdown code blocks.
      var cleaned = response.trim();
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      }
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      cleaned = cleaned.trim();

      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      // If parsing fails, return raw text in metadata.
      return {'raw_response': response};
    }
  }

  /// Maps an [AIException] to the appropriate [AIFailure].
  AIFailure _mapAiException(AIException e) {
    if (e.code == 9002) return AIFailure.rateLimited();
    if (e.code == 9003) return AIFailure.timeout();
    if (e.code == 9004) return AIFailure.invalidResponse();
    return AIFailure(message: e.message, code: e.code);
  }
}
