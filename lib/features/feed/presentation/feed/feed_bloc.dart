import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github_feed/core/failures/network_failure.dart';
import 'package:github_feed/features/feed/domain/usecases/get_available_feeds_use_case.dart';
import 'package:webfeed_revised/domain/atom_feed.dart';

import '../../domain/entities/feed_source_entity.dart';
import '../../domain/usecases/get_atom_feed_use_case.dart';

part 'feed_state.dart';
part 'feed_event.dart';
part 'feed_bloc.freezed.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetAvailableFeedsUseCase getAvailableFeedsUseCase;
  final GetAtomFeedUseCase getAtomFeedUseCase;

  FeedBloc({
    required this.getAvailableFeedsUseCase,
    required this.getAtomFeedUseCase,
  }) : super(const FeedState.initial()) {
    on<_Started>((event, emit) async {
      emit(const FeedState.loading());

      final result = await getAvailableFeedsUseCase.execute();

      result.fold(
        (err) => emit(FeedState.error(err.message)),
        (feed) => emit(FeedState.loaded(feed)),
      );
    });

    on<_StartedAtom>((event, emit) async {
      try {
        emit(const FeedState.loading());

        final result = await getAtomFeedUseCase.execute(event.url);

        result.fold(
          (err) => emit(FeedState.error(err.message)),
          (feed) => emit(FeedState.loadedAtom(feed)),
        );
      } catch (e) {
        emit(FeedState.error(e.toString()));
      }
    });
  }
}
