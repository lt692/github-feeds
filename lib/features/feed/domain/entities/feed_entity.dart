import 'package:equatable/equatable.dart';

class FeedEntity extends Equatable {
  final String title;
  final String link;
  final String updated;

  const FeedEntity({
    required this.title,
    required this.link,
    required this.updated,
  });

  @override
  List<Object?> get props => [title, link, updated];
}
