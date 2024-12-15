import 'package:dio/dio.dart';

import '../../../../core/failures/network_failure.dart';
import '../../../../core/extensions.dart';
import '../models/feed_source_model.dart';

abstract class AvailableFeedsRemoteDataSource {
  /// Fetches available feed sources.
  Future<List<FeedSourceModel>> fetch();
}

class FeedRemoteDataSourceImpl implements AvailableFeedsRemoteDataSource {
  final Dio client;

  const FeedRemoteDataSourceImpl(this.client);

  @override
  Future<List<FeedSourceModel>> fetch() async {
    final response = await client.get<Map<String, dynamic>>(
      'https://api.github.com/feeds',
    );

    final data = response.data;

    final Map<String, dynamic>? links = data?['_links'];

    if (links == null) {
      throw NetworkFailure("No '_links' field in the response");
    }

    final List<FeedSourceModel> feedSources = [];

    links.forEach((key, value) {
      if (value is Map<String, dynamic> && value['href'] is String) {
        final href = value['href'] as String;
        if (href.startsWith('https://')) {
          feedSources.add(FeedSourceModel(
            name: key.replaceAll('_', ' ').capitalizeFirst(),
            urlTemplate: href,
          ));
        }
      }
    });

    return feedSources;
  }
}
