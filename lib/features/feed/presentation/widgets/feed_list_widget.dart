import 'package:flutter/material.dart';
import 'package:github_feed/features/feed/presentation/pages/feed_page.dart';
import '../../domain/entities/feed_source_entity.dart';
import 'parameter_dialog.dart';

class FeedListWidget extends StatefulWidget {
  final List<FeedSourceEntity> feeds;

  const FeedListWidget({super.key, required this.feeds});

  @override
  State<FeedListWidget> createState() => _FeedListWidgetState();
}

class _FeedListWidgetState extends State<FeedListWidget> {
  Future<void> _onTap(FeedSourceEntity feed) async {
    final missingParams = feed.requiredParams;

    if (missingParams.isEmpty) {
      if (feed.urlTemplate.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No URL available for this feed')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeedPage(
            url: feed.urlTemplate,
            title: feed.name,
          ),
        ),
      );
      return;
    }

    final parameters = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return ParameterDialog(missingParams: missingParams);
      },
    );

    if (parameters == null || !feed.hasRequirements(parameters)) {
      return;
    }

    final finalUrl = feed.generateUrl(parameters);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedPage(
          url: finalUrl,
          title: parameters.entries.first.value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.feeds.length,
      itemBuilder: (context, index) {
        final feed = widget.feeds[index];
        return ListTile(
          title: Text(feed.name),
          subtitle: Text(feed.urlTemplate),
          onTap: () => _onTap(feed),
        );
      },
    );
  }
}
