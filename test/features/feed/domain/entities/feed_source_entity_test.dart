import 'package:flutter_test/flutter_test.dart';
import 'package:github_feed/features/feed/domain/entities/feed_source_entity.dart';

void main() {
  group('FeedSourceEntity', () {
    const name = 'GitHub Feed';
    const urlTemplate = 'https://example.com/{user}/{repo}';
    const requiredParams = ['user', 'repo'];

    const entity = FeedSourceEntity(
      name: name,
      urlTemplate: urlTemplate,
      requiredParams: requiredParams,
    );

    test('generateUrl should replace placeholders with user input', () {
      const userInput = {'user': 'octocat', 'repo': 'hello-world'};
      final generatedUrl = entity.generateUrl(userInput);

      expect(generatedUrl, 'https://example.com/octocat/hello-world.atom');
    });

    test('generateUrl should append .atom if missing', () {
      const userInput = {'user': 'octocat', 'repo': 'hello-world'};
      const noAtomTemplate = 'https://example.com/{user}/{repo}';
      const entityWithoutAtom = FeedSourceEntity(
        name: name,
        urlTemplate: noAtomTemplate,
        requiredParams: requiredParams,
      );

      final generatedUrl = entityWithoutAtom.generateUrl(userInput);

      expect(generatedUrl, 'https://example.com/octocat/hello-world.atom');
    });

    test('generateUrl should leave .atom intact if already present', () {
      const userInput = {'user': 'octocat', 'repo': 'hello-world'};
      const atomTemplate = 'https://example.com/{user}/{repo}.atom';
      const entityWithAtom = FeedSourceEntity(
        name: name,
        urlTemplate: atomTemplate,
        requiredParams: requiredParams,
      );

      final generatedUrl = entityWithAtom.generateUrl(userInput);

      expect(generatedUrl, 'https://example.com/octocat/hello-world.atom');
    });

    test(
        'hasRequirements should return true if all required params are present',
        () {
      const userInput = {'user': 'octocat', 'repo': 'hello-world'};
      final result = entity.hasRequirements(userInput);

      expect(result, isTrue);
    });

    test('hasRequirements should return false if any required param is missing',
        () {
      const userInput = {'user': 'octocat'}; // Missing 'repo'
      final result = entity.hasRequirements(userInput);

      expect(result, isFalse);
    });

    test('props should include name, urlTemplate, and requiredParams', () {
      expect(entity.props, [name, urlTemplate, requiredParams]);
    });

    test('entities with the same properties should be equal', () {
      const anotherEntity = FeedSourceEntity(
        name: name,
        urlTemplate: urlTemplate,
        requiredParams: requiredParams,
      );

      expect(entity, equals(anotherEntity));
    });

    test('entities with different properties should not be equal', () {
      const differentEntity = FeedSourceEntity(
        name: 'Different Feed',
        urlTemplate: 'https://example.com/other/{user}/{repo}',
        requiredParams: ['user', 'repo'],
      );

      expect(entity, isNot(equals(differentEntity)));
    });
  });
}
