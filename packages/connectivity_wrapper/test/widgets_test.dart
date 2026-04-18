import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:connectivity_wrapper/src/widgets/empty_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _withStatus(ConnectivityStatus status, Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Provider<ConnectivityStatus>.value(
        value: status,
        child: child,
      ),
    ),
  );
}

void main() {
  group('EmptyContainer', () {
    testWidgets('renders a SizedBox.shrink', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: EmptyContainer()),
      ));
      expect(find.byType(EmptyContainer), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('ConnectivityWidgetWrapper asserts', () {
    testWidgets('asserts when decoration + offlineWidget are both set',
        (tester) async {
      expect(
        () => ConnectivityWidgetWrapper(
          decoration: const BoxDecoration(color: Colors.red),
          offlineWidget: const SizedBox(),
          child: const SizedBox(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('asserts when height + offlineWidget are both set',
        (tester) async {
      expect(
        () => ConnectivityWidgetWrapper(
          height: 40,
          offlineWidget: const SizedBox(),
          child: const SizedBox(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('asserts when messageStyle + offlineWidget are both set',
        (tester) async {
      expect(
        () => ConnectivityWidgetWrapper(
          messageStyle: const TextStyle(fontSize: 12),
          offlineWidget: const SizedBox(),
          child: const SizedBox(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('asserts when message + offlineWidget are both set',
        (tester) async {
      expect(
        () => ConnectivityWidgetWrapper(
          message: 'hi',
          offlineWidget: const SizedBox(),
          child: const SizedBox(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('asserts when color + decoration are both set',
        (tester) async {
      expect(
        () => ConnectivityWidgetWrapper(
          color: Colors.red,
          decoration: const BoxDecoration(color: Colors.red),
          child: const SizedBox(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('ConnectivityWidgetWrapper online behavior', () {
    testWidgets('stacked layout shows child + empty offline slot when online',
        (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.CONNECTED,
          const ConnectivityWidgetWrapper(child: Text('child')),
        ),
      );
      expect(find.text('child'), findsOneWidget);
      // Default offline message should not appear
      expect(find.textContaining('Please connect'), findsNothing);
    });

    testWidgets('non-stacked layout returns the child unchanged when online',
        (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.CONNECTED,
          const ConnectivityWidgetWrapper(
            stacked: false,
            child: Text('kid'),
          ),
        ),
      );
      expect(find.text('kid'), findsOneWidget);
      expect(find.textContaining('Please connect'), findsNothing);
    });
  });

  group('ConnectivityWidgetWrapper offline behavior', () {
    testWidgets('shows default offline widget with message when disconnected',
        (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.DISCONNECTED,
          const ConnectivityWidgetWrapper(child: Text('child')),
        ),
      );
      expect(find.textContaining('Please connect'), findsOneWidget);
    });

    testWidgets('shows custom message/style/height/color/alignment offline',
        (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.DISCONNECTED,
          const ConnectivityWidgetWrapper(
            message: 'No net',
            messageStyle: TextStyle(fontSize: 20),
            height: 60,
            color: Colors.green,
            alignment: Alignment.topCenter,
            child: SizedBox(),
          ),
        ),
      );
      expect(find.text('No net'), findsOneWidget);
    });

    testWidgets('shows custom offline widget when provided', (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.DISCONNECTED,
          const ConnectivityWidgetWrapper(
            offlineWidget: Text('custom offline'),
            child: SizedBox(),
          ),
        ),
      );
      expect(find.text('custom offline'), findsOneWidget);
    });

    testWidgets('disableInteraction shows black38 scrim offline',
        (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.DISCONNECTED,
          const ConnectivityWidgetWrapper(
            disableInteraction: true,
            child: SizedBox(),
          ),
        ),
      );
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('disableInteraction with custom decoration',
        (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.DISCONNECTED,
          const ConnectivityWidgetWrapper(
            disableInteraction: true,
            decoration: BoxDecoration(color: Colors.black54),
            child: SizedBox(),
          ),
        ),
      );
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('non-stacked layout shows offline widget when disconnected',
        (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.DISCONNECTED,
          const ConnectivityWidgetWrapper(
            stacked: false,
            child: Text('child'),
          ),
        ),
      );
      expect(find.text('child'), findsNothing);
      expect(find.textContaining('Please connect'), findsOneWidget);
    });
  });

  group('ConnectivityScreenWrapper', () {
    testWidgets('asserts when color + decoration are both set',
        (tester) async {
      expect(
        () => ConnectivityScreenWrapper(
          color: Colors.red,
          decoration: const BoxDecoration(color: Colors.red),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('renders offline widget at bottom by default when offline',
        (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.DISCONNECTED,
          const ConnectivityScreenWrapper(child: Text('child')),
        ),
      );
      await tester.pump();
      expect(find.textContaining('Please connect'), findsOneWidget);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('renders offline widget at top when positionOnScreen is TOP',
        (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.DISCONNECTED,
          const ConnectivityScreenWrapper(
            positionOnScreen: PositionOnScreen.TOP,
            message: 'up there',
            child: Text('child'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('up there'), findsOneWidget);
    });

    testWidgets('uses custom color, duration, height, style, textAlign',
        (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.DISCONNECTED,
          const ConnectivityScreenWrapper(
            color: Colors.green,
            duration: Duration(milliseconds: 100),
            height: 80,
            messageStyle: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('Please connect'), findsOneWidget);
    });

    testWidgets(
        'shows disableWidget when disableInteraction is true and offline',
        (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.DISCONNECTED,
          const ConnectivityScreenWrapper(
            disableInteraction: true,
            disableWidget: Text('scrim'),
            child: Text('child'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('scrim'), findsOneWidget);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('renders without child when child is null', (tester) async {
      await tester.pumpWidget(
        _withStatus(
          ConnectivityStatus.CONNECTED,
          const ConnectivityScreenWrapper(),
        ),
      );
      await tester.pump();
      expect(find.byType(ConnectivityScreenWrapper), findsOneWidget);
    });
  });

  group('ConnectivityAppWrapper', () {
    testWidgets('builds and provides ConnectivityStatus to the subtree',
        (tester) async {
      await tester.pumpWidget(
        ConnectivityAppWrapper(
          app: MaterialApp(
            home: Scaffold(
              body: Builder(builder: (context) {
                final status = Provider.of<ConnectivityStatus>(context);
                return Text('status: $status');
              }),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('CONNECTED'), findsOneWidget);
    });
  });
}
