class TitleFormatter {
  static String format(String? url) {
    if (url == null || url.isEmpty) {
      return 'GitHub available Feeds';
    }

    final uri = Uri.parse(url.replaceAll(".atom", ""));
    final segments = uri.pathSegments;
    if (segments.isEmpty) {
      return 'Unknown feed';
    }

    return segments.join(' - ');
  }
}
