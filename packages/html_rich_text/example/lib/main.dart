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
                'Welcome to <b>Flutter</b>! Check out this <i>amazing</i> and <u>lightweight</u> package.',
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
                  'u': TextStyle(decoration: TextDecoration.underline),
                },
              ),
            ),
            _buildExample(
              'Product Description',
              const HtmlRichText(
                'This product is <b>amazing</b>! Features include <i>lightweight design</i> and <u>superior quality</u>.',
                tagStyles: {
                  'b': TextStyle(fontWeight: FontWeight.bold),
                  'i': TextStyle(fontStyle: FontStyle.italic),
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
