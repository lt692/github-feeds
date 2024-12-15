import 'package:either_dart/either.dart';
import 'package:github_feed/core/failures/network_failure.dart';
import 'package:github_feed/features/feed/data/datasources/atom_feed_local_data_source.dart';
import 'package:github_feed/features/feed/data/datasources/atom_feed_remote_data_source.dart';
import 'package:webfeed_revised/domain/atom_feed.dart';
import 'package:webfeed_revised/domain/atom_item.dart';

import '../../../../core/failures/cache_failure.dart';
import '../../../../core/failures/failure.dart';
import '../../../../core/failures/feed_failure.dart';
import '../../domain/entities/feed_source_entity.dart';
import '../../domain/repositories/feed_repository.dart';
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
      final cachedModels = await availableFeedsLocalDataSource.get();

      if (cachedModels.isNotEmpty) {
        final entities = cachedModels.map((model) => model.toEntity()).toList();
        return Right(entities);
      }

      final models = await availableFeedsRemoteDataSource.fetch();
      final entities = models.map((model) => model.toEntity()).toList();

      await availableFeedsLocalDataSource.save(models);

      return Right(entities);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AtomFeed>> getAtomFeed(String feedUrl) async {
    try {
      String? remoteXml;
      final cachedXmls = await atomFeedLocalDataSource.getAll(feedUrl);
      try {
        remoteXml = await atomFeedRemoteDataSource.fetch(feedUrl);
      } on FeedFailure catch (e) {
        return Left(e);
      } catch (_) {
        // Continue
      }

      if (remoteXml != null) {
        await atomFeedLocalDataSource.save(feedUrl, remoteXml);
      }
      final aggregatedFeed = await _aggregateFeeds(cachedXmls, remoteXml);

      if (cachedXmls.isEmpty && remoteXml == null) {
        return const Left(Failure("Turn on internet"));
      }

      return Right(aggregatedFeed);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<AtomFeed> _aggregateFeeds(
    List<String> cachedXmls,
    String? remoteXml,
  ) async {
    final allItems = <String, AtomItem>{};

    for (var cachedXml in cachedXmls) {
      final cachedFeed = AtomFeed.parse(cachedXml);
      if (cachedFeed.items != null) {
        for (var item in cachedFeed.items!) {
          allItems[item.id ?? item.title ?? ''] = item;
        }
      }
    }

    if (remoteXml != null) {
      final remoteFeed = AtomFeed.parse(remoteXml);
      if (remoteFeed.items != null) {
        for (var item in remoteFeed.items!) {
          allItems[item.id ?? item.title ?? ''] = item;
        }
      }
    }

    final aggregatedItems = allItems.values.toList();
    aggregatedItems.sort((a, b) {
      if (a.updated == null || b.updated == null) {
        return 0;
      }
      return b.updated!.compareTo(a.updated!);
    });

    return AtomFeed(
      id: remoteXml != null ? AtomFeed.parse(remoteXml).id : '',
      title: remoteXml != null ? AtomFeed.parse(remoteXml).title : '',
      updated: remoteXml != null ? AtomFeed.parse(remoteXml).updated : null,
      items: aggregatedItems,
    );
  }
}
