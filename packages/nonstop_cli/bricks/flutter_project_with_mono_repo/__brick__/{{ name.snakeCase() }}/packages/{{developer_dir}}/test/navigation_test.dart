import 'package:core/core.dart' as core;
import 'package:developer/developer.dart';
import 'package:di/di.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _PlainLogger implements core.Logger {
  @override
  Object get logger => this;
  @override
  void d(String message) {}
  @override
  void i(String message) {}
  @override
  void w(String message) {}
  @override
  void e(String message, [Object? error, StackTrace? stackTrace]) {}
}

class _Flags implements FeatureFlagProvider {
  bool enabled = true;
  @override
  Future<void> init() async {}
  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async =>
      enabled;
  @override
  void dispose() {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(core.init);
  tearDown(di.reset);

  testWidgets('a custom logger does not need to expose Talker', (tester) async {
    await di.reset();
    di.register<core.Logger>(_PlainLogger());
    await tester.pumpWidget(const MaterialApp(home: DeveloperScreen()));
    expect(find.text('This logger has no interactive viewer.'), findsOneWidget);
  });

  testWidgets('disabled developer gesture remains inert', (tester) async {
    final provider = _Flags()..enabled = false;
    final service = FeatureFlag(
      provider: provider,
      logger: di.get<core.Logger>(),
    );
    await service.init();
    di.register<FeatureFlag>(service, dispose: (service) => service.dispose());
    await tester.pumpWidget(
      const MaterialApp(home: OpenDevToolsWrapper(child: Text('Demo'))),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demo'));
    await tester.pumpAndSettle();
    expect(find.text('Demo'), findsOneWidget);
    expect(find.byType(TalkerScreen), findsNothing);
  });

  testWidgets(
    'direct navigation is denied before feature flags are configured',
    (tester) async {
      final router = GoRouter(
        initialLocation: DeveloperRoutes.developer,
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('Home')),
          ...DeveloperRouter().routes,
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(TalkerScreen), findsNothing);
    },
  );

  for (final visual in [false, true]) {
    testWidgets('enabled gesture respects its tap window (visual=$visual)', (
      tester,
    ) async {
      final provider = _Flags();
      final flags = FeatureFlag(
        provider: provider,
        logger: di.get<core.Logger>(),
      );
      await flags.init();
      di.register<FeatureFlag>(flags);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: Center(
                child: OpenDevToolsWrapper(
                  tapCount: 3,
                  enableVisualFeedback: visual,
                  child: const Text('Open tools'),
                ),
              ),
            ),
          ),
          ...DeveloperRouter().routes,
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open tools'));
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.text('Open tools'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(TalkerScreen), findsNothing);
      await tester.tap(find.text('Open tools'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Open tools'));
      await tester.pumpAndSettle();
      expect(find.byType(TalkerScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
