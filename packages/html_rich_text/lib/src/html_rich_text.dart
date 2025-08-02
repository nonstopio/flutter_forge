import 'package:flutter/material.dart';

class HtmlRichText extends StatelessWidget {
  final String htmlText;
  final TextStyle? style;
  final Map<String, TextStyle> tagStyles;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const HtmlRichText(
    this.htmlText, {
    super.key,
    this.style,
    this.tagStyles = const {},
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

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