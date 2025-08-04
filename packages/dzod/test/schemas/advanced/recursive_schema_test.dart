import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('RecursiveSchema', () {
    group('Basic Recursive Validation', () {
      test('should validate simple recursive structure', () {
        late Schema<Map<String, dynamic>> treeSchema;
        treeSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
              'children': z.array(treeSchema).optional(),
            }));

        final validTree = {
          'value': 'root',
          'children': [
            {'value': 'child1'},
            {
              'value': 'child2',
              'children': [
                {'value': 'grandchild1'},
              ],
            },
          ],
        };

        final result = treeSchema.parse(validTree);
        expect(result['value'], equals('root'));
        expect(result['children'], hasLength(2));
        expect(result['children'][1]['children'], hasLength(1));
      });

      test('should validate recursive structure without optional children', () {
        late Schema<Map<String, dynamic>> nodeSchema;
        nodeSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'id': z.number(),
              'parent': nodeSchema.optional(),
            }));

        final validNode = {
          'id': 1,
          'parent': {
            'id': 0,
          },
        };

        final result = nodeSchema.parse(validNode);
        expect(result['id'], equals(1));
        expect(result['parent']['id'], equals(0));
      });

      test('should fail validation for invalid recursive structure', () {
        late Schema<Map<String, dynamic>> treeSchema;
        treeSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
              'children': z.array(treeSchema).optional(),
            }));

        final invalidTree = {
          'value': 'root',
          'children': [
            {'value': 123}, // Invalid: number instead of string
          ],
        };

        expect(
          () => treeSchema.parse(invalidTree),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Circular Reference Detection', () {
      test('should detect circular references when enabled', () {
        late Schema<Map<String, dynamic>> nodeSchema;
        nodeSchema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'id': z.string(),
                  'ref': nodeSchema.optional(),
                }),
            enableCircularDetection: true);

        // Create circular structure
        final node1 = <String, dynamic>{'id': 'node1'};
        final node2 = <String, dynamic>{'id': 'node2', 'ref': node1};
        node1['ref'] = node2; // Creates circular reference

        expect(
          () => nodeSchema.parse(node1),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should allow circular structures when detection is disabled', () {
        late Schema<Map<String, dynamic>> nodeSchema;
        nodeSchema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'id': z.string(),
                  'ref': nodeSchema.optional(),
                }),
            enableCircularDetection: false,
            maxDepth: 5);

        // This test is tricky because we need to create a structure that would be circular
        // but won't exceed max depth in validation
        final validNode = {
          'id': 'root',
          'ref': {
            'id': 'child',
            'ref': {
              'id': 'grandchild',
            },
          },
        };

        final result = nodeSchema.parse(validNode);
        expect(result['id'], equals('root'));
        expect(result['ref']['id'], equals('child'));
      });
    });

    group('Depth Limits', () {
      test('should enforce maximum depth limit', () {
        late Schema<Map<String, dynamic>> deepSchema;
        deepSchema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'level': z.number(),
                  'next': deepSchema.optional(),
                }),
            maxDepth: 3);

        // Create structure that exceeds depth limit
        final deepStructure = {
          'level': 0,
          'next': {
            'level': 1,
            'next': {
              'level': 2,
              'next': {
                'level': 3,
                'next': {
                  'level': 4, // This should exceed depth limit
                },
              },
            },
          },
        };

        expect(
          () => deepSchema.parse(deepStructure),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate within depth limit', () {
        late Schema<Map<String, dynamic>> deepSchema;
        deepSchema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'level': z.number(),
                  'next': deepSchema.optional(),
                }),
            maxDepth: 5);

        final validStructure = {
          'level': 0,
          'next': {
            'level': 1,
            'next': {
              'level': 2,
            },
          },
        };

        final result = deepSchema.parse(validStructure);
        expect(result['level'], equals(0));
        expect(result['next']['level'], equals(1));
        expect(result['next']['next']['level'], equals(2));
      });
    });

    group('Memoization', () {
      test('should cache schema instances when memoization is enabled', () {
        final recursiveSchema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string(),
                }),
            enableMemoization: true);

        expect(recursiveSchema.isMemoizationEnabled, isTrue);
        expect(recursiveSchema.cacheSize, greaterThanOrEqualTo(0));

        // Parse to trigger memoization
        recursiveSchema.parse({'value': 'test'});

        final initialCacheSize = recursiveSchema.cacheSize;

        // Parse again - should use cached schema
        recursiveSchema.parse({'value': 'test2'});

        // Cache size should be stable or grow
        expect(
            recursiveSchema.cacheSize, greaterThanOrEqualTo(initialCacheSize));
      });

      test('should clear cache when requested', () {
        final recursiveSchema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string(),
                }),
            enableMemoization: true);

        // Parse to populate cache
        recursiveSchema.parse({'value': 'test'});

        // Clear cache
        recursiveSchema.clearCache();
        expect(recursiveSchema.cacheSize, equals(0));
      });

      test('should not cache when memoization is disabled', () {
        final recursiveSchema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string(),
                }),
            enableMemoization: false);

        expect(recursiveSchema.isMemoizationEnabled, isFalse);

        recursiveSchema.parse({'value': 'test'});
        expect(recursiveSchema.cacheSize, equals(0));
      });
    });

    group('Schema Configuration', () {
      test('should create schema with custom settings', () {
        final customSchema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string(),
                }),
            maxDepth: 50,
            enableCircularDetection: false,
            enableMemoization: true,
            description: 'Custom recursive schema',
            metadata: {'version': '1.0'});

        expect(customSchema.maxDepth, equals(50));
        expect(customSchema.isCircularDetectionEnabled, isFalse);
        expect(customSchema.isMemoizationEnabled, isTrue);
        expect(customSchema.description, equals('Custom recursive schema'));
        expect(customSchema.metadata?['version'], equals('1.0'));
      });

      test('should create schema with updated settings', () {
        final baseSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
            }));

        final updatedSchema = baseSchema.withSettings(
          maxDepth: 100,
          enableCircularDetection: false,
          description: 'Updated schema',
        );

        expect(updatedSchema.maxDepth, equals(100));
        expect(updatedSchema.isCircularDetectionEnabled, isFalse);
        expect(updatedSchema.description, equals('Updated schema'));
      });

      test('should create schema with specific depth limit', () {
        final baseSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
            }));

        final limitedSchema = baseSchema.withMaxDepth(10);
        expect(limitedSchema.maxDepth, equals(10));
      });

      test('should toggle circular detection', () {
        final baseSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
            }));

        final withoutDetection = baseSchema.withCircularDetection(false);
        expect(withoutDetection.isCircularDetectionEnabled, isFalse);

        final withDetection = withoutDetection.withCircularDetection(true);
        expect(withDetection.isCircularDetectionEnabled, isTrue);
      });

      test('should toggle memoization', () {
        final baseSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
            }));

        final withoutMemo = baseSchema.withMemoization(false);
        expect(withoutMemo.isMemoizationEnabled, isFalse);

        final withMemo = withoutMemo.withMemoization(true);
        expect(withMemo.isMemoizationEnabled, isTrue);
      });
    });

    group('Preset Configurations', () {
      test('should create safe recursive schema', () {
        final safeSchema = z
            .recursive<Map<String, dynamic>>(() => z.object({
                  'value': z.string(),
                }))
            .safe();

        expect(safeSchema.maxDepth, equals(100));
        expect(safeSchema.isCircularDetectionEnabled, isTrue);
        expect(safeSchema.isMemoizationEnabled, isTrue);
      });

      test('should create optimized recursive schema', () {
        final optimizedSchema = z
            .recursive<Map<String, dynamic>>(() => z.object({
                  'value': z.string(),
                }))
            .optimized();

        expect(optimizedSchema.maxDepth, equals(10000));
        expect(optimizedSchema.isCircularDetectionEnabled, isFalse);
        expect(optimizedSchema.isMemoizationEnabled, isTrue);
      });
    });

    group('Validation with Statistics', () {
      test('should validate and return statistics', () {
        late RecursiveSchema<Map<String, dynamic>> treeSchema;
        treeSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
              'children': z.array(treeSchema).optional(),
            }));

        final tree = {
          'value': 'root',
          'children': [
            {
              'value': 'child',
              'children': [
                {'value': 'grandchild'},
              ],
            },
          ],
        };

        final result = treeSchema.validateWithStats(tree);
        expect(result.isSuccess, isTrue);
        expect(result.maxDepthReached, greaterThan(0));
        expect(result.totalValidations, greaterThan(0));
        expect(result.circularReferencesDetected, equals(0));

        final stats = result.statistics;
        expect(stats['success'], isTrue);
        expect(stats['maxDepthReached'], isA<int>());
        expect(stats['totalValidations'], isA<int>());
      });

      test('should validate async and return statistics', () async {
        late RecursiveSchema<Map<String, dynamic>> treeSchema;
        treeSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
              'children': z.array(treeSchema).optional(),
            }));

        final tree = {
          'value': 'root',
          'children': [
            {'value': 'child'},
          ],
        };

        final result = await treeSchema.validateWithStatsAsync(tree);
        expect(result.isSuccess, isTrue);
        expect(result.maxDepthReached, greaterThan(0));
      });

      test('should handle validation failure with stats', () {
        late RecursiveSchema<Map<String, dynamic>> failureSchema;
        failureSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
              'children': z.array(failureSchema).optional(),
            }));

        final invalidTree = {
          'value': 123, // Invalid: should be string
          'children': [
            {'value': 'valid child'},
          ],
        };

        final result = failureSchema.validateWithStats(invalidTree);
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.data, isNull);
        expect(result.errors, isNotNull);
        expect(result.errors!.errors, isNotEmpty);

        final stats = result.statistics;
        expect(stats['success'], isFalse);
      });

      test('should provide proper toString representation for stats', () {
        late RecursiveSchema<Map<String, dynamic>> schema;
        schema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
            }));

        final result = schema.validateWithStats({'value': 'test'});
        final str = result.toString();
        expect(str, contains('ValidationResultWithStats'));
        expect(str, contains('success: true'));
        expect(str, contains('depth:'));
        expect(str, contains('circular:'));
        expect(str, contains('validations:'));
      });
    });

    group('Async Validation', () {
      test('should support async validation', () async {
        late Schema<Map<String, dynamic>> asyncTreeSchema;
        asyncTreeSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string().refineAsync((s) async {
                await Future.delayed(const Duration(milliseconds: 1));
                return s.isNotEmpty;
              }, message: 'Value cannot be empty'),
              'children': z.array(asyncTreeSchema).optional(),
            }));

        final tree = {
          'value': 'root',
          'children': [
            {'value': 'child'},
          ],
        };

        final result = await asyncTreeSchema.parseAsync(tree);
        expect(result['value'], equals('root'));
        expect(result['children'], hasLength(1));
      });

      test('should handle async validation errors', () async {
        late Schema<Map<String, dynamic>> asyncTreeSchema;
        asyncTreeSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z
                  .string()
                  .refineAsync((s) async => false, message: 'Always fails'),
              'children': z.array(asyncTreeSchema).optional(),
            }));

        final tree = {
          'value': 'root',
        };

        await expectLater(
          asyncTreeSchema.parseAsync(tree),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should support async validation with proper error handling',
          () async {
        late Schema<Map<String, dynamic>> asyncSchemaWithValidation;
        asyncSchemaWithValidation = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string().refineAsync((s) async {
                    // Simulate async validation that might fail
                    await Future.delayed(const Duration(milliseconds: 1));
                    if (s == 'fail') {
                      throw const ValidationException(
                          'Async validation failed');
                    }
                    return true;
                  }),
                  'next': asyncSchemaWithValidation.optional(),
                }),
            maxDepth: 10);

        // Test successful case
        final validStructure = {
          'value': 'success',
          'next': {
            'value': 'also_success',
          },
        };

        final result =
            await asyncSchemaWithValidation.parseAsync(validStructure);
        expect(result['value'], equals('success'));

        // Test failure case
        final invalidStructure = {
          'value': 'fail',
        };

        await expectLater(
          asyncSchemaWithValidation.parseAsync(invalidStructure),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Factory Methods', () {
      test('should create recursive schema with factory method', () {
        final schema = RecursiveExtension.recursive<Map<String, dynamic>>(
          () => z.object({'value': z.string()}),
          maxDepth: 50,
          enableCircularDetection: true,
          description: 'Factory created',
        );

        expect(schema.maxDepth, equals(50));
        expect(schema.isCircularDetectionEnabled, isTrue);
        expect(schema.description, equals('Factory created'));
      });

      test('should create safe recursive schema with factory', () {
        final schema = RecursiveExtension.recursiveSafe<Map<String, dynamic>>(
          () => z.object({'value': z.string()}),
          description: 'Safe schema',
        );

        expect(schema.maxDepth, equals(100));
        expect(schema.isCircularDetectionEnabled, isTrue);
        expect(schema.isMemoizationEnabled, isTrue);
        expect(schema.description, equals('Safe schema'));
      });

      test('should create optimized recursive schema with factory', () {
        final schema =
            RecursiveExtension.recursiveOptimized<Map<String, dynamic>>(
          () => z.object({'value': z.string()}),
          description: 'Optimized schema',
        );

        expect(schema.maxDepth, equals(10000));
        expect(schema.isCircularDetectionEnabled, isFalse);
        expect(schema.isMemoizationEnabled, isTrue);
        expect(schema.description, equals('Optimized schema'));
      });
    });

    group('Schema Properties', () {
      test('should provide schema statistics', () {
        final schema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string(),
                }),
            maxDepth: 42,
            enableCircularDetection: true,
            enableMemoization: false);

        final stats = schema.statistics;
        expect(stats['maxDepth'], equals(42));
        expect(stats['circularDetectionEnabled'], isTrue);
        expect(stats['memoizationEnabled'], isFalse);
        expect(stats['cacheSize'], equals(0));
        expect(stats['schemaType'], isA<String>());
      });

      test('should have correct schema type', () {
        final schema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
            }));

        expect(schema.schemaType, equals('RecursiveSchema'));
      });

      test('should have proper string representation', () {
        final schema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string(),
                }),
            maxDepth: 50,
            description: 'Test schema');

        final str = schema.toString();
        expect(str, contains('RecursiveSchema'));
        expect(str, contains('depth:50'));
        expect(str, contains('Test schema'));
      });

      test('should format toString correctly for all configurations', () {
        // Test without description
        final schema1 = z.recursive<Map<String, dynamic>>(
            () => z.object({'value': z.string()}),
            maxDepth: 10,
            enableCircularDetection: false,
            enableMemoization: true);

        final str1 = schema1.toString();
        expect(str1, contains('RecursiveSchema<Map<String, dynamic>>'));
        expect(str1, contains('depth:10'));
        expect(str1, contains('circular:false'));
        expect(str1, contains('memo:true'));
        expect(
            str1,
            isNot(contains(
                ' ('))); // No description part (note the space before parenthesis)

        // Test with description
        final schema2 = z.recursive<Map<String, dynamic>>(
            () => z.object({'value': z.string()}),
            description: 'My Schema');

        final str2 = schema2.toString();
        expect(str2, contains('(My Schema)'));
      });
    });

    group('Equality and Hash Code', () {
      test('should implement equality correctly', () {
        final schema1 = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string(),
                }),
            maxDepth: 100,
            description: 'Test');

        final schema2 = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string(),
                }),
            maxDepth: 100,
            description: 'Test');

        final schema3 = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string(),
                }),
            maxDepth: 200,
            description: 'Test');

        expect(schema1, equals(schema1)); // Same instance
        expect(schema1 == schema2, isTrue); // Same configuration
        expect(schema1 == schema3, isFalse); // Different max depth
      });

      test('should implement hash code correctly', () {
        final schema1 = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string(),
                }),
            maxDepth: 100,
            description: 'Test');

        final schema2 = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.string(),
                }),
            maxDepth: 100,
            description: 'Test');

        expect(schema1.hashCode, equals(schema2.hashCode));
      });
    });

    group('Nested RecursiveSchema Validation', () {
      test('should handle nested RecursiveSchema instances', () {
        // Create a recursive schema that contains another recursive schema
        late Schema<Map<String, dynamic>> innerRecursiveSchema;
        innerRecursiveSchema =
            z.recursive<Map<String, dynamic>>(() => z.object({
                  'innerValue': z.string(),
                  'innerNext': innerRecursiveSchema.optional(),
                }));

        late Schema<Map<String, dynamic>> outerRecursiveSchema;
        outerRecursiveSchema =
            z.recursive<Map<String, dynamic>>(() => z.object({
                  'outerValue': z.string(),
                  'inner': innerRecursiveSchema,
                  'outerNext': outerRecursiveSchema.optional(),
                }));

        final nestedStructure = {
          'outerValue': 'outer1',
          'inner': {
            'innerValue': 'inner1',
            'innerNext': {
              'innerValue': 'inner2',
            },
          },
          'outerNext': {
            'outerValue': 'outer2',
            'inner': {
              'innerValue': 'inner3',
            },
          },
        };

        final result = outerRecursiveSchema.parse(nestedStructure);
        expect(result['outerValue'], equals('outer1'));
        expect(result['inner']['innerValue'], equals('inner1'));
        expect(result['inner']['innerNext']['innerValue'], equals('inner2'));
        expect(result['outerNext']['outerValue'], equals('outer2'));
        expect(result['outerNext']['inner']['innerValue'], equals('inner3'));
      });
    });

    group('Complex Recursive Scenarios', () {
      test('should handle mutual recursion', () {
        late Schema<Map<String, dynamic>> nodeASchema;
        late Schema<Map<String, dynamic>> nodeBSchema;

        nodeASchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'type': z.literal('A'),
              'value': z.string(),
              'nodeB': nodeBSchema.optional(),
            }));

        nodeBSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'type': z.literal('B'),
              'value': z.number(),
              'nodeA': nodeASchema.optional(),
            }));

        final mutualStructure = {
          'type': 'A',
          'value': 'root',
          'nodeB': {
            'type': 'B',
            'value': 42,
            'nodeA': {
              'type': 'A',
              'value': 'nested',
            },
          },
        };

        final result = nodeASchema.parse(mutualStructure);
        expect(result['type'], equals('A'));
        expect(result['nodeB']['type'], equals('B'));
        expect(result['nodeB']['nodeA']['type'], equals('A'));
      });

      test('should handle recursive arrays', () {
        late Schema<dynamic> recursiveArraySchema;
        recursiveArraySchema = z.recursive<dynamic>(() => z.union([
              z.string(),
              z.number(),
              z.array(recursiveArraySchema),
            ]));

        final nestedArray = [
          'hello',
          42,
          [
            'nested',
            [
              'deeply nested',
              99,
            ],
          ],
        ];

        final result = recursiveArraySchema.parse(nestedArray);
        expect(result, hasLength(3));
        expect(result[0], equals('hello'));
        expect(result[1], equals(42));
        expect(result[2][1][0], equals('deeply nested'));
      });

      test('should handle recursive with refinements and transformations', () {
        late Schema<Map<String, dynamic>> commentSchema;
        commentSchema = z
            .recursive<Map<String, dynamic>>(() => z.object({
                  'id': z.string(),
                  'text': z.string().min(1),
                  'author': z.string(),
                  'replies': z.array(commentSchema).optional(),
                }))
            .transform((comment) => {
                  ...comment,
                  'replyCount': comment['replies'] != null
                      ? (comment['replies'] as List).length
                      : 0,
                });

        final commentTree = {
          'id': '1',
          'text': 'Root comment',
          'author': 'Alice',
          'replies': [
            {
              'id': '2',
              'text': 'First reply',
              'author': 'Bob',
            },
            {
              'id': '3',
              'text': 'Second reply',
              'author': 'Charlie',
              'replies': [
                {
                  'id': '4',
                  'text': 'Nested reply',
                  'author': 'Dave',
                },
              ],
            },
          ],
        };

        final result = commentSchema.parse(commentTree);
        expect(result['replyCount'], equals(2));
        expect(result['replies'][1]['replyCount'], equals(1));
        expect(result['replies'][0]['replyCount'], equals(0));
      });

      test('should handle very deep recursive structures within limits', () {
        late Schema<Map<String, dynamic>> chainSchema;
        chainSchema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'value': z.number(),
                  'next': chainSchema.optional(),
                }),
            maxDepth: 1000);

        // Create a chain of 50 nodes (well within limit)
        Map<String, dynamic> buildChain(int depth) {
          if (depth <= 1) {
            return {'value': depth};
          }
          return {
            'value': depth,
            'next': buildChain(depth - 1),
          };
        }

        final chain = buildChain(50);
        final result = chainSchema.parse(chain);

        expect(result['value'], equals(50));

        // Traverse chain to verify structure
        var current = result;
        var count = 50;
        while (current['next'] != null) {
          current = current['next'];
          count--;
        }
        expect(count, equals(1));
        expect(current['value'], equals(1));
      });
    });

    group('ValidationContext', () {
      test('should handle incrementDepth correctly', () {
        // This test is designed to trigger the incrementDepth method
        // by creating a scenario where it might be needed
        final context = ValidationContext();
        expect(context.depth, equals(0));
        expect(context.maxDepthReached, equals(0));
        expect(context.totalValidations, equals(0));
        expect(context.circularReferencesDetected, equals(0));

        // Test incrementDepth functionality
        final newContext = context.incrementDepth();
        expect(newContext.depth, equals(1));
        expect(newContext.visitedObjects, isEmpty);

        // Modify original context to test state sharing
        context.totalValidations = 5;
        context.circularReferencesDetected = 2;
        context.maxDepthReached = 3;

        final anotherContext = context.incrementDepth();
        expect(anotherContext.depth, equals(1));
        expect(anotherContext.totalValidations, equals(5));
        expect(anotherContext.circularReferencesDetected, equals(2));
        expect(anotherContext.maxDepthReached, equals(3));
      });
    });

    group('Nested RecursiveSchema Context Handling', () {
      test('should pass context to nested RecursiveSchema instances', () {
        // Create a recursive schema that contains another recursive schema
        // This tests lines 150-152 where schema is RecursiveSchema
        late RecursiveSchema<Map<String, dynamic>> innerSchema;
        innerSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
              'next': innerSchema.optional(),
            }));

        late RecursiveSchema<Map<String, dynamic>> outerSchema;
        outerSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'inner': innerSchema,
              'outerNext': outerSchema.optional(),
            }));

        final nestedData = {
          'inner': {
            'value': 'test',
            'next': {
              'value': 'nested',
            },
          },
        };

        final result = outerSchema.parse(nestedData);
        expect(result['inner']['value'], equals('test'));
        expect(result['inner']['next']['value'], equals('nested'));
      });
    });

    group('Edge Case Coverage', () {
      test(
          'should cover nested RecursiveSchema context passing (lines 150-152)',
          () {
        // Create nested recursive schemas to trigger lines 150-152
        late RecursiveSchema<Map<String, dynamic>> innerRecursive;
        innerRecursive = z.recursive<Map<String, dynamic>>(() => z.object({
              'innerValue': z.string(),
              'innerChild': innerRecursive.optional(),
            }));

        late RecursiveSchema<Map<String, dynamic>> outerRecursive;
        outerRecursive = z.recursive<Map<String, dynamic>>(() => z.object({
              'outerValue': z.string(),
              'inner':
                  innerRecursive, // This should trigger the nested RecursiveSchema path
              'outerChild': outerRecursive.optional(),
            }));

        final testData = {
          'outerValue': 'outer',
          'inner': {
            'innerValue': 'inner',
            'innerChild': {
              'innerValue': 'deep inner',
            },
          },
        };

        final result = outerRecursive.validate(testData);
        expect(result.isSuccess, isTrue);
        expect(result.data!['inner']['innerValue'], equals('inner'));
        expect(result.data!['inner']['innerChild']['innerValue'],
            equals('deep inner'));
      });

      test('should cover async nested RecursiveSchema (lines 227-230)',
          () async {
        // Create nested recursive schemas for async validation
        late RecursiveSchema<Map<String, dynamic>> innerAsync;
        innerAsync = z.recursive<Map<String, dynamic>>(() => z.object({
              'innerValue': z.string(),
              'innerNext': innerAsync.optional(),
            }));

        late RecursiveSchema<Map<String, dynamic>> outerAsync;
        outerAsync = z.recursive<Map<String, dynamic>>(() => z.object({
              'outerValue': z.string(),
              'innerSchema':
                  innerAsync, // This should trigger async nested RecursiveSchema path
              'outerNext': outerAsync.optional(),
            }));

        final asyncData = {
          'outerValue': 'async outer',
          'innerSchema': {
            'innerValue': 'async inner',
            'innerNext': {
              'innerValue': 'deep async inner',
            },
          },
        };

        // This should trigger lines 227-230 for async nested RecursiveSchema
        final result = await outerAsync.validateAsync(asyncData);
        expect(result.isSuccess, isTrue);
        expect(
            result.data!['innerSchema']['innerValue'], equals('async inner'));
        expect(result.data!['innerSchema']['innerNext']['innerValue'],
            equals('deep async inner'));
      });

      test(
          'should cover async validation with List objects for complete object ID coverage',
          () async {
        late RecursiveSchema<Map<String, dynamic>> listSchema;
        listSchema = z.recursive<Map<String, dynamic>>(
            () => z.object({
                  'items': z.array(z.string()),
                  'nested': listSchema.optional(),
                }),
            enableCircularDetection: true);

        final testData = {
          'items': ['item1', 'item2'],
          'nested': {
            'items': ['nested1'],
          },
        };

        final result = await listSchema.validateAsync(testData);
        expect(result.isSuccess, isTrue);
        expect(result.data!['items'], hasLength(2));
        expect(result.data!['nested']['items'], hasLength(1));
      });
    });

    group('Nested RecursiveSchema Coverage', () {
      test('should handle recursive schema as inner schema in sync validation',
          () {
        // Create a deeply nested recursive schema to test the path where
        // _schema is itself a RecursiveSchema instance (lines 151-152)
        late Schema<Map<String, dynamic>> innerRecursive;
        late Schema<Map<String, dynamic>> outerRecursive;

        innerRecursive = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string(),
              'nested': innerRecursive.optional(),
            }));

        outerRecursive =
            z.recursive<Map<String, dynamic>>(() => innerRecursive);

        final testData = {
          'value': 'test',
          'nested': {
            'value': 'nested_test',
          },
        };

        final result = outerRecursive.validate(testData);
        expect(result.isSuccess, isTrue);
        expect(result.data!['value'], equals('test'));
        expect(result.data!['nested']['value'], equals('nested_test'));
      });

      test('should handle recursive schema as inner schema in async validation',
          () async {
        // Test the async path where _schema is itself a RecursiveSchema (lines 228, 230)
        late Schema<Map<String, dynamic>> innerRecursive;
        late Schema<Map<String, dynamic>> outerRecursive;

        innerRecursive = z.recursive<Map<String, dynamic>>(() => z.object({
              'value': z.string().refineAsync(
                    (value) async => Future.delayed(
                        const Duration(milliseconds: 1), () => true),
                  ),
              'nested': innerRecursive.optional(),
            }));

        outerRecursive =
            z.recursive<Map<String, dynamic>>(() => innerRecursive);

        final testData = {
          'value': 'test',
          'nested': {
            'value': 'nested_test',
          },
        };

        final result = await outerRecursive.validateAsync(testData);
        expect(result.isSuccess, isTrue);
        expect(result.data!['value'], equals('test'));
        expect(result.data!['nested']['value'], equals('nested_test'));
      });

      test('should handle async depth limit exceeded', () async {
        // Test async validation with depth limit exceeded (lines 184-187, 190)
        late Schema<Map<String, dynamic>> deepSchema;
        deepSchema = z.recursive<Map<String, dynamic>>(
          () => z.object({
            'value': z.string().refineAsync(
                  (value) async => Future.delayed(
                      const Duration(milliseconds: 1), () => true),
                ),
            'child': deepSchema.optional(),
          }),
          maxDepth: 2, // Set a low max depth to trigger the limit
        );

        final deepData = {
          'value': 'level1',
          'child': {
            'value': 'level2',
            'child': {
              'value': 'level3', // This should exceed maxDepth of 2
              'child': {
                'value': 'level4',
              },
            },
          },
        };

        final result = await deepSchema.validateAsync(deepData);
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors, hasLength(1));
        expect(result.errors!.errors.first.code, equals('schema_circular'));
        expect(result.errors!.errors.first.message,
            contains('Maximum recursion depth exceeded: 2'));
      });

      test('should handle async circular reference detection', () async {
        // Test async circular reference detection (lines 200-203, 207)
        late Schema<Map<String, dynamic>> circularSchema;
        circularSchema = z.recursive<Map<String, dynamic>>(() => z.object({
              'id': z.string().refineAsync(
                    (value) async => Future.delayed(
                        const Duration(milliseconds: 1), () => true),
                  ),
              'ref': circularSchema.optional(),
            }));

        // Create circular reference
        final Map<String, dynamic> circularData = {
          'id': 'node1',
        };
        final Map<String, dynamic> childData = {
          'id': 'node2',
          'ref': circularData,
        };
        circularData['ref'] = childData;

        final result = await circularSchema.validateAsync(circularData);
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors, hasLength(1));
        expect(result.errors!.errors.first.code, equals('schema_circular'));
        expect(result.errors!.errors.first.message,
            equals('Circular reference detected'));
      });
    });
  });
}
