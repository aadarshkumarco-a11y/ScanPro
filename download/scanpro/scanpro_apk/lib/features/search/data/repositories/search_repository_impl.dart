import 'package:dartz/dartz.dart';
import 'package:scanpro/core/errors/exceptions.dart';
import 'package:scanpro/core/errors/failures.dart';
import 'package:scanpro/features/search/data/datasources/search_local_datasource.dart';
import 'package:scanpro/features/search/domain/entities/search_result.dart';
import 'package:scanpro/features/search/domain/repositories/search_repository.dart';

/// Concrete implementation of [SearchRepository].
///
/// Delegates search operations to [SearchLocalDatasource] and
/// converts all exceptions to appropriate [Failure] subclasses.
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({
    required SearchLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  final SearchLocalDatasource _localDatasource;

  @override
  Future<Either<Failure, List<SearchResult>>> search(String query) async {
    try {
      final models = _localDatasource.search(query);
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to search: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchByTag(String tag) async {
    try {
      final models = _localDatasource.searchByTag(tag);
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to search by tag: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchByOcrText(
    String query,
  ) async {
    try {
      final models = _localDatasource.searchByOcrText(query);
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to search OCR text: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getRecentSearches() async {
    try {
      final searches = _localDatasource.getRecentSearches();
      return Right(searches);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get recent searches: ${e.toString()}',
        code: 1003,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearRecentSearches() async {
    try {
      await _localDatasource.clearRecentSearches();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to clear recent searches: ${e.toString()}',
        code: 1002,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveRecentSearch(String query) async {
    try {
      await _localDatasource.saveRecentSearch(query);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to save recent search: ${e.toString()}',
        code: 1002,
      ));
    }
  }
}
