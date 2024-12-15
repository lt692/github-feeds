import '../../domain/entities/feed_source_entity.dart';

class FeedSourceModel {
  final String name;
  final String urlTemplate;

  FeedSourceModel({
    required this.name,
    required this.urlTemplate,
  });

  factory FeedSourceModel.fromJson(Map<String, dynamic> json) {
    return FeedSourceModel(
      name: json['name'] as String,
      urlTemplate: json['urlTemplate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'urlTemplate': urlTemplate,
    };
  }

  FeedSourceEntity toEntity() {
    return FeedSourceEntity(
      name: name,
      urlTemplate: urlTemplate,
      requiredParams: _extractRequiredParams(urlTemplate),
    );
  }

  // Utility method to extract required parameters (this should be a simple helper method)
  List<String> _extractRequiredParams(String urlTemplate) {
    final paramRegex = RegExp(r'{([^}]+)}');
    final matches = paramRegex.allMatches(urlTemplate);
    return matches.map((match) => match.group(1)!).toList();
  }
}
