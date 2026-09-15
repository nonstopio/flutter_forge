import 'package:design_system/design_system.dart' as ds;
import 'package:design_system/utils/extensions/string.dart';
import 'package:design_system/generated/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

void main() {
  test(
    'extended palettes retain custom color families for each contrast mode',
    () {
      final family = ColorFamily(
        color: Colors.red,
        onColor: Colors.white,
        colorContainer: Colors.pink,
        onColorContainer: Colors.black,
      );
      final extended = ExtendedColor(
        seed: Colors.red,
        value: Colors.pink,
        light: family,
        lightHighContrast: family,
        lightMediumContrast: family,
        dark: family,
        darkHighContrast: family,
        darkMediumContrast: family,
      );
      expect(extended.seed, Colors.red);
      expect(extended.light.color, Colors.red);
      expect(extended.dark.onColorContainer, Colors.black);
    },
  );
  testWidgets(
    'date filters select another period without deselecting the current one',
    (tester) async {
      final changes = <ds.DateFilterType>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ds.DateFilterChips(
              selectedFilter: ds.DateFilterType.week,
              onFilterChanged: changes.add,
            ),
          ),
        ),
      );
      await tester.tap(find.text(strings.common.week));
      expect(changes, isEmpty);
      await tester.tap(find.text(strings.common.month));
      expect(changes, [ds.DateFilterType.month]);
    },
  );

  testWidgets('error view explains failures and exposes retry', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ds.DefaultErrorView(
            error: StateError('failure'),
            stackTrace: StackTrace.current,
            descriptionBuilder: (_) => 'Try another connection',
            onRetry: () {
              retries++;
            },
          ),
        ),
      ),
    );
    expect(find.text('Try another connection'), findsOneWidget);
    await tester.tap(find.text(strings.generic.try_again));
    expect(retries, 1);
  });

  testWidgets('error screen provides retry and home actions', (tester) async {
    var retries = 0;
    var homes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ds.ErrorScreen(
          title: 'Unavailable',
          message: 'Try later',
          error: 'Details',
          onRetry: () {
            retries++;
          },
          onGoHome: () {
            homes++;
          },
        ),
      ),
    );
    expect(find.text('Unavailable'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.tap(find.byType(OutlinedButton));
    expect(retries, 1);
    expect(homes, 1);
  });

  for (final extension in ['png', 'svg']) {
    testWidgets('missing $extension assets render a fallback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ds.AssetImage(assetPath: 'missing.$extension')),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.image), findsOneWidget);
    });
  }

  testWidgets(
    'all theme variants expose appropriate brightness and selected styles',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final design = ds.DesignSystem(context);
              for (final theme in [design.light(), design.dark()]) {
                expect(
                  theme.navigationBarTheme.iconTheme!.resolve({
                    WidgetState.selected,
                  })!.size,
                  20,
                );
                expect(
                  theme.navigationBarTheme.iconTheme!.resolve({})!.size,
                  20,
                );
                expect(
                  theme.navigationBarTheme.labelTextStyle!.resolve({
                    WidgetState.selected,
                  })!.fontWeight,
                  FontWeight.w600,
                );
                expect(
                  theme.navigationBarTheme.labelTextStyle!
                      .resolve({})!
                      .fontWeight,
                  FontWeight.w500,
                );
              }
              final palette = design.theme;
              for (final theme in [
                palette.light(),
                palette.lightMediumContrast(),
                palette.lightHighContrast(),
              ]) {
                expect(theme.brightness, Brightness.light);
              }
              for (final theme in [
                palette.dark(),
                palette.darkMediumContrast(),
                palette.darkHighContrast(),
              ]) {
                expect(theme.brightness, Brightness.dark);
              }
              expect(palette.extendedColors, isEmpty);
              return const SizedBox();
            },
          ),
        ),
      );
    },
  );

  testWidgets('wrapper changes brightness and supports loader show and hide', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    late BuildContext loaderContext;
    await tester.pumpWidget(
      ds.DesignSystemWrapper(
        builder: (_, theme) => MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              loaderContext = context;
              return Scaffold(body: Text(theme.brightness.name));
            },
          ),
        ),
      ),
    );
    expect(find.text('light'), findsOneWidget);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(find.text('dark'), findsOneWidget);
    ds.Loader.show(loaderContext);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ds.DefaultLoader), findsOneWidget);
    ds.Loader.hide(loaderContext);
    await tester.pumpAndSettle();
    expect(find.byType(ds.DefaultLoader), findsNothing);
  });

  test('nullable string helpers preserve nonempty text', () {
    expect((null as String?).asEmptyIfNull, '');
    expect('text'.asEmptyIfNull, 'text');
    expect((null as String?).isNotNullAndNotEmpty, isFalse);
    expect(''.isNotNullAndNotEmpty, isFalse);
    expect('text'.isNotNullAndNotEmpty, isTrue);
    expect(ds.HeaderType.image.ratio, 4);
    expect(ds.HeaderType.asset.ratio, 1);
  });
}
