import 'package:flutter/material.dart';

// Basic examples
import 'examples/basic/boolean_null_example.dart';
import 'examples/basic/number_validations_example.dart';
import 'examples/basic/string_validation_example.dart';
import 'examples/basic/user_schema_example.dart';

// Complex examples
import 'examples/complex/array_advanced_example.dart';
import 'examples/complex/enum_example.dart';
import 'examples/complex/object_manipulation_example.dart';
import 'examples/complex/record_example.dart';
import 'examples/complex/tuple_example.dart';

// Advanced examples
import 'examples/advanced/coercion_example.dart';
import 'examples/advanced/discriminated_union_example.dart';
import 'examples/advanced/pipeline_example.dart';
import 'examples/advanced/recursive_schema_example.dart';

// Async examples
import 'examples/async/api_validation_example.dart';
import 'examples/async/database_validation_example.dart';

// Error handling examples
import 'examples/error_handling/error_code_system_example.dart';
import 'examples/error_handling/error_formatting_example.dart';

// Schema composition examples
import 'examples/schema_composition/introspection_example.dart';
import 'examples/schema_composition/json_schema_generation_example.dart';

// Security examples
import 'examples/security/security_best_practices_example.dart';

// Real world examples
import 'examples/real_world/authentication_schema_example.dart';

class ExampleItem {
  final String title;
  final Widget widget;
  final IconData icon;

  const ExampleItem(this.title, this.widget, this.icon);
}

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
  String _selectedCategory = 'Basic';

  final Map<String, List<ExampleItem>> _categorizedExamples = {
    'Basic': [
      const ExampleItem('Example 1: User Schema', UserSchemaExample(), Icons.person_outline),
      const ExampleItem('Example 2: String Validations', StringValidationExample(), Icons.text_fields),
      const ExampleItem('Example 3: Number Validations', NumberValidationsExample(), Icons.numbers),
      const ExampleItem('Example 4: Boolean & Null', BooleanNullExample(), Icons.toggle_on),
    ],
    'Complex': [
      const ExampleItem('Example 5: Object Manipulation', ObjectManipulationExample(), Icons.transform),
      const ExampleItem('Example 6: Advanced Arrays', ArrayAdvancedExample(), Icons.list),
      const ExampleItem('Example 7: Type-safe Tuples', TupleExample(), Icons.view_list),
      const ExampleItem('Example 8: Flexible Enums', EnumExample(), Icons.list_alt),
      const ExampleItem('Example 9: Key-value Records', RecordExample(), Icons.table_chart),
    ],
    'Advanced': [
      const ExampleItem('Example 10: Discriminated Unions', DiscriminatedUnionExample(), Icons.account_tree),
      const ExampleItem('Example 11: Validation Pipelines', PipelineExample(), Icons.plumbing),
      const ExampleItem('Example 12: Recursive Schemas', RecursiveSchemaExample(), Icons.account_tree),
      const ExampleItem('Example 13: Type Coercion', CoercionExample(), Icons.transform),
    ],
    'Async': [
      const ExampleItem('Example 14: Database Validation', DatabaseValidationExample(), Icons.storage),
      const ExampleItem('Example 15: API Validation', ApiValidationExample(), Icons.cloud_done),
    ],
    'Error Handling': [
      const ExampleItem('Example 20: Error Code System', ErrorCodeSystemExample(), Icons.error_outline),
      const ExampleItem('Example 21: Error Formatting', ErrorFormattingExample(), Icons.format_list_bulleted),
    ],
    'Schema Composition': [
      const ExampleItem('Example 23: Schema Introspection', IntrospectionExample(), Icons.schema),
      const ExampleItem('Example 25: JSON Schema Generation', JsonSchemaGenerationExample(), Icons.code),
    ],
    'Security': [
      const ExampleItem('Example 30: Security Best Practices', SecurityBestPracticesExample(), Icons.security),
    ],
    'Real World': [
      const ExampleItem('Example 32: Authentication Schema', AuthenticationSchemaExample(), Icons.lock),
    ],
  };

  List<Widget> get _currentExamples => 
      _categorizedExamples[_selectedCategory]!.map((e) => e.widget).toList();

  List<String> get _currentTitles => 
      _categorizedExamples[_selectedCategory]!.map((e) => e.title).toList();

  List<IconData> get _currentIcons => 
      _categorizedExamples[_selectedCategory]!.map((e) => e.icon).toList();

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
          // Sidebar with categories and examples
          SizedBox(
            width: MediaQuery.of(context).size.width > 800 ? 300 : 250,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Category selector
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                          _selectedIndex = 0;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _categorizedExamples.keys.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  // Examples list
                  Expanded(
                    child: ListView.builder(
                      itemCount: _currentTitles.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedIndex;
                        return ListTile(
                          selected: isSelected,
                          leading: Icon(
                            _currentIcons[index],
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary 
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          title: Text(
                            _currentTitles[index],
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  
                  // Stats footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${_categorizedExamples.values.expand((e) => e).length}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Examples',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${_categorizedExamples.length}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Categories',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with category info
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(_selectedCategory),
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_selectedCategory Examples',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              _getCategoryDescription(_selectedCategory),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Current example
                  _currentExamples[_selectedIndex],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Basic':
        return Icons.foundation;
      case 'Complex':
        return Icons.architecture;
      case 'Advanced':
        return Icons.rocket_launch;
      case 'Async':
        return Icons.sync;
      case 'Error Handling':
        return Icons.error_outline;
      case 'Schema Composition':
        return Icons.schema;
      case 'Security':
        return Icons.security;
      case 'Real World':
        return Icons.public;
      default:
        return Icons.code;
    }
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'Basic':
        return 'Fundamental validation patterns for common data types';
      case 'Complex':
        return 'Advanced data structure validation with objects, arrays, and collections';
      case 'Advanced':
        return 'Sophisticated validation patterns with unions, pipelines, and recursion';
      case 'Async':
        return 'Asynchronous validation with database checks and API calls';
      case 'Error Handling':
        return 'Comprehensive error reporting and formatting strategies';
      case 'Schema Composition':
        return 'Schema introspection, transformation, and JSON Schema generation';
      case 'Security':
        return 'Security-focused validation patterns to prevent common vulnerabilities';
      case 'Real World':
        return 'Production-ready examples for real-world applications';
      default:
        return 'Interactive validation examples';
    }
  }
}
