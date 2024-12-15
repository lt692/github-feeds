import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:either_dart/either.dart';

import 'package:github_feed/core/failures/failure.dart';
import 'package:github_feed/features/feed/domain/entities/feed_source_entity.dart';
import 'package:github_feed/features/feed/domain/repositories/feed_repository.dart';
import 'package:github_feed/features/feed/domain/usecases/get_available_feeds_use_case.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository mockRepository;
  late GetAvailableFeedsUseCase useCase;

  setUp(() {
    mockRepository = MockFeedRepository();
    useCase = GetAvailableFeedsUseCase(mockRepository);
  });

  group('GetAvailableFeedsUseCase', () {
    final feedSources = [
      const FeedSourceEntity(
        name: 'GitHub',
        urlTemplate: 'https://github.com/{user}.atom',
        requiredParams: ['user'],
      ),
      const FeedSourceEntity(
        name: 'RSS Feed',
        urlTemplate: 'https://example.com/rss/{category}.atom',
        requiredParams: ['category'],
      ),
    ];

    test(
        'should return a list of FeedSourceEntity when repository returns Right',
        () async {
      when(() => mockRepository.getAvailableFeeds())
          .thenAnswer((_) async => Right(feedSources));

      final result = await useCase.execute();

      expect(result, Right(feedSources));
      verify(() => mockRepository.getAvailableFeeds()).called(1);
    });

    test('should return a Failure when repository returns Left', () async {
      const failure = Failure('Failed to fetch feeds');
      when(() => mockRepository.getAvailableFeeds())
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase.execute();

      expect(result, const Left(failure));
      verify(() => mockRepository.getAvailableFeeds()).called(1);
    });
  });
}
