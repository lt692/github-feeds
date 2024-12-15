import 'package:either_dart/either.dart';

import '../../../../core/failures/failure.dart';
import '../entities/feed_source_entity.dart';
import '../repositories/feed_repository.dart';

class GetAvailableFeedsUseCase {
  final FeedRepository repository;

  const GetAvailableFeedsUseCase(this.repository);

  Future<Either<Failure, List<FeedSourceEntity>>> execute() async {
    return await repository.getAvailableFeeds();
  }
}
