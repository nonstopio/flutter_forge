import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html_rich_text/html_rich_text.dart';

void main() {
  group('HtmlRichText', () {
    testWidgets('renders plain text when no tags are defined',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HtmlRichText(
              'Hello World',
              tagStyles: {},
            ),
          ),
        ),
      );

      final RichText richText = tester.widget(find.byType(RichText));
      final TextSpan textSpan = richText.text as TextSpan;

      expect(textSpan.text, 'Hello World');
    });

    testWidgets('renders bold text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HtmlRichText(
              'Hello <b>World</b>!',
              tagStyles: {
                'b': TextStyle(fontWeight: FontWeight.bold),
              },
            ),
          ),
        ),
      );

      final RichText richText = tester.widget(find.byType(RichText));
      final TextSpan textSpan = richText.text as TextSpan;

      expect(textSpan.children!.length, 3);
      expect((textSpan.children![0] as TextSpan).text, 'Hello ');
      expect((textSpan.children![1] as TextSpan).text, 'World');
      expect(
        (textSpan.children![1] as TextSpan).style?.fontWeight,
        FontWeight.bold,
      );
      expect((textSpan.children![2] as TextSpan).text, '!');
    });

    testWidgets('renders italic text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HtmlRichText(
              'Hello <i>World</i>!',
              tagStyles: {
                'i': TextStyle(fontStyle: FontStyle.italic),
              },
            ),
          ),
        ),
      );

      final RichText richText = tester.widget(find.byType(RichText));
      final TextSpan textSpan = richText.text as TextSpan;

      expect(textSpan.children!.length, 3);
      expect((textSpan.children![1] as TextSpan).style?.fontStyle,
          FontStyle.italic);
    });

    testWidgets('renders multiple tags correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HtmlRichText(
              'Hello <b>bold</b> and <i>italic</i> text!',
              tagStyles: {
                'b': TextStyle(fontWeight: FontWeight.bold),
                'i': TextStyle(fontStyle: FontStyle.italic),
              },
            ),
          ),
        ),
      );

      final RichText richText = tester.widget(find.byType(RichText));
      final TextSpan textSpan = richText.text as TextSpan;

      expect(textSpan.children!.length, 5);
      expect((textSpan.children![0] as TextSpan).text, 'Hello ');
      expect((textSpan.children![1] as TextSpan).text, 'bold');
      expect((textSpan.children![2] as TextSpan).text, ' and ');
      expect((textSpan.children![3] as TextSpan).text, 'italic');
      expect((textSpan.children![4] as TextSpan).text, ' text!');
    });

    testWidgets('applies base style to non-tagged text',
        (WidgetTester tester) async {
      const baseStyle = TextStyle(fontSize: 20, color: Colors.blue);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HtmlRichText(
              'Hello <b>World</b>!',
              style: baseStyle,
              tagStyles: {
                'b': TextStyle(fontWeight: FontWeight.bold),
              },
            ),
          ),
        ),
      );

      final RichText richText = tester.widget(find.byType(RichText));
      final TextSpan textSpan = richText.text as TextSpan;

      expect((textSpan.children![0] as TextSpan).style?.fontSize, 20);
      expect((textSpan.children![0] as TextSpan).style?.color, Colors.blue);
    });

    testWidgets('respects text alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HtmlRichText(
              'Hello World',
              textAlign: TextAlign.center,
              tagStyles: {},
            ),
          ),
        ),
      );

      final RichText richText = tester.widget(find.byType(RichText));
      expect(richText.textAlign, TextAlign.center);
    });

    testWidgets('respects maxLines property', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HtmlRichText(
              'Hello World',
              maxLines: 2,
              tagStyles: {},
            ),
          ),
        ),
      );

      final RichText richText = tester.widget(find.byType(RichText));
      expect(richText.maxLines, 2);
    });

    testWidgets('respects overflow property', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HtmlRichText(
              'Hello World',
              overflow: TextOverflow.ellipsis,
              tagStyles: {},
            ),
          ),
        ),
      );

      final RichText richText = tester.widget(find.byType(RichText));
      expect(richText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('ignores undefined tags', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HtmlRichText(
              'Hello <b>bold</b> and <unknown>unknown</unknown> text!',
              tagStyles: {
                'b': TextStyle(fontWeight: FontWeight.bold),
              },
            ),
          ),
        ),
      );

      final RichText richText = tester.widget(find.byType(RichText));
      final TextSpan textSpan = richText.text as TextSpan;

      // The unknown tag should be treated as plain text
      expect(textSpan.children!.length, 3);
      expect((textSpan.children![0] as TextSpan).text, 'Hello ');
      expect((textSpan.children![1] as TextSpan).text, 'bold');
      expect((textSpan.children![2] as TextSpan).text,
          ' and <unknown>unknown</unknown> text!');
    });

    testWidgets('handles case-insensitive tags', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HtmlRichText(
              'Hello <B>World</B>!',
              tagStyles: {
                'b': TextStyle(fontWeight: FontWeight.bold),
              },
            ),
          ),
        ),
      );

      final RichText richText = tester.widget(find.byType(RichText));
      final TextSpan textSpan = richText.text as TextSpan;

      expect(textSpan.children!.length, 3);
      expect((textSpan.children![1] as TextSpan).text, 'World');
      expect(
        (textSpan.children![1] as TextSpan).style?.fontWeight,
        FontWeight.bold,
      );
    });

    testWidgets('merges tag styles with base style',
        (WidgetTester tester) async {
      const baseStyle = TextStyle(fontSize: 20, color: Colors.blue);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HtmlRichText(
              'Hello <b>World</b>!',
              style: baseStyle,
              tagStyles: {
                'b': TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              },
            ),
          ),
        ),
      );

      final RichText richText = tester.widget(find.byType(RichText));
      final TextSpan textSpan = richText.text as TextSpan;

      // Tagged text should have merged styles
      final taggedStyle = (textSpan.children![1] as TextSpan).style;
      expect(taggedStyle?.fontSize, 20); // Inherited from base
      expect(taggedStyle?.color, Colors.red); // Overridden by tag
      expect(taggedStyle?.fontWeight, FontWeight.bold); // From tag
    });

    group('<a> tag support', () {
      testWidgets('renders <a> tag with default link style',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HtmlRichText(
                'Visit <a href="https://flutter.dev">Flutter</a> website',
                onLinkTap: (url) {},
              ),
            ),
          ),
        );

        final RichText richText = tester.widget(find.byType(RichText));
        final TextSpan textSpan = richText.text as TextSpan;

        expect(textSpan.children!.length, 3);
        expect((textSpan.children![0] as TextSpan).text, 'Visit ');
        expect((textSpan.children![1] as TextSpan).text, 'Flutter');
        expect((textSpan.children![2] as TextSpan).text, ' website');

        // Check default link style
        final linkStyle = (textSpan.children![1] as TextSpan).style;
        expect(linkStyle?.color, Colors.blue);
        expect(linkStyle?.decoration, TextDecoration.underline);
      });

      testWidgets('applies custom style to <a> tag',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HtmlRichText(
                'Visit <a href="https://flutter.dev">Flutter</a> website',
                tagStyles: const {
                  'a': TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                },
                onLinkTap: (url) {},
              ),
            ),
          ),
        );

        final RichText richText = tester.widget(find.byType(RichText));
        final TextSpan textSpan = richText.text as TextSpan;

        final linkStyle = (textSpan.children![1] as TextSpan).style;
        expect(linkStyle?.color, Colors.green);
        expect(linkStyle?.fontWeight, FontWeight.bold);
      });

      testWidgets('calls onLinkTap callback when link is tapped',
          (WidgetTester tester) async {
        String? tappedUrl;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HtmlRichText(
                'Visit <a href="https://flutter.dev">Flutter</a> website',
                onLinkTap: (url) {
                  tappedUrl = url;
                },
              ),
            ),
          ),
        );

        // Find and tap the link
        final RichText richText = tester.widget(find.byType(RichText));
        final TextSpan textSpan = richText.text as TextSpan;
        final linkSpan = textSpan.children![1] as TextSpan;

        // Simulate tap on the link
        expect(linkSpan.recognizer, isNotNull);
        (linkSpan.recognizer as TapGestureRecognizer).onTap!();

        expect(tappedUrl, 'https://flutter.dev');
      });

      testWidgets('handles <a> tag without href', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HtmlRichText(
                'This is <a>a link</a> without href',
                onLinkTap: (url) {},
              ),
            ),
          ),
        );

        final RichText richText = tester.widget(find.byType(RichText));
        final TextSpan textSpan = richText.text as TextSpan;

        expect(textSpan.children!.length, 3);
        expect((textSpan.children![1] as TextSpan).text, 'a link');

        // Link without href should still have style but no recognizer
        final linkStyle = (textSpan.children![1] as TextSpan).style;
        expect(linkStyle?.color, Colors.blue);
        expect(linkStyle?.decoration, TextDecoration.underline);
        expect((textSpan.children![1] as TextSpan).recognizer, isNull);
      });

      testWidgets('handles multiple links in text',
          (WidgetTester tester) async {
        final List<String> tappedUrls = [];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HtmlRichText(
                'Visit <a href="https://flutter.dev">Flutter</a> and <a href="https://dart.dev">Dart</a>',
                onLinkTap: (url) {
                  tappedUrls.add(url);
                },
              ),
            ),
          ),
        );

        final RichText richText = tester.widget(find.byType(RichText));
        final TextSpan textSpan = richText.text as TextSpan;

        expect(textSpan.children!.length, 4);
        expect((textSpan.children![0] as TextSpan).text, 'Visit ');
        expect((textSpan.children![1] as TextSpan).text, 'Flutter');
        expect((textSpan.children![2] as TextSpan).text, ' and ');
        expect((textSpan.children![3] as TextSpan).text, 'Dart');

        // Test first link
        final firstLink = textSpan.children![1] as TextSpan;
        (firstLink.recognizer as TapGestureRecognizer).onTap!();
        expect(tappedUrls, ['https://flutter.dev']);

        // Test second link
        final secondLink = textSpan.children![3] as TextSpan;
        (secondLink.recognizer as TapGestureRecognizer).onTap!();
        expect(tappedUrls, ['https://flutter.dev', 'https://dart.dev']);
      });

      testWidgets('combines <a> tags with other tags',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HtmlRichText(
                'This is <b>bold</b> and <a href="https://example.com">link</a> text',
                tagStyles: const {
                  'b': TextStyle(fontWeight: FontWeight.bold),
                },
                onLinkTap: (url) {},
              ),
            ),
          ),
        );

        final RichText richText = tester.widget(find.byType(RichText));
        final TextSpan textSpan = richText.text as TextSpan;

        expect(textSpan.children!.length, 5);
        expect((textSpan.children![0] as TextSpan).text, 'This is ');
        expect((textSpan.children![1] as TextSpan).text, 'bold');
        expect((textSpan.children![2] as TextSpan).text, ' and ');
        expect((textSpan.children![3] as TextSpan).text, 'link');
        expect((textSpan.children![4] as TextSpan).text, ' text');

        // Check bold style
        expect(
          (textSpan.children![1] as TextSpan).style?.fontWeight,
          FontWeight.bold,
        );

        // Check link style
        final linkStyle = (textSpan.children![3] as TextSpan).style;
        expect(linkStyle?.color, Colors.blue);
        expect(linkStyle?.decoration, TextDecoration.underline);
      });

      testWidgets('link without onLinkTap is not clickable',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: HtmlRichText(
                'Visit <a href="https://flutter.dev">Flutter</a> website',
              ),
            ),
          ),
        );

        final RichText richText = tester.widget(find.byType(RichText));
        final TextSpan textSpan = richText.text as TextSpan;

        // Link should still be styled
        final linkStyle = (textSpan.children![1] as TextSpan).style;
        expect(linkStyle?.color, Colors.blue);
        expect(linkStyle?.decoration, TextDecoration.underline);

        // But should not have a recognizer
        expect((textSpan.children![1] as TextSpan).recognizer, isNull);
      });
    });
  });
}
