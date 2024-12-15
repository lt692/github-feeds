import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_feed/core/failures/failure.dart';
import 'package:mocktail/mocktail.dart';
import 'package:webfeed_revised/domain/atom_feed.dart';

import 'package:github_feed/features/feed/domain/entities/feed_source_entity.dart';
import 'package:github_feed/features/feed/domain/usecases/get_atom_feed_use_case.dart';
import 'package:github_feed/features/feed/domain/usecases/get_available_feeds_use_case.dart';
import 'package:github_feed/features/feed/presentation/bloc/feed_bloc.dart';

class MockGetAvailableFeedsUseCase extends Mock
    implements GetAvailableFeedsUseCase {}

class MockGetAtomFeedUseCase extends Mock implements GetAtomFeedUseCase {}

void main() {
  late MockGetAvailableFeedsUseCase mockGetAvailableFeedsUseCase;
  late MockGetAtomFeedUseCase mockGetAtomFeedUseCase;
  late FeedBloc feedBloc;

  setUp(() {
    mockGetAvailableFeedsUseCase = MockGetAvailableFeedsUseCase();
    mockGetAtomFeedUseCase = MockGetAtomFeedUseCase();
    feedBloc = FeedBloc(
      getAvailableFeedsUseCase: mockGetAvailableFeedsUseCase,
      getAtomFeedUseCase: mockGetAtomFeedUseCase,
    );
  });

  group('FeedBloc', () {
    const feedSourceEntities = [
      FeedSourceEntity(
        name: 'GitHub',
        urlTemplate: 'https://github.com/{user}.atom',
        requiredParams: ['user'],
      ),
      FeedSourceEntity(
        name: 'RSS Feed',
        urlTemplate: 'https://example.com/rss/{category}.atom',
        requiredParams: ['category'],
      ),
    ];

    const feedUrl = 'https://github.com/example.atom';
    final atomFeed = AtomFeed();

    test('initial state is FeedState.initial()', () {
      expect(feedBloc.state, const FeedState.initial());
    });

    blocTest<FeedBloc, FeedState>(
      'emits [loading, loaded] when _Started event is added and fetch is successful',
      build: () {
        when(() => mockGetAvailableFeedsUseCase.execute())
            .thenAnswer((_) async => const Right(feedSourceEntities));
        return feedBloc;
      },
      act: (bloc) => bloc.add(const FeedEvent.started()),
      expect: () => [
        const FeedState.loading(),
        const FeedState.loaded(feedSourceEntities),
      ],
      verify: (_) {
        verify(() => mockGetAvailableFeedsUseCase.execute()).called(1);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'emits [loading, error] when _Started event is added and fetch fails',
      build: () {
        when(() => mockGetAvailableFeedsUseCase.execute()).thenAnswer(
            (_) async => const Left(Failure('Failed to fetch feeds')));
        return feedBloc;
      },
      act: (bloc) => bloc.add(const FeedEvent.started()),
      expect: () => [
        const FeedState.loading(),
        const FeedState.error('Failed to fetch feeds'),
      ],
      verify: (_) {
        verify(() => mockGetAvailableFeedsUseCase.execute()).called(1);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'emits [loading, loadedAtom] when _StartedAtom event is added and fetch is successful',
      build: () {
        when(() => mockGetAtomFeedUseCase.execute(feedUrl))
            .thenAnswer((_) async => Right(atomFeed));
        return feedBloc;
      },
      act: (bloc) => bloc.add(const FeedEvent.startedAtom(feedUrl)),
      expect: () => [
        const FeedState.loading(),
        FeedState.loadedAtom(atomFeed),
      ],
      verify: (_) {
        verify(() => mockGetAtomFeedUseCase.execute(feedUrl)).called(1);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'emits [loading, error] when _StartedAtom event is added and fetch fails',
      build: () {
        when(() => mockGetAtomFeedUseCase.execute(feedUrl)).thenAnswer(
            (_) async => const Left(Failure('Failed to fetch feed')));
        return feedBloc;
      },
      act: (bloc) => bloc.add(const FeedEvent.startedAtom(feedUrl)),
      expect: () => [
        const FeedState.loading(),
        const FeedState.error('Failed to fetch feed'),
      ],
      verify: (_) {
        verify(() => mockGetAtomFeedUseCase.execute(feedUrl)).called(1);
      },
    );
  });
}
