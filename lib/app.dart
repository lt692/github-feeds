import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_feed/features/feed/data/datasources/atom_feed_local_data_source.dart';
import 'package:github_feed/features/feed/data/datasources/atom_feed_remote_data_source.dart';

import 'features/feed/data/datasources/available_feeds_local_data_source.dart';
import 'features/feed/data/datasources/available_feeds_remote_data_source.dart';
import 'features/feed/data/repositories/feed_repository_impl.dart';
import 'features/feed/domain/repositories/feed_repository.dart';
import 'features/feed/domain/usecases/get_available_feeds_use_case.dart';
import 'features/feed/domain/usecases/get_atom_feed_use_case.dart';
import 'features/feed/presentation/bloc/feed_bloc.dart';
import 'features/feed/presentation/pages/feed_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Dio>(
          create: (_) => Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          ),
        ),
        RepositoryProvider<AvailableFeedsRemoteDataSource>(
          create: (context) => FeedRemoteDataSourceImpl(context.read<Dio>()),
        ),
        RepositoryProvider<AvailableFeedsLocalDataSource>(
          create: (context) => FeedLocalDataSourceImpl(),
        ),
        RepositoryProvider<AtomFeedRemoteDataSource>(
          create: (context) =>
              AtomFeedRemoteDataSourceImpl(context.read<Dio>()),
        ),
        RepositoryProvider<AtomFeedLocalDataSource>(
          create: (context) => AtomFeedLocalDataSourceImpl(),
        ),
        RepositoryProvider<FeedRepository>(
          create: (context) => FeedRepositoryImpl(
            availableFeedsLocalDataSource:
                context.read<AvailableFeedsLocalDataSource>(),
            availableFeedsRemoteDataSource:
                context.read<AvailableFeedsRemoteDataSource>(),
            atomFeedLocalDataSource: context.read<AtomFeedLocalDataSource>(),
            atomFeedRemoteDataSource: context.read<AtomFeedRemoteDataSource>(),
          ),
        ),
        RepositoryProvider<GetAtomFeedUseCase>(
          create: (context) => GetAtomFeedUseCase(
            context.read<FeedRepository>(),
          ),
        ),
        RepositoryProvider<GetAvailableFeedsUseCase>(
          create: (context) => GetAvailableFeedsUseCase(
            context.read<FeedRepository>(),
          ),
        ),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
          home: FeedPage(
            feedBloc: FeedBloc(
              getAvailableFeedsUseCase:
                  context.read<GetAvailableFeedsUseCase>(),
              getAtomFeedUseCase: context.read<GetAtomFeedUseCase>(),
            ),
          ),
        );
      }),
    );
  }
}
