import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A widget that renders HTML-styled text using Flutter's RichText widget.
///
/// [HtmlRichText] allows you to display text with basic HTML-like styling
/// by defining custom styles for specific tags. It's a lightweight alternative
/// to full HTML rendering widgets.
///
/// Example:
/// ```dart
/// HtmlRichText(
///   '<b>Bold text</b> and <i>italic text</i>',
///   tagStyles: {
///     'b': TextStyle(fontWeight: FontWeight.bold),
///     'i': TextStyle(fontStyle: FontStyle.italic),
///   },
/// )
/// ```
class HtmlRichText extends StatefulWidget {
  /// The HTML-styled text to be rendered.
  ///
  /// This string can contain HTML-like tags that match the keys in [tagStyles].
  /// Text without matching tags will be rendered using the default [style].
  final String htmlText;

  /// The default text style applied to all text.
  ///
  /// This style is used as the base style for all text. Tag-specific styles
  /// from [tagStyles] will be merged with this style.
  final TextStyle? style;

  /// A map of HTML tag names to their corresponding text styles.
  ///
  /// Keys should be tag names (without angle brackets), and values should be
  /// the [TextStyle] to apply to text within those tags.
  ///
  /// Example:
  /// ```dart
  /// {
  ///   'b': TextStyle(fontWeight: FontWeight.bold),
  ///   'highlight': TextStyle(backgroundColor: Colors.yellow),
  /// }
  /// ```
  final Map<String, TextStyle> tagStyles;

  /// How the text should be aligned horizontally.
  ///
  /// Defaults to [TextAlign.start].
  final TextAlign textAlign;

  /// An optional maximum number of lines for the text to span.
  ///
  /// If the text exceeds the given number of lines, it will be truncated
  /// according to [overflow].
  final int? maxLines;

  /// How visual overflow should be handled.
  ///
  /// This determines what happens when the text would exceed the available space.
  /// Defaults to [TextOverflow.clip].
  final TextOverflow overflow;

  /// Callback function that is called when a link is tapped.
  ///
  /// This callback receives the URL from the href attribute of the <a> tag.
  /// If this is null, links will be styled but not clickable.
  ///
  /// Example:
  /// ```dart
  /// HtmlRichText(
  ///   'Visit <a href="https://flutter.dev">Flutter</a>',
  ///   onLinkTap: (url) => print('Tapped: $url'),
  /// )
  /// ```
  final void Function(String url)? onLinkTap;

  /// Creates an [HtmlRichText] widget.
  ///
  /// The [htmlText] parameter is required and contains the text to be rendered.
  /// Use [tagStyles] to define styling for specific HTML-like tags.
  ///
  /// Example:
  /// ```dart
  /// HtmlRichText(
  ///   'Hello <b>world</b>!',
  ///   tagStyles: {'b': TextStyle(fontWeight: FontWeight.bold)},
  /// )
  /// ```
  const HtmlRichText(
    this.htmlText, {
    super.key,
    this.style,
    this.tagStyles = const {},
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.onLinkTap,
  });

  @override
  State<HtmlRichText> createState() => _HtmlRichTextState();
}

class _HtmlRichTextState extends State<HtmlRichText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  /// Builds the widget by parsing HTML text and returning a [RichText] widget.
  ///
  /// This method processes the [htmlText] using the provided [tagStyles] mapping
  /// and creates a [RichText] widget with the appropriate styling.
  @override
  Widget build(BuildContext context) {
    // Clear previous recognizers
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    return RichText(
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      text: _parseAdvancedHtmlToTextSpan(widget.htmlText, context),
    );
  }

  TextSpan _parseAdvancedHtmlToTextSpan(String html, BuildContext context) {
    final List<TextSpan> spans = [];

    // Check if we need to process HTML
    final bool hasAnyTags = widget.tagStyles.isNotEmpty ||
        html.contains('<a') ||
        widget.onLinkTap != null;

    if (!hasAnyTags) {
      return TextSpan(
        text: html,
        style: widget.style ?? Theme.of(context).textTheme.bodyMedium,
      );
    }

    // Create regex pattern for tags defined in tagStyles and <a> tags
    final List<String> patterns = [];

    // Add patterns for regular tags
    for (final tag in widget.tagStyles.keys) {
      if (tag != 'a') {
        patterns.add('<$tag>(.*?)</$tag>');
      }
    }

    // Always add pattern for <a> tags if they exist in the HTML
    if (html.contains('<a')) {
      patterns.add(r'<a(?:\s+href=["' ']([^"' ']*)[^>]*)?>([^<]*)</a>');
    }

    if (patterns.isEmpty) {
      return TextSpan(
        text: html,
        style: widget.style ?? Theme.of(context).textTheme.bodyMedium,
      );
    }

    final String tagPattern = patterns.join('|');
    final RegExp tagRegex = RegExp(tagPattern, caseSensitive: false);

    int lastIndex = 0;

    for (final Match match in tagRegex.allMatches(html)) {
      // Add text before the tag
      if (match.start > lastIndex) {
        final beforeText = html.substring(lastIndex, match.start);
        if (beforeText.isNotEmpty) {
          spans.add(TextSpan(
            text: beforeText,
            style: widget.style ?? Theme.of(context).textTheme.bodyMedium,
          ));
        }
      }

      // Find which tag matched and get its content
      final String matchedTag = match.group(0)!;

      // Check if it's an <a> tag
      final aTagPattern = RegExp(
        r'<a(?:\s+href=["' ']([^"' ']*)[^>]*)?>([^<]*)</a>',
        caseSensitive: false,
      );
      final aTagMatch = aTagPattern.firstMatch(matchedTag);

      if (aTagMatch != null) {
        // Handle <a> tag
        final String? href = aTagMatch.group(1);
        final String? linkText = aTagMatch.group(2);

        if (linkText != null) {
          final baseStyle =
              widget.style ?? Theme.of(context).textTheme.bodyMedium;

          // Get custom style for 'a' tag or use default link style
          final linkStyle = widget.tagStyles['a'] ??
              const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              );

          final mergedStyle = baseStyle?.merge(linkStyle) ?? linkStyle;

          if (href != null && widget.onLinkTap != null) {
            // Create clickable link
            final recognizer = TapGestureRecognizer()
              ..onTap = () => widget.onLinkTap!(href);
            _recognizers.add(recognizer);

            spans.add(TextSpan(
              text: linkText,
              style: mergedStyle,
              recognizer: recognizer,
            ));
          } else {
            // Non-clickable styled link
            spans.add(TextSpan(
              text: linkText,
              style: mergedStyle,
            ));
          }
        }
      } else {
        // Handle other tags
        String? tagName;
        String? content;

        for (final tag in widget.tagStyles.keys) {
          if (tag == 'a') continue; // Skip 'a' tag as it's handled separately

          final tagPattern = RegExp('<$tag>(.*?)</$tag>', caseSensitive: false);
          final tagMatch = tagPattern.firstMatch(matchedTag);
          if (tagMatch != null) {
            tagName = tag;
            content = tagMatch.group(1);
            break;
          }
        }

        if (tagName != null && content != null) {
          final baseStyle =
              widget.style ?? Theme.of(context).textTheme.bodyMedium;
          final tagStyleFromMap = widget.tagStyles[tagName]!;

          spans.add(TextSpan(
            text: content,
            style: baseStyle?.merge(tagStyleFromMap) ?? tagStyleFromMap,
          ));
        }
      }

      lastIndex = match.end;
    }

    // Add remaining text after the last tag
    if (lastIndex < html.length) {
      final remainingText = html.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        spans.add(TextSpan(
          text: remainingText,
          style: widget.style ?? Theme.of(context).textTheme.bodyMedium,
        ));
      }
    }

    // If no tags found, return the whole text as normal
    if (spans.isEmpty) {
      return TextSpan(
        text: html,
        style: widget.style ?? Theme.of(context).textTheme.bodyMedium,
      );
    }

    return TextSpan(children: spans);
  }
}
