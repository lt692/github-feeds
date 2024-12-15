import 'package:flutter_test/flutter_test.dart';
import 'package:github_feed/core/failures/network_failure.dart';
import 'package:github_feed/features/feed/data/datasources/atom_feed_local_data_source.dart';
import 'package:github_feed/features/feed/data/datasources/atom_feed_remote_data_source.dart';
import 'package:github_feed/features/feed/data/datasources/available_feeds_local_data_source.dart';
import 'package:github_feed/features/feed/data/datasources/available_feeds_remote_data_source.dart';
import 'package:github_feed/features/feed/data/models/feed_source_model.dart';
import 'package:github_feed/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

class MockAvailableFeedsRemoteDataSource extends Mock
    implements AvailableFeedsRemoteDataSource {}

class MockAvailableFeedsLocalDataSource extends Mock
    implements AvailableFeedsLocalDataSource {}

class MockAtomFeedRemoteDataSource extends Mock
    implements AtomFeedRemoteDataSource {}

class MockAtomFeedLocalDataSource extends Mock
    implements AtomFeedLocalDataSource {}

void main() {
  late MockAvailableFeedsRemoteDataSource mockAvailableFeedsRemoteDataSource;
  late MockAvailableFeedsLocalDataSource mockAvailableFeedsLocalDataSource;
  late MockAtomFeedRemoteDataSource mockAtomFeedRemoteDataSource;
  late MockAtomFeedLocalDataSource mockAtomFeedLocalDataSource;
  late FeedRepositoryImpl repository;

  setUp(() {
    mockAvailableFeedsRemoteDataSource = MockAvailableFeedsRemoteDataSource();
    mockAvailableFeedsLocalDataSource = MockAvailableFeedsLocalDataSource();
    mockAtomFeedRemoteDataSource = MockAtomFeedRemoteDataSource();
    mockAtomFeedLocalDataSource = MockAtomFeedLocalDataSource();
    repository = FeedRepositoryImpl(
      availableFeedsRemoteDataSource: mockAvailableFeedsRemoteDataSource,
      availableFeedsLocalDataSource: mockAvailableFeedsLocalDataSource,
      atomFeedRemoteDataSource: mockAtomFeedRemoteDataSource,
      atomFeedLocalDataSource: mockAtomFeedLocalDataSource,
    );

    registerFallbackValue(<FeedSourceModel>[]);
  });

  group('getAvailableFeeds', () {
    test('should return a list of feed sources when remote fetch is successful',
        () async {
      final mockFeedModels = [
        FeedSourceModel(
            name: 'Feed1', urlTemplate: 'https://example.com/feed1'),
        FeedSourceModel(
            name: 'Feed2', urlTemplate: 'https://example.com/feed2'),
      ];

      when(() => mockAvailableFeedsRemoteDataSource.fetch())
          .thenAnswer((_) async => mockFeedModels);
      when(() => mockAvailableFeedsLocalDataSource.save(any()))
          .thenAnswer((_) async {});

      final result = await repository.getAvailableFeeds();

      expect(result.isRight, true);
      expect(
        result.right,
        mockFeedModels.map((model) => model.toEntity()).toList(),
      );

      verify(() => mockAvailableFeedsRemoteDataSource.fetch()).called(1);
      verify(() => mockAvailableFeedsLocalDataSource.save(mockFeedModels))
          .called(1);
    });

    test(
        'should return a list of feed sources from cache when remote fetch fails',
        () async {
      final mockFeedModels = [
        FeedSourceModel(
            name: 'Feed1', urlTemplate: 'https://example.com/feed1'),
        FeedSourceModel(
            name: 'Feed2', urlTemplate: 'https://example.com/feed2'),
      ];

      // Simulate a network failure
      when(() => mockAvailableFeedsRemoteDataSource.fetch())
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      ));

      when(() => mockAvailableFeedsLocalDataSource.get())
          .thenAnswer((_) async => mockFeedModels);

      final result = await repository.getAvailableFeeds();

      expect(result.isRight, true);
      expect(
        result.right,
        mockFeedModels.map((model) => model.toEntity()).toList(),
      );

      verify(() => mockAvailableFeedsRemoteDataSource.fetch()).called(1);
      verify(() => mockAvailableFeedsLocalDataSource.get()).called(1);
    });

    test(
        'should return CacheFailure when remote fetch fails and cache is empty',
        () async {
      when(() => mockAvailableFeedsRemoteDataSource.fetch())
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.unknown,
      ));

      when(() => mockAvailableFeedsLocalDataSource.get())
          .thenAnswer((_) async => []);

      final result = await repository.getAvailableFeeds();

      expect(result.isLeft, true);
      expect(result.left, isA<NetworkFailure>());

      verify(() => mockAvailableFeedsRemoteDataSource.fetch()).called(1);
      verify(() => mockAvailableFeedsLocalDataSource.get()).called(1);
    });
  });
}
