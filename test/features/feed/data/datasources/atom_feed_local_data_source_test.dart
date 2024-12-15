import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:github_feed/features/feed/data/datasources/atom_feed_local_data_source.dart';

void main() {
  group('AtomFeedLocalDataSource Tests', () {
    late AtomFeedLocalDataSourceImpl atomFeedLocalDataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      atomFeedLocalDataSource = AtomFeedLocalDataSourceImpl();
    });

    test('save and get should store and retrieve data correctly', () async {
      const feedUrl = 'https://example.com/feed';
      const xml = '<feed>data</feed>';
      
      await atomFeedLocalDataSource.save(feedUrl, xml);
      
      final result = await atomFeedLocalDataSource.get(feedUrl);
      expect(result, xml);
    });

    test('get should return null when no data is saved', () async {
      const feedUrl = 'https://example.com/feed';
      
      final result = await atomFeedLocalDataSource.get(feedUrl);
      expect(result, isNull);
    });

    test('get should handle error gracefully if SharedPreferences fails', () async {
      const feedUrl = 'https://example.com/feed';

      // Simulating a failure scenario (e.g., by removing the key)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(feedUrl);

      final result = await atomFeedLocalDataSource.get(feedUrl);
      expect(result, isNull);
    });
  });
}
