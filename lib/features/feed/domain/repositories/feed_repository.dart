import 'package:either_dart/either.dart';
import 'package:webfeed_revised/domain/atom_feed.dart';

import '../../../../core/failures/failure.dart';
import '../entities/feed_source_entity.dart';

abstract class FeedRepository {
  Future<Either<Failure, List<FeedSourceEntity>>> getAvailableFeeds();
  Future<Either<Failure, AtomFeed>> getAtomFeed(String feedUrl);
}
