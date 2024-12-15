part of 'feed_bloc.dart';

@freezed
class FeedState with _$FeedState {
  const factory FeedState.initial() = _Initial;
  const factory FeedState.loading() = _Loading;
  const factory FeedState.loaded(List<FeedSourceEntity> feeds) = _Loaded;
  const factory FeedState.loadedAtom(AtomFeed feed) = _LoadedAtom;
  const factory FeedState.error(String message) = _Error;
}
