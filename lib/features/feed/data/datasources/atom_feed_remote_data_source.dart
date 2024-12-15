import 'package:dio/dio.dart';

import '../../../../core/failures/network_failure.dart';

abstract class AtomFeedRemoteDataSource {
  Future<String> fetch(String feedUrl);
}

class AtomFeedRemoteDataSourceImpl implements AtomFeedRemoteDataSource {
  final Dio client;

  const AtomFeedRemoteDataSourceImpl(this.client);

  @override
  Future<String> fetch(String feedUrl) async {
    final response = await client.get<String>(
      feedUrl,
      options: Options(responseType: ResponseType.plain),
    );

    if (response.data == null) {
      throw NetworkFailure("Received empty response from server");
    }

    return response.data!;
  }
}
