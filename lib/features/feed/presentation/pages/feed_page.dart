import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/title_formatter.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/feed_atom_list_widget.dart';
import '../widgets/feed_error_widget.dart';
import '../widgets/feed_initial_widget.dart';
import '../widgets/feed_list_widget.dart';
import '../widgets/feed_loading_widget.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({
    super.key,
    this.url,
    required this.feedBloc,
  });

  final String? url;

  final FeedBloc feedBloc;

  @override
  Widget build(BuildContext context) {
    final feedEvent =
        url != null ? FeedEvent.startedAtom(url!) : const FeedEvent.started();

    String title = TitleFormatter.format(url);

    return BlocProvider<FeedBloc>(
      create: (context) => feedBloc..add(feedEvent),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    context.read<FeedBloc>().add(feedEvent);
                  },
                  icon: const Icon(Icons.refresh),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {
            return state.map(
              initial: (_) => const FeedInitialWidget(),
              loading: (_) => const FeedLoadingWidget(),
              loaded: (s) => FeedListWidget(
                feeds: s.feeds,
              ),
              loadedAtom: (s) => FeedAtomListWidget(
                feed: s.feed,
              ),
              error: (s) => FeedErrorWidget(
                message: s.message,
              ),
            );
          },
        ),
      ),
    );
  }
}
