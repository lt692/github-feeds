import 'package:flutter_test/flutter_test.dart';
import 'package:github_feed/core/extensions.dart';
import 'package:webfeed_revised/domain/atom_person.dart';

void main() {
  group('UrlToAtom', () {
    test('should add .atom to the URL if it does not already end with .atom',
        () {
      var person = AtomPerson(uri: 'https://example.com/feed');
      expect(person.getAtomUrl(), equals('https://example.com/feed.atom'));
    });

    test('should return the same URL if it already ends with .atom', () {
      var person = AtomPerson(uri: 'https://example.com/feed.atom');
      expect(person.getAtomUrl(), equals('https://example.com/feed.atom'));
    });

    test('should return null if the URI is null', () {
      var person = AtomPerson(uri: null);
      expect(person.getAtomUrl(), isNull);
    });
  });
}
