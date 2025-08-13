import 'package:flutter/material.dart';
import 'package:html_rich_text/html_rich_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTML Rich Text Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HtmlRichTextDemo(),
    );
  }
}

class HtmlRichTextDemo extends StatelessWidget {
  const HtmlRichTextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTML Rich Text Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildExample(
              'Basic Example',
              const HtmlRichText(
                'Hello <b>World</b>! This is <i>italic</i> text.',
                tagStyles: {
                  'b': TextStyle(fontWeight: FontWeight.bold),
                  'i': TextStyle(fontStyle: FontStyle.italic),
                },
              ),
            ),
            _buildExample(
              'Colored Tags',
              const HtmlRichText(
                'Welcome to <b>Flutter</b>! Check out this <i>amazing</i>, <strong>powerful</strong> and <u>lightweight</u> package.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                tagStyles: {
                  'b': TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  'i': TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.green,
                  ),
                  'strong': TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                  ),
                  'u': TextStyle(decoration: TextDecoration.underline),
                },
              ),
            ),
            _buildExample(
              'Product Description',
              const HtmlRichText(
                'This product is <b>amazing</b>! Features include <i>lightweight design</i>, <strong>superior quality</strong> and <u>great value</u>.',
                tagStyles: {
                  'b': TextStyle(fontWeight: FontWeight.bold),
                  'i': TextStyle(fontStyle: FontStyle.italic),
                  'strong': TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.orange,
                  ),
                  'u': TextStyle(decoration: TextDecoration.underline),
                },
              ),
            ),
            _buildExample(
              'Chat Message',
              const HtmlRichText(
                'User said: <b>Hello!</b> How are you <i>today</i>?',
                tagStyles: {
                  'b': TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  'i': TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                },
              ),
            ),
            _buildExample(
              'News Article',
              const HtmlRichText(
                '<b>Breaking News:</b> Flutter releases <i>amazing</i> new features!',
                style: TextStyle(fontSize: 18),
                tagStyles: {
                  'b': TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  'i': TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                  ),
                },
              ),
            ),
            _buildExample(
              'Text Alignment',
              const HtmlRichText(
                'This is <b>center aligned</b> text with <i>styles</i>!',
                textAlign: TextAlign.center,
                tagStyles: {
                  'b': TextStyle(fontWeight: FontWeight.bold),
                  'i': TextStyle(fontStyle: FontStyle.italic),
                },
              ),
            ),
            _buildExample(
              'Max Lines with Overflow',
              const HtmlRichText(
                'This is a <b>very long text</b> that demonstrates the <i>maxLines</i> '
                'and <u>overflow</u> properties. When text is too long, it will be '
                'truncated with an ellipsis. This is useful for preview text in lists '
                'or cards where space is limited.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                tagStyles: {
                  'b': TextStyle(fontWeight: FontWeight.bold),
                  'i': TextStyle(fontStyle: FontStyle.italic),
                  'u': TextStyle(decoration: TextDecoration.underline),
                },
              ),
            ),
            _buildExample(
              'Mixed Content',
              const HtmlRichText(
                'Regular text, then <b>bold text</b>, followed by <i>italic text</i>, '
                'and finally <u>underlined text</u>. All seamlessly integrated!',
                style: TextStyle(fontSize: 16),
                tagStyles: {
                  'b': TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  'i': TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.orange,
                  ),
                  'u': TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.teal,
                  ),
                },
              ),
            ),
            _buildExample(
              'Clickable Links',
              HtmlRichText(
                'Check out <a href="https://flutter.dev">Flutter</a> and '
                '<a href="https://dart.dev">Dart</a> for more information.',
                onLinkTap: (url) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tapped: $url'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            _buildExample(
              'Custom Link Styling',
              HtmlRichText(
                'Visit our <a href="https://example.com">website</a> for '
                'more <a href="https://example.com/products">products</a>.',
                tagStyles: const {
                  'a': TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                },
                onLinkTap: (url) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening: $url'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            _buildExample(
              'Mixed Tags with Links',
              HtmlRichText(
                'This is <b>important</b>: visit <a href="https://flutter.dev">Flutter</a> '
                'for <i>amazing</i> mobile development!',
                tagStyles: const {
                  'b': TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  'i': TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.purple,
                  ),
                },
                onLinkTap: (url) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Link clicked: $url'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            _buildExample(
              'Non-clickable Styled Links',
              const HtmlRichText(
                'This <a href="https://example.com">link</a> is styled but not clickable '
                'because onLinkTap is not provided.',
                tagStyles: {
                  'a': TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExample(String title, Widget example) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            example,
          ],
        ),
      ),
    );
  }
}
