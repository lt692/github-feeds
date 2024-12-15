import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:github_feed/features/feed/domain/entities/feed_source_entity.dart';
import 'package:github_feed/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:github_feed/features/feed/presentation/pages/feed_page.dart';
import 'package:github_feed/features/feed/presentation/widgets/feed_error_widget.dart';
import 'package:github_feed/features/feed/presentation/widgets/feed_list_widget.dart';
import 'package:github_feed/features/feed/presentation/widgets/feed_loading_widget.dart';

class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}

void main() {
  late MockFeedBloc mockFeedBloc;

  setUp(() {
    mockFeedBloc = MockFeedBloc();
  });

  testWidgets('renders FeedLoadingWidget when state is loading',
      (tester) async {
    when(() => mockFeedBloc.state).thenReturn(const FeedState.loading());

    await tester.pumpWidget(
      MaterialApp(
        home: FeedPage(feedBloc: mockFeedBloc),
      ),
    );

    mockFeedBloc.add(const FeedEvent.started());
    await tester.pump();

    expect(find.byType(FeedLoadingWidget), findsOneWidget);
  });

  testWidgets('renders FeedErrorWidget when state is error', (tester) async {
    when(() => mockFeedBloc.state).thenReturn(
      const FeedState.error('Error occurred'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FeedPage(feedBloc: mockFeedBloc),
      ),
    );

    mockFeedBloc.add(const FeedEvent.started());
    await tester.pump();

    expect(find.byType(FeedErrorWidget), findsOneWidget);
    expect(find.text('Error occurred'), findsOneWidget);
  });

  testWidgets('renders FeedListWidget when state is loaded', (tester) async {
    const feedSource = FeedSourceEntity(
      name: 'Test Feed',
      urlTemplate: 'https://example.com/feed.atom',
      requiredParams: [],
    );
    when(() => mockFeedBloc.state).thenReturn(
      const FeedState.loaded([feedSource]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FeedPage(feedBloc: mockFeedBloc),
      ),
    );

    mockFeedBloc.add(const FeedEvent.started());
    await tester.pump();

    expect(find.byType(FeedListWidget), findsOneWidget);
    expect(find.text('Test Feed'), findsOneWidget);
  });
}
