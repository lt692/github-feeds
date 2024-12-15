part of 'feed_bloc.dart';

@freezed
class FeedEvent with _$FeedEvent {
  const factory FeedEvent.started() = _Started;
  const factory FeedEvent.startedAtom(String url) = _StartedAtom;
}
