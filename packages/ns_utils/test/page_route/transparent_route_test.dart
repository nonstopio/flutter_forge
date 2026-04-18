import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/page_route/tansparent_route.dart';

void main() {
  testWidgets('TransparentRoute pushes a non-opaque route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  TransparentRoute<void>(
                    builder: (_) => const Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Center(child: Text('transparent')),
                    ),
                    settings: const RouteSettings(name: 'transparent'),
                  ),
                );
              },
              child: const Text('go'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('transparent'), findsOneWidget);
  });
}
