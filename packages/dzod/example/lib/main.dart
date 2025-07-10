import 'package:flutter/material.dart';

import 'examples/basic/boolean_null_example.dart';
import 'examples/basic/number_validations_example.dart';
import 'examples/basic/string_validation_example.dart';
import 'examples/basic/user_schema_example.dart';
import 'examples/complex/array_advanced_example.dart';
import 'examples/complex/enum_example.dart';
import 'examples/complex/object_manipulation_example.dart';
import 'examples/complex/tuple_example.dart';

void main() {
  runApp(const DzodExampleApp());
}

class DzodExampleApp extends StatelessWidget {
  const DzodExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dzod Validation Showcase',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const ValidationShowcasePage(),
    );
  }
}

class ValidationShowcasePage extends StatefulWidget {
  const ValidationShowcasePage({super.key});

  @override
  State<ValidationShowcasePage> createState() => _ValidationShowcasePageState();
}

class _ValidationShowcasePageState extends State<ValidationShowcasePage> {
  int _selectedIndex = 0;

  final List<Widget> _examples = [
    const UserSchemaExample(),
    const StringValidationExample(),
    const NumberValidationsExample(),
    const BooleanNullExample(),
    const ObjectManipulationExample(),
    const ArrayAdvancedExample(),
    const TupleExample(),
    const EnumExample(),
  ];

  final List<String> _exampleTitles = [
    'Example 1: User Schema',
    'Example 2: String Validations',
    'Example 3: Number Validations',
    'Example 4: Boolean & Null',
    'Example 5: Object Manipulation',
    'Example 6: Advanced Arrays',
    'Example 7: Type-safe Tuples',
    'Example 8: Flexible Enums',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dzod Validation Showcase'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            extended: MediaQuery.of(context).size.width > 800,
            labelType: MediaQuery.of(context).size.width > 600
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.selected,
            backgroundColor: Theme.of(context).colorScheme.surface,
            destinations: _exampleTitles.asMap().entries.map((entry) {
              final index = entry.key;
              final title = entry.value;
              return NavigationRailDestination(
                icon: Icon(_getIconForExample(index)),
                selectedIcon: Icon(_getIconForExample(index)),
                label: Text(title),
              );
            }).toList(),
          ),

          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive Validation Examples',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore dzod validation features through interactive examples',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Current example
                  _examples[_selectedIndex],

                  const SizedBox(height: 24),

                  // Coming Soon section
                  if (_selectedIndex == _examples.length - 1)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.construction,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Coming Soon',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'More validation examples will be added here:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                'Records Validation',
                                'Discriminated Unions',
                                'Async Validation',
                                'Flutter Integration',
                                'Custom Validation',
                                'Complex Schemas',
                              ]
                                  .map((text) => Chip(
                                        label: Text(text),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        labelStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
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

  IconData _getIconForExample(int index) {
    switch (index) {
      case 0:
        return Icons.person_outline;
      case 1:
        return Icons.text_fields;
      case 2:
        return Icons.numbers;
      case 3:
        return Icons.toggle_on;
      case 4:
        return Icons.transform;
      case 5:
        return Icons.list;
      case 6:
        return Icons.view_list;
      case 7:
        return Icons.list_alt;
      default:
        return Icons.code;
    }
  }
}
