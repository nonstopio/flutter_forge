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
class HtmlRichText extends StatelessWidget {
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
  });

  /// Builds the widget by parsing HTML text and returning a [RichText] widget.
  ///
  /// This method processes the [htmlText] using the provided [tagStyles] mapping
  /// and creates a [RichText] widget with the appropriate styling.
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      text: _parseAdvancedHtmlToTextSpan(htmlText, context),
    );
  }

  TextSpan _parseAdvancedHtmlToTextSpan(String html, BuildContext context) {
    final List<TextSpan> spans = [];

    // Return early if no tagStyles provided
    if (tagStyles.isEmpty) {
      return TextSpan(
        text: html,
        style: style ?? Theme.of(context).textTheme.bodyMedium,
      );
    }

    // Create regex pattern for only the tags defined in tagStyles
    final String tagPattern =
        tagStyles.keys.map((tag) => '<$tag>(.*?)</$tag>').join('|');
    final RegExp tagRegex = RegExp(tagPattern, caseSensitive: false);

    int lastIndex = 0;

    for (final Match match in tagRegex.allMatches(html)) {
      // Add text before the tag
      if (match.start > lastIndex) {
        final beforeText = html.substring(lastIndex, match.start);
        if (beforeText.isNotEmpty) {
          spans.add(TextSpan(
            text: beforeText,
            style: style ?? Theme.of(context).textTheme.bodyMedium,
          ));
        }
      }

      // Find which tag matched and get its content
      final String matchedTag = match.group(0)!;
      String? tagName;
      String? content;

      for (final tag in tagStyles.keys) {
        final tagPattern = RegExp('<$tag>(.*?)</$tag>', caseSensitive: false);
        final tagMatch = tagPattern.firstMatch(matchedTag);
        if (tagMatch != null) {
          tagName = tag;
          content = tagMatch.group(1);
          break;
        }
      }

      if (tagName != null && content != null) {
        final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
        final tagStyleFromMap = tagStyles[tagName]!;

        spans.add(TextSpan(
          text: content,
          style: baseStyle?.merge(tagStyleFromMap) ?? tagStyleFromMap,
        ));
      }

      lastIndex = match.end;
    }

    // Add remaining text after the last tag
    if (lastIndex < html.length) {
      final remainingText = html.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        spans.add(TextSpan(
          text: remainingText,
          style: style ?? Theme.of(context).textTheme.bodyMedium,
        ));
      }
    }

    // If no tags found, return the whole text as normal
    if (spans.isEmpty) {
      return TextSpan(
        text: html,
        style: style ?? Theme.of(context).textTheme.bodyMedium,
      );
    }

    return TextSpan(children: spans);
  }
}
