import 'package:equatable/equatable.dart';

class FeedSourceEntity extends Equatable {
  final String name;
  final String urlTemplate;
  final List<String> requiredParams;

  const FeedSourceEntity({
    required this.name,
    required this.urlTemplate,
    required this.requiredParams,
  });

  String generateUrl(Map<String, String> userInput) {
    String finalUrl = urlTemplate;
    userInput.forEach((key, value) {
      finalUrl = finalUrl.replaceAll('{$key}', value);
    });

    if (!finalUrl.endsWith('.atom')) {
      finalUrl = '$finalUrl.atom';
    }

    return finalUrl;
  }

  bool hasRequirements(Map<String, String> parameters) {
    return requiredParams.every((param) => parameters.containsKey(param));
  }

  @override
  List<Object?> get props => [name, urlTemplate, requiredParams];
}
