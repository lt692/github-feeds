import 'package:either_dart/either.dart';
import 'package:webfeed_revised/webfeed_revised.dart';

import '../../../../core/failures/failure.dart';
import '../repositories/feed_repository.dart';

class GetAtomFeedUseCase {
  final FeedRepository repository;

  const GetAtomFeedUseCase(this.repository);

  Future<Either<Failure, AtomFeed>> execute(String feedUrl) async {
    return await repository.getAtomFeed(feedUrl);
  }
}
