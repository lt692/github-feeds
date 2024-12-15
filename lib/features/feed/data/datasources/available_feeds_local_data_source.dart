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
  static const String _cacheTimestampKey = 'cacheTimestamp';
  static const int _cacheExpiryDays = 7;

  @override
  Future<List<FeedSourceModel>> get() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cachedTimestamp = prefs.getString(_cacheTimestampKey);
      if (cachedTimestamp != null) {
        final cacheDate = DateTime.parse(cachedTimestamp);
        final expiryDate = cacheDate.add(
          const Duration(days: _cacheExpiryDays),
        );

        if (DateTime.now().isAfter(expiryDate)) {
          await clear();
          return [];
        }
      }

      final cachedFeedsJson = prefs.getString(_cachedFeedsKey);
      if (cachedFeedsJson == null) return [];

      final List<dynamic> cachedList = jsonDecode(cachedFeedsJson);
      return cachedList
          .map((item) => FeedSourceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> save(List<FeedSourceModel> feeds) async {
    final prefs = await SharedPreferences.getInstance();
    final feedsJson = jsonEncode(feeds.map((feed) => feed.toJson()).toList());
    await prefs.setString(_cachedFeedsKey, feedsJson);
    await prefs.setString(
      _cacheTimestampKey,
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedFeedsKey);
    await prefs.remove(_cacheTimestampKey);
  }
}
