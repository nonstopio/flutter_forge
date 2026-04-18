import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/src.dart';

class _Dest extends StatelessWidget {
  const _Dest(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Scaffold(body: Text(label));
}

Future<GlobalKey<NavigatorState>> _buildApp(WidgetTester tester) async {
  final navKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navKey,
      home: const Scaffold(body: SizedBox()),
    ),
  );
  await tester.pump();
  return navKey;
}

BuildContext _navCtx(GlobalKey<NavigatorState> navKey) =>
    navKey.currentContext!;

void main() {
  testWidgets('ContextExtensions exposes mediaquery helpers', (tester) async {
    BuildContext? ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(builder: (c) {
            ctx = c;
            return const SizedBox();
          }),
        ),
      ),
    );
    expect(ctx!.mq, isA<MediaQueryData>());
    expect(ctx!.sizeX, isA<Size>());
    expect(ctx!.width, greaterThan(0));
    expect(ctx!.height, greaterThan(0));
    expect(ctx!.isLandscape, isA<bool>());
  });

  testWidgets('setFocus requests focus without throwing', (tester) async {
    BuildContext? ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(builder: (c) {
            ctx = c;
            return const SizedBox();
          }),
        ),
      ),
    );
    final node = FocusNode();
    ctx!.setFocus(focusNode: node);
    await tester.pump();
    node.dispose();
  });

  testWidgets('push supports material', (tester) async {
    final key = await _buildApp(tester);
    unawaited(_navCtx(key).push(const _Dest('m')));
    await tester.pumpAndSettle();
    expect(find.text('m'), findsOneWidget);
  });

  testWidgets('push supports cupertino', (tester) async {
    final key = await _buildApp(tester);
    unawaited(_navCtx(key).push(const _Dest('c'), isCupertino: true));
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);
  });

  testWidgets('push supports transparent', (tester) async {
    final key = await _buildApp(tester);
    unawaited(_navCtx(key).push(const _Dest('t'), transparent: true));
    await tester.pumpAndSettle();
    expect(find.text('t'), findsOneWidget);
  });

  testWidgets('replace supports material', (tester) async {
    final key = await _buildApp(tester);
    unawaited(_navCtx(key).replace(const _Dest('m2')));
    await tester.pumpAndSettle();
    expect(find.text('m2'), findsOneWidget);
  });

  testWidgets('replace supports cupertino', (tester) async {
    final key = await _buildApp(tester);
    unawaited(_navCtx(key).replace(const _Dest('c2'), isCupertino: true));
    await tester.pumpAndSettle();
    expect(find.text('c2'), findsOneWidget);
  });

  testWidgets('replace supports transparent', (tester) async {
    final key = await _buildApp(tester);
    unawaited(_navCtx(key).replace(const _Dest('t2'), transparent: true));
    await tester.pumpAndSettle();
    expect(find.text('t2'), findsOneWidget);
  });

  testWidgets('makeFirst and pushAfterFirst', (tester) async {
    final key = await _buildApp(tester);
    unawaited(_navCtx(key).push(const _Dest('first')));
    await tester.pumpAndSettle();
    _navCtx(key).makeFirst(const _Dest('mf'));
    await tester.pumpAndSettle();

    unawaited(_navCtx(key).push(const _Dest('second')));
    await tester.pumpAndSettle();
    _navCtx(key).pushAfterFirst(const _Dest('paf'));
    await tester.pumpAndSettle();
  });

  testWidgets('pop is safe on an empty stack', (tester) async {
    final key = await _buildApp(tester);
    _navCtx(key).pop();
    await tester.pump();
  });

  testWidgets('pop catches when no Navigator is in scope', (tester) async {
    BuildContext? ctx;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        }),
      ),
    );
    ctx!.pop();
    await tester.pump();
  });

  testWidgets('maybePop from a deeper route', (tester) async {
    final key = await _buildApp(tester);
    unawaited(_navCtx(key).push(const _Dest('deep')));
    await tester.pumpAndSettle();
    _navCtx(key).maybePop();
    await tester.pumpAndSettle();
  });
}

void unawaited(Future<void>? _) {}
