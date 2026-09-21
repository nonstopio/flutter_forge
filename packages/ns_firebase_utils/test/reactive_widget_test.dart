import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_firebase_utils/reactive_widget/base_reactive_widget.dart';

void main() {
  testWidgets('reactive builder selects data, waiting and fallback states',
      (tester) async {
    for (final waiting in [const Text('waiting'), null]) {
      final builder = getReactiveBuilder<String>(
          onData: (data) => Text('data:$data'),
          onFallback: const Text('fallback'),
          onWaiting: waiting);
      for (final snapshot in [
        const AsyncSnapshot<String>.nothing(),
        const AsyncSnapshot<String>.waiting(),
        const AsyncSnapshot<String>.withData(ConnectionState.active, 'hello'),
        const AsyncSnapshot<String>.nothing().inState(ConnectionState.active),
        AsyncSnapshot<String>.withError(
            ConnectionState.done, StateError('failed'))
      ]) {
        await tester.pumpWidget(MaterialApp(
            home: Builder(builder: (context) => builder(context, snapshot))));
        final expected = snapshot.hasData
            ? 'data:hello'
            : snapshot.hasError ||
                    snapshot.connectionState == ConnectionState.active ||
                    waiting == null
                ? 'fallback'
                : 'waiting';
        expect(find.text(expected), findsOneWidget);
      }
    }
  });

  testWidgets(
      'document changes rebuild reactive widgets and missing documents use fallback',
      (tester) async {
    final ref = FakeFirebaseFirestore().doc('items/one');
    await tester.pumpWidget(MaterialApp(
        home: ReactiveWidget<Map<String, dynamic>>(
      reactiveRef: ReactiveRef(ref),
      fallbackValue: const {'name': 'fallback'},
      waitingWidget: const Text('waiting'),
      widgetBuilder: (data) => Text(data?['name'] as String? ?? 'null'),
    )));
    await tester.pumpAndSettle();
    expect(find.text('fallback'), findsOneWidget);
    await ref.set({'name': 'created'});
    await tester.pumpAndSettle();
    expect(find.text('created'), findsOneWidget);
    await ref.delete();
    await tester.pumpAndSettle();
    expect(find.text('fallback'), findsOneWidget);
  });
}
