import 'package:flutter_test/flutter_test.dart';
import 'package:github_feed/core/utils/title_formatter.dart';

void main() {
  test(
      'format should return "GitHub available Feeds" when url is null or empty',
      () {
    expect(TitleFormatter.format(null), 'GitHub available Feeds');
    expect(TitleFormatter.format(''), 'GitHub available Feeds');
  });

  test('format should return "Unknown feed" when url has no path segments', () {
    expect(TitleFormatter.format('https://example.com'), 'Unknown feed');
  });

  test('format should return formatted path when url has path segments', () {
    expect(TitleFormatter.format('https://example.com/feed/abc.atom'),
        'feed - abc');
  });

  test('format should handle url with ".atom" suffix correctly', () {
    expect(TitleFormatter.format('https://example.com/feed/abc.atom'),
        'feed - abc');
  });
}
