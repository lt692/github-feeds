import 'package:github_feed/core/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CapitalizeFirstLetter extension', () {
    test('should capitalize the first letter of a lowercase word', () {
      const input = 'hello';
      final result = input.capitalizeFirst();
      expect(result, 'Hello');
    });

    test(
        'should capitalize the first letter of an uppercase word and make the rest lowercase',
        () {
      const input = 'HELLO';
      final result = input.capitalizeFirst();
      expect(result, 'Hello');
    });

    test('should capitalize a word with mixed case', () {
      const input = 'hELLo';
      final result = input.capitalizeFirst();
      expect(result, 'Hello');
    });

    test('should handle an empty string', () {
      const input = '';
      final result = input.capitalizeFirst();
      expect(result, '');
    });

    test('should handle a single lowercase character', () {
      const input = 'a';
      final result = input.capitalizeFirst();
      expect(result, 'A');
    });

    test('should handle a single uppercase character', () {
      const input = 'A';
      final result = input.capitalizeFirst();
      expect(result, 'A');
    });

    test('should handle strings with only whitespace', () {
      const input = '   ';
      final result = input.capitalizeFirst();
      expect(result, '   ');
    });

    test('should handle a string with special characters', () {
      const input = '@hello';
      final result = input.capitalizeFirst();
      expect(result, '@hello');
    });

    test('should handle a string starting with a number', () {
      const input = '1hello';
      final result = input.capitalizeFirst();
      expect(result, '1hello');
    });

    test('should not affect already correctly capitalized strings', () {
      const input = 'Hello';
      final result = input.capitalizeFirst();
      expect(result, 'Hello');
    });
  });
}
