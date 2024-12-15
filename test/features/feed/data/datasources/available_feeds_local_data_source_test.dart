import 'package:flutter_test/flutter_test.dart';
import 'package:github_feed/features/feed/data/datasources/available_feeds_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:github_feed/features/feed/data/models/feed_source_model.dart';

void main() {
  group('FeedLocalDataSourceImpl Tests', () {
    late FeedLocalDataSourceImpl feedLocalDataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      feedLocalDataSource = FeedLocalDataSourceImpl();
    });

    test('save should store and retrieve data correctly', () async {
      final feeds = [
        FeedSourceModel(
          name: 'Feed 1',
          urlTemplate: 'https://example.com/feed1',
        ),
        FeedSourceModel(
          name: 'Feed 2',
          urlTemplate: 'https://example.com/feed2',
        ),
      ];

      await feedLocalDataSource.save(feeds);

      final result = await feedLocalDataSource.get();
      expect(result, isNotEmpty);
      expect(result.length, feeds.length);
      expect(result[0].name, feeds[0].name);
      expect(result[1].urlTemplate, feeds[1].urlTemplate);
    });

    test('get should return empty list when no data is saved', () async {
      final result = await feedLocalDataSource.get();
      expect(result, isEmpty);
    });

    test('clear should remove cached data', () async {
      final feeds = [
        FeedSourceModel(
          name: 'Feed 1',
          urlTemplate: 'https://example.com/feed1',
        )
      ];

      await feedLocalDataSource.save(feeds);
      await feedLocalDataSource.clear();

      final result = await feedLocalDataSource.get();
      expect(result, isEmpty);
    });
  });
}
