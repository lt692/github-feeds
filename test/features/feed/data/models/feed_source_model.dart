import 'package:flutter_test/flutter_test.dart';
import 'package:github_feed/features/feed/data/models/feed_source_model.dart';
import 'package:github_feed/features/feed/domain/entities/feed_source_entity.dart';

void main() {
  group('FeedSourceModel Tests', () {
    late FeedSourceModel feedSourceModel;

    setUp(() {
      feedSourceModel = FeedSourceModel(
        name: 'Test Feed',
        urlTemplate: 'https://example.com/{param1}/{param2}',
      );
    });

    test(
        'toEntity should correctly convert FeedSourceModel to FeedSourceEntity',
        () {
      final feedSourceEntity = feedSourceModel.toEntity();

      expect(feedSourceEntity, isA<FeedSourceEntity>());
      expect(feedSourceEntity.name, feedSourceModel.name);
      expect(feedSourceEntity.urlTemplate, feedSourceModel.urlTemplate);
      expect(feedSourceEntity.requiredParams, isNotEmpty);
      expect(feedSourceEntity.requiredParams.length, 2);
      expect(feedSourceEntity.requiredParams, contains('param1'));
      expect(feedSourceEntity.requiredParams, contains('param2'));
    });

    test('toJson should correctly convert FeedSourceModel to JSON map', () {
      final jsonMap = feedSourceModel.toJson();

      expect(jsonMap, isA<Map<String, dynamic>>());
      expect(jsonMap['name'], feedSourceModel.name);
      expect(jsonMap['urlTemplate'], feedSourceModel.urlTemplate);
    });

    test('fromJson should correctly convert JSON map to FeedSourceModel', () {
      final jsonMap = {
        'name': 'Test Feed',
        'urlTemplate': 'https://example.com/{param1}/{param2}',
      };

      final model = FeedSourceModel.fromJson(jsonMap);

      expect(model, isA<FeedSourceModel>());
      expect(model.name, jsonMap['name']);
      expect(model.urlTemplate, jsonMap['urlTemplate']);
    });
  });
}
