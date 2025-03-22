import 'package:test/test.dart';
import 'package:cli_utils/cli_utils.dart';

void main() {
  group('StringCaseExtension', () {
    test('snakeCase', () {
      expect('helloWorld'.snakeCase, equals('hello_world'));
      expect('HelloWorld'.snakeCase, equals('hello_world'));
      expect('hello_world'.snakeCase, equals('hello_world'));
      expect('HELLO_WORLD'.snakeCase, equals('hello_world'));
      expect('hello-world'.snakeCase, equals('hello_world')); // Hyphens should be converted to underscores
      expect('hello world'.snakeCase, equals('hello_world')); // Spaces should be converted to underscores
    });

    test('pascalCase', () {
      expect('hello_world'.pascalCase, equals('HelloWorld'));
      expect('HelloWorld'.pascalCase, equals('HelloWorld'));
      expect('hello-world'.pascalCase, equals('HelloWorld'));
      expect('hello world'.pascalCase, equals('HelloWorld'));
    });

    test('camelCase', () {
      expect('hello_world'.camelCase, equals('helloWorld'));
      expect('HelloWorld'.camelCase, equals('helloWorld'));
      expect('hello-world'.camelCase, equals('helloWorld'));
      expect('hello world'.camelCase, equals('helloWorld'));
    });

    test('titleCase', () {
      expect('hello_world'.titleCase, equals('Hello World'));
      expect('HelloWorld'.titleCase, equals('Hello World'));
      expect('hello-world'.titleCase, equals('Hello World'));
      expect('hello world'.titleCase, equals('Hello World'));
    });
  });
}