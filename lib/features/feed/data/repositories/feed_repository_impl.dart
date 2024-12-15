import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:webfeed_revised/domain/atom_feed.dart';

import '../../../../core/failures/cache_failure.dart';
import '../../../../core/failures/failure.dart';
import '../../../../core/failures/feed_failure.dart';
import '../../../../core/failures/network_failure.dart';
import '../../domain/entities/feed_source_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/atom_feed_local_data_source.dart';
import '../datasources/atom_feed_remote_data_source.dart';
import '../datasources/available_feeds_local_data_source.dart';
import '../datasources/available_feeds_remote_data_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  final AvailableFeedsLocalDataSource availableFeedsLocalDataSource;
  final AvailableFeedsRemoteDataSource availableFeedsRemoteDataSource;

  final AtomFeedLocalDataSource atomFeedLocalDataSource;
  final AtomFeedRemoteDataSource atomFeedRemoteDataSource;

  const FeedRepositoryImpl({
    required this.availableFeedsLocalDataSource,
    required this.availableFeedsRemoteDataSource,
    required this.atomFeedLocalDataSource,
    required this.atomFeedRemoteDataSource,
  });

  @override
  Future<Either<Failure, List<FeedSourceEntity>>> getAvailableFeeds() async {
    try {
      final models = await availableFeedsRemoteDataSource.fetch();
      final feedSources = models.map((model) => model.toEntity()).toList();
      await availableFeedsLocalDataSource.save(models);
      return Right(feedSources);
    } on DioException catch (_) {
      try {
        final cachedModels = await availableFeedsLocalDataSource.get();
        if (cachedModels.isNotEmpty) {
          final entities =
              cachedModels.map((model) => model.toEntity()).toList();
          return Right(entities);
        }
      } catch (e) {
        return Left(CacheFailure('Failed to fetch from cache'));
      }

      return Left(NetworkFailure('Cmon. Turn on internet :)'));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AtomFeed>> getAtomFeed(String feedUrl) async {
    try {
      final remoteXml = await atomFeedRemoteDataSource.fetch(feedUrl);
      await atomFeedLocalDataSource.save(feedUrl, remoteXml);
      final feed = AtomFeed.parse(remoteXml);
      return Right(feed);
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode;
      switch (statusCode) {
        case 404:
          return Left(FeedFailure('User is private'));
        default:
          try {
            final cachedFeed = await atomFeedLocalDataSource.get(feedUrl);
            if (cachedFeed != null) {
              final feed = AtomFeed.parse(cachedFeed);
              return Right(feed);
            }
          } catch (e) {
            return Left(CacheFailure('Failed to fetch from cache'));
          }
          return Left(NetworkFailure('Check internet connection'));
      }
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
