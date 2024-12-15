import 'package:shared_preferences/shared_preferences.dart';

abstract class AtomFeedLocalDataSource {
  Future<void> save(String feedUrl, String xml);
  Future<List<String>> getAll(String feedUrl);
}

class AtomFeedLocalDataSourceImpl implements AtomFeedLocalDataSource {
  @override
  Future<void> save(String feedUrl, String xml) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedAtomFeeds = prefs.getStringList(feedUrl) ?? [];
    cachedAtomFeeds.add(xml);

    await prefs.setStringList(feedUrl, cachedAtomFeeds);
  }

  @override
  Future<List<String>> getAll(String feedUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedAtomFeeds = prefs.getStringList(feedUrl) ?? [];
      return cachedAtomFeeds;
    } catch (e) {
      return [];
    }
  }
}
