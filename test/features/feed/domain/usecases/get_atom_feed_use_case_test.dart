import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:either_dart/either.dart';
import 'package:webfeed_revised/webfeed_revised.dart';

import 'package:github_feed/features/feed/domain/usecases/get_atom_feed_use_case.dart';
import 'package:github_feed/features/feed/domain/repositories/feed_repository.dart';
import 'package:github_feed/core/failures/network_failure.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository mockRepository;
  late GetAtomFeedUseCase useCase;

  setUp(() {
    mockRepository = MockFeedRepository();
    useCase = GetAtomFeedUseCase(mockRepository);
  });

  group('GetAtomFeedUseCase', () {
    const feedUrl = 'https://example.com/feed.atom';
    final mockAtomFeed = AtomFeed(title: 'Mock Feed');

    test('should return AtomFeed when repository returns Right', () async {
      when(() => mockRepository.getAtomFeed(feedUrl))
          .thenAnswer((_) async => Right(mockAtomFeed));

      final result = await useCase.execute(feedUrl);

      expect(result, Right(mockAtomFeed));
      verify(() => mockRepository.getAtomFeed(feedUrl)).called(1);
    });

    test('should return Failure when repository returns Left', () async {
      var failure = NetworkFailure('No internet connection');
      when(() => mockRepository.getAtomFeed(feedUrl))
          .thenAnswer((_) async => Left(failure));

      final result = await useCase.execute(feedUrl);

      expect(result, Left(failure));
      verify(() => mockRepository.getAtomFeed(feedUrl)).called(1);
    });
  });
}
