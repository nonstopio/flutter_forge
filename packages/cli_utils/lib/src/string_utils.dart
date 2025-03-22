/// Extension methods for string case conversions.
///
/// Provides utilities to convert strings between different case styles:
/// - snake_case
/// - PascalCase
/// - camelCase
/// - Title Case
///
/// Example usage:
/// ```dart
/// final name = 'MyProject';
/// print(name.snakeCase);    // my_project
/// print(name.camelCase);    // myProject
/// print(name.pascalCase);   // MyProject
/// print(name.titleCase);    // My Project
/// ```
extension StringCaseExtension on String {
  /// Converts string to snake_case.
  ///
  /// Example:
  /// - 'myVariable' -> 'my_variable'
  /// - 'MyClass' -> 'my_class'
  /// - 'my-string' -> 'my_string'
  String get snakeCase {
    if (isEmpty) return this;
    
    final words = <String>[];
    var currentWord = StringBuffer();
    
    for (var i = 0; i < length; i++) {
      final char = this[i];
      if (char == '_' || char == '-' || char == ' ') {
        if (currentWord.isNotEmpty) {
          words.add(currentWord.toString());
          currentWord.clear();
        }
      } else if (i > 0 && char.toUpperCase() == char) {
        // If current char is uppercase and previous char was lowercase
        if (this[i - 1].toLowerCase() == this[i - 1]) {
          if (currentWord.isNotEmpty) {
            words.add(currentWord.toString());
            currentWord.clear();
          }
        }
        currentWord.write(char);
      } else {
        currentWord.write(char);
      }
    }
    
    if (currentWord.isNotEmpty) {
      words.add(currentWord.toString());
    }
    
    return words.map((word) => word.toLowerCase()).join('_');
  }

  /// Converts string to PascalCase.
  ///
  /// Example:
  /// - 'my_variable' -> 'MyVariable'
  /// - 'my-string' -> 'MyString'
  /// - 'my string' -> 'MyString'
  String get pascalCase {
    if (isEmpty) return this;
    return snakeCase
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join();
  }

  /// Converts string to camelCase.
  ///
  /// Example:
  /// - 'MyClass' -> 'myClass'
  /// - 'my_variable' -> 'myVariable'
  /// - 'my string' -> 'myString'
  String get camelCase {
    final pascal = pascalCase;
    return pascal.isEmpty ? '' : pascal[0].toLowerCase() + pascal.substring(1);
  }

  /// Converts string to Title Case.
  ///
  /// Example:
  /// - 'myVariable' -> 'My Variable'
  /// - 'my_string' -> 'My String'
  /// - 'MyClass' -> 'My Class'
  String get titleCase {
    if (isEmpty) return this;
    return snakeCase
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}