import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_feed/core/extensions.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webfeed_revised/webfeed_revised.dart';

import '../../domain/usecases/get_atom_feed_use_case.dart';
import '../../domain/usecases/get_available_feeds_use_case.dart';
import '../bloc/feed_bloc.dart';
import '../pages/feed_page.dart';

class FeedAtomListWidget extends StatelessWidget {
  final AtomFeed feed;

  const FeedAtomListWidget({super.key, required this.feed});

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      log("Could not launch URL: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: feed.items?.length ?? 0,
      itemBuilder: (context, index) {
        final item = feed.items![index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? "-",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8.0),
                if (item.updated != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 16.0),
                      FeedItemDate(updated: item.updated),
                    ],
                  ),
                if (item.summary?.isNotEmpty ?? false)
                  Text(
                    item.summary!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 4),
                if (item.authors?.isNotEmpty ?? false)
                  FeedAuthorsWidget(authors: item.authors!),
                if (item.links?.isNotEmpty ?? false)
                  FeedLinksWidget(
                    links: item.links!,
                    onLinkPressed: _launchURL,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FeedItemDate extends StatelessWidget {
  final DateTime? updated;

  const FeedItemDate({super.key, required this.updated});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        updated != null ? DateFormat('yyyy-MM-dd HH:mm').format(updated!) : "-";

    return Text(
      formattedDate,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class IconTextRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final List<Widget> children;

  const IconTextRow({
    super.key,
    required this.icon,
    this.iconColor = Colors.black54,
    this.iconSize = 18.0,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        const SizedBox(width: 6.0),
        Expanded(
          child: Wrap(
            spacing: 2.0,
            runSpacing: 2.0,
            children: children,
          ),
        ),
      ],
    );
  }
}

class FeedAuthorsWidget extends StatelessWidget {
  final List<AtomPerson> authors;

  const FeedAuthorsWidget({super.key, required this.authors});

  @override
  Widget build(BuildContext context) {
    return IconTextRow(
      icon: Icons.person,
      iconColor: Colors.blueGrey,
      children: authors.map((author) {
        return TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.all(8.0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            String? url = author.getAtomUrl();
            if (url == null) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedPage(
                  url: url,
                  feedBloc: FeedBloc(
                    getAvailableFeedsUseCase:
                        context.read<GetAvailableFeedsUseCase>(),
                    getAtomFeedUseCase: context.read<GetAtomFeedUseCase>(),
                  ),
                ),
              ),
            );
          },
          child: Text(
            author.name ?? "-",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}

class FeedLinksWidget extends StatelessWidget {
  final List<AtomLink> links;
  final void Function(String url) onLinkPressed;

  const FeedLinksWidget({
    super.key,
    required this.links,
    required this.onLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    final validLinks = links.where((link) => link.href != null).toList();

    if (validLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: validLinks
          .map(
            (link) => IconTextRow(
              icon: Icons.link,
              iconColor: Colors.blueGrey,
              iconSize: 16.0,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.all(8.0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => onLinkPressed(link.href!),
                  child: Text(
                    link.href!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
