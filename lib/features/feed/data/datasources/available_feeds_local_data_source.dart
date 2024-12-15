import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/feed_source_model.dart';

abstract class AvailableFeedsLocalDataSource {
  Future<List<FeedSourceModel>> get();
  Future<void> save(List<FeedSourceModel> feeds);
  Future<void> clear();
}

class FeedLocalDataSourceImpl implements AvailableFeedsLocalDataSource {
  static const String _cachedFeedsKey = 'cachedFeeds';

  @override
  Future<List<FeedSourceModel>> get() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedFeedsJson = prefs.getString(_cachedFeedsKey);
    if (cachedFeedsJson == null) return [];
    final List<dynamic> cachedList = jsonDecode(cachedFeedsJson);
    return cachedList
        .map((item) => FeedSourceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(List<FeedSourceModel> feeds) async {
    final prefs = await SharedPreferences.getInstance();
    final feedsJson = jsonEncode(feeds.map((feed) => feed.toJson()).toList());
    await prefs.setString(_cachedFeedsKey, feedsJson);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedFeedsKey);
  }
}
