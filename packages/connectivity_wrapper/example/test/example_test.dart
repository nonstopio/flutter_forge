import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:connectivity_wrapper_example/main.dart' as app;
import 'package:connectivity_wrapper_example/screens/custom_offline_widget_screen.dart';
import 'package:connectivity_wrapper_example/screens/network_aware_widget_screen.dart';
import 'package:connectivity_wrapper_example/screens/scaffold_example_screen.dart';
import 'package:connectivity_wrapper_example/utils/strings.dart';
import 'package:connectivity_wrapper_example/utils/ui_helper.dart' as ui;
import 'package:connectivity_wrapper_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var connected = true;
  setUp(() {
    connected = true;
    ConnectivityWrapper.instance.networkChecker = () async => connected;
    ConnectivityWrapper.instance.checkInterval =
        const Duration(milliseconds: 20);
  });
  tearDown(() {
    ConnectivityWrapper.instance.networkChecker = null;
    ConnectivityWrapper.instance.checkInterval = const Duration(seconds: 2);
  });

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(ConnectivityWrapper.instance.hasListeners, isFalse);
  }

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester
        .pumpWidget(ConnectivityAppWrapper(app: MaterialApp(home: screen)));
    await tester.pumpAndSettle();
  }

  testWidgets('entry point navigates to each demonstration', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Connectivity Wrapper Example'), findsOneWidget);
    for (final title in [
      Strings.example1,
      Strings.example2,
      Strings.example3
    ]) {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    await close(tester);
  });

  testWidgets('menu checks current connection and shows both status messages',
      (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.example4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('You Are Connected'), findsOneWidget);
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
        Colors.green);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    connected = false;
    await tester.tap(find.text(Strings.example4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('You Are Not Connected'), findsOneWidget);
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
        Colors.red);
    await close(tester);
  });

  testWidgets(
      'scaffold controls customize and reset each offline presentation option',
      (tester) async {
    await pumpScreen(tester, const ScaffoldExampleScreen());
    ConnectivityWidgetWrapper wrapper() =>
        tester.widget(find.byType(ConnectivityWidgetWrapper));
    expect(wrapper().alignment, Alignment.bottomCenter);
    final controls = <String, void Function(bool)>{
      Strings.customDecoration: (enabled) =>
          expect(wrapper().decoration, enabled ? isA<BoxDecoration>() : isNull),
      Strings.customHeight: (enabled) =>
          expect(wrapper().height, enabled ? 150 : isNull),
      Strings.customMessage: (enabled) {
        expect(wrapper().message, enabled ? Strings.offlineMessage : isNull);
        expect(wrapper().messageStyle?.fontSize, enabled ? 40 : isNull);
      },
      Strings.userInteraction: (enabled) =>
          expect(wrapper().disableInteraction, enabled),
    };
    for (final entry in controls.entries) {
      final finder = find.widgetWithText(CheckboxListTile, entry.key);
      tester.widget<CheckboxListTile>(finder).onChanged!(null);
      await tester.pump();
      entry.value(false);
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
      entry.value(true);
      await tester.tap(finder);
      await tester.pumpAndSettle();
      entry.value(false);
    }
    for (final entry in {
      Icons.arrow_upward: Alignment.topCenter,
      Icons.center_focus_strong: Alignment.center,
      Icons.arrow_downward: Alignment.bottomCenter
    }.entries) {
      await tester.ensureVisible(find.byIcon(entry.key));
      await tester.tap(find.byIcon(entry.key));
      await tester.pumpAndSettle();
      expect(wrapper().alignment, entry.value);
    }
    await close(tester);
  });

  testWidgets('custom offline screen renders its illustration and reconnects',
      (tester) async {
    await pumpScreen(tester, const CustomOfflineWidgetScreen());
    expect(find.text(' Item 0'), findsOneWidget);
    connected = false;
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(OfflineWidget), findsOneWidget);
    expect(find.text(Strings.offlineMessage), findsOneWidget);
    expect(tester.widget<Image>(find.byType(Image)).image,
        const AssetImage('assets/dog.gif'));
    connected = true;
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(OfflineWidget), findsNothing);
    await close(tester);
  });

  testWidgets('network-aware form disables sign in while offline',
      (tester) async {
    await pumpScreen(tester, const NetworkAwareWidgetScreen());
    await tester.enterText(find.byType(TextField).first, 'a@example.com');
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.tap(find.text('Sign In'));
    expect(
        tester
            .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'Sign In'))
            .onPressed,
        isNotNull);
    connected = false;
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Sign In'), findsNothing);
    expect(
        tester
            .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'Connecting'))
            .onPressed,
        isNull);
    await close(tester);
  });

  testWidgets('snackbar and spacer helpers respect custom and default options',
      (tester) async {
    late BuildContext context;
    await tester
        .pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (value) {
      context = value;
      return const Column(children: [ui.Spacer(), ui.Spacer(size: 12)]);
    }))));
    final paddings = tester
        .widgetList<Padding>(find.descendant(
            of: find.byType(ui.Spacer), matching: find.byType(Padding)))
        .map((widget) => widget.padding);
    expect(paddings, [const EdgeInsets.all(5), const EdgeInsets.all(12)]);
    const style = TextStyle(fontSize: 22, color: Colors.pink);
    showSnackBar(context,
        title: 'custom', color: Colors.blue, milliseconds: 500, style: style);
    await tester.pumpAndSettle();
    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.duration, const Duration(milliseconds: 500));
    expect(bar.backgroundColor, Colors.blue);
    expect(tester.widget<Text>(find.text('custom')).style, style);
    await tester.pumpWidget(const SizedBox());
  });
}
