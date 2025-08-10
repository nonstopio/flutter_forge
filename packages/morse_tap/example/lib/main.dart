import 'package:flutter/material.dart';
import 'package:morse_tap/morse_tap.dart';

void main() {
  runApp(const MorseTapExampleApp());
}

class MorseTapExampleApp extends StatelessWidget {
  const MorseTapExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morse Tap Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const MorseTapDetectorExample(),
    const MorseTextInputExample(),
    const StringExtensionExample(),
  ];

  final List<String> _pageTitles = [
    'Tap Detector',
    'Text Input',
    'String Extensions',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentPage]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.touch_app),
            label: 'Tap Detector',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: 'Text Input',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.code), label: 'Extensions'),
        ],
      ),
    );
  }
}

class MorseTapDetectorExample extends StatefulWidget {
  const MorseTapDetectorExample({super.key});

  @override
  State<MorseTapDetectorExample> createState() =>
      _MorseTapDetectorExampleState();
}

class _MorseTapDetectorExampleState extends State<MorseTapDetectorExample> {
  String _message = 'Use gestures to input SOS (... --- ...)';
  String _currentTarget = 'SOS';
  Color _buttonColor = Colors.blue;
  String _gestureHint = '';

  final Map<String, String> _targets = {
    'SOS': '... --- ...',
    'HELLO': '.... . .-.. .-.. ---',
    'OK': '--- -.-',
    'YES': '-.-- . ...',
    'NO': '-. ---',
  };

  void _onCorrectSequence() {
    setState(() {
      _message = '✅ Perfect! You tapped $_currentTarget correctly!';
      _buttonColor = Colors.green;
      _gestureHint = '';
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _message =
              'Use gestures to input $_currentTarget (${_targets[_currentTarget]})';
          _buttonColor = Colors.blue;
        });
      }
    });
  }

  void _onIncorrectSequence() {
    setState(() {
      _message = '❌ Wrong sequence. Try again!';
      _buttonColor = Colors.red;
      _gestureHint = '';
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _message =
              'Use gestures to input $_currentTarget (${_targets[_currentTarget]})';
          _buttonColor = Colors.blue;
        });
      }
    });
  }

  void _onTimeout() {
    setState(() {
      _message = '⏰ Sequence timed out. Try again!';
      _buttonColor = Colors.orange;
      _gestureHint = '';
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _message =
              'Use gestures to input $_currentTarget (${_targets[_currentTarget]})';
          _buttonColor = Colors.blue;
        });
      }
    });
  }

  void _onDotAdded() {
    setState(() {
      _gestureHint = 'Added dot (•)';
    });
  }

  void _onDashAdded() {
    setState(() {
      _gestureHint = 'Added dash (—)';
    });
  }

  void _onSpaceAdded() {
    setState(() {
      _gestureHint = 'Added space';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Morse Tap Detector',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the button below using Morse code patterns. Short taps are dots (•), long taps are dashes (—).',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Target: $_currentTarget',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Morse: ${_targets[_currentTarget]}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Target selection
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _targets.keys.map((target) {
                final isSelected = target == _currentTarget;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(target),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _currentTarget = target;
                          _message =
                              'Use gestures to input $target (${_targets[target]})';
                          _buttonColor = Colors.blue;
                          _gestureHint = '';
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Morse tap detector
          Expanded(
            child: MorseTapDetector(
              expectedMorseCode: _targets[_currentTarget]!,
              onCorrectSequence: _onCorrectSequence,
              onIncorrectSequence: _onIncorrectSequence,
              onSequenceTimeout: _onTimeout,
              onDotAdded: _onDotAdded,
              onDashAdded: _onDashAdded,
              onSpaceAdded: _onSpaceAdded,
              feedbackColor: _buttonColor,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _buttonColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _buttonColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, size: 48, color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'TAP HERE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1 tap = • | 2 taps = — | Hold = space',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Status message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                if (_gestureHint.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue[200]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _gestureHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MorseTextInputExample extends StatefulWidget {
  const MorseTextInputExample({super.key});

  @override
  State<MorseTextInputExample> createState() => _MorseTextInputExampleState();
}

class _MorseTextInputExampleState extends State<MorseTextInputExample> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _morseController = TextEditingController();
  bool _autoConvert = true;

  @override
  void dispose() {
    _textController.dispose();
    _morseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Morse Text Input',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap in the input area to create Morse code. The widget converts your taps to text in real-time.',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _autoConvert,
                        onChanged: (value) {
                          setState(() {
                            _autoConvert = value ?? true;
                          });
                        },
                      ),
                      const Text('Auto-convert to text'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Text input mode
          Expanded(
            child: MorseTextInput(
              controller: _autoConvert ? _textController : _morseController,
              autoConvertToText: _autoConvert,
              showMorsePreview: true,
              onTextChanged: (text) {
                // Optional: handle text changes
              },
              decoration: InputDecoration(
                labelText: _autoConvert ? 'Converted Text' : 'Morse Code',
                helperText: _autoConvert
                    ? 'Text appears here as you tap'
                    : 'Raw Morse code appears here',
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Single tap = dot (•)'),
                  const Text('• Double tap = dash (—)'),
                  const Text('• Long press = space between letters'),
                  const Text('• Auto-completion after 1.2 seconds'),
                  const SizedBox(height: 12),
                  const Text(
                    'Try tapping "HELLO" or "SOS"!',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StringExtensionExample extends StatefulWidget {
  const StringExtensionExample({super.key});

  @override
  State<StringExtensionExample> createState() => _StringExtensionExampleState();
}

class _StringExtensionExampleState extends State<StringExtensionExample> {
  final TextEditingController _inputController = TextEditingController(
    text: 'HELLO WORLD',
  );
  String _morseOutput = '';
  String _backToText = '';

  @override
  void initState() {
    super.initState();
    _updateOutputs();
    _inputController.addListener(_updateOutputs);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _updateOutputs() {
    final input = _inputController.text;
    setState(() {
      _morseOutput = input.toMorseCode();
      _backToText = _morseOutput.fromMorseCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'String Extensions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Demonstrates the extension methods available on String for Morse code conversion.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Input field
          TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              labelText: 'Input Text',
              border: OutlineInputBorder(),
              helperText: 'Type any text to see the Morse code conversion',
            ),
            textCapitalization: TextCapitalization.characters,
          ),

          const SizedBox(height: 16),

          // Outputs
          Expanded(
            child: Column(
              children: [
                // Morse code output
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.code, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              '.toMorseCode()',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            _morseOutput.isEmpty
                                ? 'Enter text above...'
                                : _morseOutput,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Back to text output
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.text_fields, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              '.fromMorseCode()',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            _backToText.isEmpty
                                ? 'Converted text appears here...'
                                : _backToText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Validation indicators
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Validation Methods:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _inputController.text.isValidMorseInput()
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: _inputController.text.isValidMorseInput()
                                  ? Colors.green
                                  : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text('.isValidMorseInput()'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _morseOutput.isValidMorseSequence()
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: _morseOutput.isValidMorseSequence()
                                  ? Colors.green
                                  : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text('.isValidMorseSequence()'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
