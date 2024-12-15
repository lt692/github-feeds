import 'package:dio/dio.dart';
import 'package:github_feed/core/failures/network_failure.dart';

import '../../../../core/failures/feed_failure.dart';

abstract class AtomFeedRemoteDataSource {
  Future<String?> fetch(String feedUrl);
}

class AtomFeedRemoteDataSourceImpl implements AtomFeedRemoteDataSource {
  final Dio client;

  const AtomFeedRemoteDataSourceImpl(this.client);

  @override
  Future<String?> fetch(String feedUrl) async {
    try {
      final response = await client.get<String>(
        feedUrl,
        options: Options(responseType: ResponseType.plain),
      );

      return response.data;
    } on DioException catch (dioError) {
      final statusCode = dioError.response?.statusCode;
      switch (statusCode) {
        case 404:
          throw FeedFailure('User is private');
        default:
          throw NetworkFailure('Check internet connection');
      }
    } catch (e) {
      throw NetworkFailure('Unexpected error: $e');
    }
  }
}
