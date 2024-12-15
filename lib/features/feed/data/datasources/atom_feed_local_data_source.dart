import 'package:shared_preferences/shared_preferences.dart';

abstract class AtomFeedLocalDataSource {
  Future<void> save(String feedUrl, String xml);
  Future<String?> get(String feedUrl);
}

class AtomFeedLocalDataSourceImpl implements AtomFeedLocalDataSource {
  @override
  Future<void> save(String feedUrl, String xml) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(feedUrl, xml);
  }

  @override
  Future<String?> get(String feedUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString(feedUrl);
    return cache;
  }
}
