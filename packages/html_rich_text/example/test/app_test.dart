import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html_rich_text/html_rich_text.dart';
import 'package:example_html_rich_text/main.dart' as app;

void main() {
  testWidgets('demo renders every card and responds to all link examples',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('HTML Rich Text Examples'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(12));
    final links = tester
        .widgetList<HtmlRichText>(find.byType(HtmlRichText))
        .where((widget) => widget.onLinkTap != null)
        .toList();
    expect(links, hasLength(3));
    for (var index = 0; index < links.length; index++) {
      links[index].onLinkTap!('https://example.com');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
          find.text('${[
            'Tapped:',
            'Opening:',
            'Link clicked:'
          ][index]} https://example.com'),
          findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    }
  });
}
