import '../../domain/entities/feed_entity.dart';

class FeedModel {
  final String title;
  final String link;
  final String updated;

  FeedModel({
    required this.title,
    required this.link,
    required this.updated,
  });

  FeedEntity toEntity() {
    return FeedEntity(
      title: title,
      link: link,
      updated: updated,
    );
  }

  factory FeedModel.fromXml(dynamic xmlElement) {
    return FeedModel(
      title: xmlElement.findElements('title').single.text,
      link: xmlElement.findElements('link').single.text,
      updated: xmlElement.findElements('updated').single.text,
    );
  }
}
