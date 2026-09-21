// Query and snapshot interfaces are mocked only at the Firestore transport boundary.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ns_firebase_utils/ui/firestore/query_builder.dart';

typedef Json = Map<String, dynamic>;

class MockQuery extends Mock implements Query<Json> {}

class MockQuerySnapshot extends Mock implements QuerySnapshot<Json> {}

class MockDocument extends Mock implements QueryDocumentSnapshot<Json> {}

/// Controls each server subscription independently so cancellation, pagination,
/// late results, and failures can be asserted without network timing.
class QueryHarness {
  final query = MockQuery();
  final limits = <int>[];
  final streams = <StreamController<QuerySnapshot<Json>>>[];

  QueryHarness() {
    when(() => query.limit(any())).thenAnswer((invocation) {
      limits.add(invocation.positionalArguments.single as int);
      final stream = StreamController<QuerySnapshot<Json>>.broadcast();
      streams.add(stream);
      return query;
    });
    when(() => query.snapshots()).thenAnswer((_) => streams.last.stream);
    addTearDown(() async {
      for (final stream in streams) {
        await stream.close();
      }
    });
  }

  void emit(int count) {
    final docs = List.generate(count, (index) {
      final doc = MockDocument();
      when(() => doc.id).thenReturn('$index');
      when(() => doc.data()).thenReturn({'name': 'item $index'});
      return doc;
    });
    final snapshot = MockQuerySnapshot();
    when(() => snapshot.docs).thenReturn(docs);
    when(() => snapshot.size).thenReturn(count);
    streams.last.add(snapshot);
  }
}

void main() {
  testWidgets(
      'query pages preserve progress, restart on query change, and cancel subscriptions',
      (tester) async {
    final first = QueryHarness();
    final second = QueryHarness();
    late FirestoreQueryBuilderSnapshot<Json> snapshot;
    final child = Text('stable child');
    Widget build(QueryHarness harness, int pageSize) => MaterialApp(
            home: FirestoreQueryBuilder<Json>(
          query: harness.query,
          pageSize: pageSize,
          child: child,
          builder: (context, value, passedChild) {
            snapshot = value;
            expect(passedChild, same(child));
            return Text(value.docs.map((doc) => doc.id).join(','));
          },
        ));
    await tester.pumpWidget(build(first, 2));
    expect(first.limits, [3]);
    expect(snapshot.isFetching, isTrue);
    expect(snapshot.isFetchingMore, isFalse);
    expect(snapshot.hasData, isFalse);
    expect(snapshot.hasError, isFalse);
    expect(snapshot.error, isNull);
    expect(snapshot.stackTrace, isNull);
    snapshot.fetchMore();
    expect(first.limits, [3]);
    first.emit(3);
    await tester.pumpAndSettle();
    expect(snapshot.hasMore, isTrue);
    expect(snapshot.hasData, isTrue);
    expect(snapshot.isFetching, isFalse);
    expect(find.text('0,1'), findsOneWidget);
    snapshot.fetchMore();
    snapshot.fetchMore();
    await tester.pumpAndSettle();
    expect(first.limits, [3, 5]);
    expect(first.streams.first.hasListener, isFalse);
    expect(snapshot.isFetchingMore, isTrue);
    first.emit(5);
    await tester.pumpAndSettle();
    expect(snapshot.isFetchingMore, isFalse);
    expect(find.text('0,1,2,3'), findsOneWidget);
    await tester.pumpWidget(build(first, 3));
    expect(first.limits, [3, 5, 7]);
    expect(snapshot.isFetching, isTrue);
    first.emit(3);
    await tester.pumpAndSettle();
    expect(snapshot.hasMore, isFalse);
    snapshot.fetchMore();
    await tester.pumpWidget(build(first, 3));
    expect(first.limits, [3, 5, 7]);
    await tester.pumpWidget(build(second, 3));
    expect(second.limits, [4]);
    expect(first.streams.last.hasListener, isFalse);
    second.emit(1);
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(second.streams.single.hasListener, isFalse);
  });

  testWidgets(
      'query failures preserve existing data and a later success clears errors',
      (tester) async {
    final harness = QueryHarness();
    late FirestoreQueryBuilderSnapshot<Json> snapshot;
    await tester.pumpWidget(MaterialApp(
        home: FirestoreQueryBuilder<Json>(
      query: harness.query,
      pageSize: 2,
      builder: (context, value, child) {
        snapshot = value;
        return const SizedBox();
      },
    )));
    final initialError = StateError('offline');
    final trace = StackTrace.current;
    harness.streams.last.addError(initialError, trace);
    await tester.pumpAndSettle();
    expect(snapshot.isFetching, isFalse);
    expect(snapshot.hasError, isTrue);
    expect(snapshot.error, same(initialError));
    expect(snapshot.stackTrace, same(trace));
    expect(snapshot.hasData, isFalse);
    expect(snapshot.hasMore, isFalse);
    harness.emit(3);
    await tester.pumpAndSettle();
    expect(snapshot.hasError, isFalse);
    expect(snapshot.error, isNull);
    expect(snapshot.stackTrace, isNull);
    expect(snapshot.docs, hasLength(2));
    snapshot.fetchMore();
    final nextError = StateError('next page failed');
    harness.streams.last.addError(nextError, trace);
    await tester.pumpAndSettle();
    expect(snapshot.isFetchingMore, isFalse);
    expect(snapshot.hasError, isTrue);
    expect(snapshot.error, same(nextError));
    expect(snapshot.hasData, isTrue);
    expect(snapshot.docs, hasLength(2));
    expect(snapshot.hasMore, isFalse);
  });

  for (final usePageView in [false, true]) {
    for (final customBuilders in [false, true]) {
      testWidgets(
          '${usePageView ? 'page' : 'list'} view renders ${customBuilders ? 'custom' : 'default'} loading and empty states',
          (tester) async {
        final harness = QueryHarness();
        final loading =
            customBuilders ? (BuildContext _) => const Text('loading') : null;
        final empty = customBuilders ? const Text('empty') : null;
        final widget = usePageView
            ? FirestorePageView<Json>(
                query: harness.query,
                loadingBuilder: loading,
                emptyBuilder: empty,
                itemBuilder: (_, doc, index) => Text(doc.id))
            : FirestoreListView<Json>(
                query: harness.query,
                loadingBuilder: loading,
                emptyBuilder: empty,
                itemBuilder: (_, doc) => Text(doc.id));
        await tester.pumpWidget(MaterialApp(home: widget));
        expect(
            customBuilders
                ? find.text('loading')
                : find.byType(CircularProgressIndicator),
            findsOneWidget);
        harness.emit(0);
        await tester.pumpAndSettle();
        expect(find.text(customBuilders ? 'empty' : 'No Data'), findsOneWidget);
      });
    }
  }

  testWidgets(
      'list view paginates from its last visible item and forwards scrolling options',
      (tester) async {
    final harness = QueryHarness();
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
        home: FirestoreListView<Json>(
      query: harness.query,
      pageSize: 2,
      itemBuilder: (_, doc) => Text(doc.data()['name'] as String),
      controller: controller,
      primary: false,
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemExtent: 40,
      reverse: true,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      addSemanticIndexes: false,
      cacheExtent: 100,
      semanticChildCount: 2,
      dragStartBehavior: DragStartBehavior.down,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      restorationId: 'items',
      clipBehavior: Clip.none,
    )));
    harness.emit(3);
    await tester.pumpAndSettle();
    expect(harness.limits, [3, 5]);
    harness.emit(4);
    await tester.pumpAndSettle();
    expect(find.text('item 3'), findsOneWidget);
    final view = tester.widget<ListView>(find.byType(ListView));
    expect(view.controller, same(controller));
    expect(view.reverse, isTrue);
    expect(view.primary, isFalse);
    expect(view.physics, isA<ClampingScrollPhysics>());
    expect(view.shrinkWrap, isTrue);
    expect(view.padding, const EdgeInsets.all(8));
    expect(view.itemExtent, 40);
    // Verify the compatibility parameter exposed by FirestoreListView.
    // ignore: deprecated_member_use
    expect(view.cacheExtent, 100);
    expect(view.semanticChildCount, 2);
    expect(view.dragStartBehavior, DragStartBehavior.down);
    expect(
        view.keyboardDismissBehavior, ScrollViewKeyboardDismissBehavior.onDrag);
    expect(view.restorationId, 'items');
    expect(view.clipBehavior, Clip.none);
    final delegate = view.childrenDelegate as SliverChildBuilderDelegate;
    expect(delegate.addAutomaticKeepAlives, isFalse);
    expect(delegate.addRepaintBoundaries, isFalse);
    expect(delegate.addSemanticIndexes, isFalse);
  });

  testWidgets('page view paginates while swiping and reports item indexes',
      (tester) async {
    final harness = QueryHarness();
    final controller = PageController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
        home: FirestorePageView<Json>(
      query: harness.query,
      pageSize: 2,
      itemBuilder: (_, doc, index) => Text('${doc.data()['name']}:$index'),
      controller: controller,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      dragStartBehavior: DragStartBehavior.down,
      restorationId: 'pages',
      clipBehavior: Clip.none,
    )));
    harness.emit(3);
    await tester.pumpAndSettle();
    expect(find.text('item 0:0'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-800, 0));
    await tester.pumpAndSettle();
    expect(harness.limits, [3, 5]);
    harness.emit(3);
    await tester.pumpAndSettle();
    controller.jumpToPage(2);
    await tester.pumpAndSettle();
    expect(find.text('item 2:2'), findsOneWidget);
    final view = tester.widget<PageView>(find.byType(PageView));
    expect(view.controller, same(controller));
    expect(view.scrollDirection, Axis.horizontal);
    expect(view.physics, isA<ClampingScrollPhysics>());
    expect(view.dragStartBehavior, DragStartBehavior.down);
    expect(view.restorationId, 'pages');
    expect(view.clipBehavior, Clip.none);
  });

  for (final usePageView in [false, true]) {
    testWidgets(
        '${usePageView ? 'page' : 'list'} view passes failures to the error builder',
        (tester) async {
      final harness = QueryHarness();
      final error = StateError('offline');
      final trace = StackTrace.current;
      Widget onError(
          BuildContext context, Object received, StackTrace receivedTrace) {
        expect(received, same(error));
        expect(receivedTrace, same(trace));
        return const Text('failed');
      }

      final widget = usePageView
          ? FirestorePageView<Json>(
              query: harness.query,
              errorBuilder: onError,
              itemBuilder: (context, doc, index) => Text(doc.id))
          : FirestoreListView<Json>(
              query: harness.query,
              errorBuilder: onError,
              itemBuilder: (_, doc) => Text(doc.id));
      await tester.pumpWidget(MaterialApp(home: widget));
      harness.emit(1);
      await tester.pumpAndSettle();
      harness.streams.last.addError(error, trace);
      await tester.pumpAndSettle();
      expect(find.text('failed'), findsOneWidget);
    });
  }
}
