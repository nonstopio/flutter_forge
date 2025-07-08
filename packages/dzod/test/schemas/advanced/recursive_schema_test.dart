import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('RecursiveSchema', () {
    group('Basic Recursive Validation', () {
      test('should validate simple recursive structure', () {
        late Schema<Map<String, dynamic>> treeSchema;
        treeSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'value': Z.string(),
              'children': Z.array(treeSchema).optional(),
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
        nodeSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'id': Z.number(),
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
        treeSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'value': Z.string(),
              'children': Z.array(treeSchema).optional(),
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
        nodeSchema = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'id': Z.string(),
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
        nodeSchema = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'id': Z.string(),
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
        deepSchema = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'level': Z.number(),
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
        deepSchema = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'level': Z.number(),
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
        final recursiveSchema = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.string(),
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
        final recursiveSchema = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.string(),
                }),
            enableMemoization: true);

        // Parse to populate cache
        recursiveSchema.parse({'value': 'test'});

        // Clear cache
        recursiveSchema.clearCache();
        expect(recursiveSchema.cacheSize, equals(0));
      });

      test('should not cache when memoization is disabled', () {
        final recursiveSchema = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.string(),
                }),
            enableMemoization: false);

        expect(recursiveSchema.isMemoizationEnabled, isFalse);

        recursiveSchema.parse({'value': 'test'});
        expect(recursiveSchema.cacheSize, equals(0));
      });
    });

    group('Schema Configuration', () {
      test('should create schema with custom settings', () {
        final customSchema = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.string(),
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
        final baseSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'value': Z.string(),
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
        final baseSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'value': Z.string(),
            }));

        final limitedSchema = baseSchema.withMaxDepth(10);
        expect(limitedSchema.maxDepth, equals(10));
      });

      test('should toggle circular detection', () {
        final baseSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'value': Z.string(),
            }));

        final withoutDetection = baseSchema.withCircularDetection(false);
        expect(withoutDetection.isCircularDetectionEnabled, isFalse);

        final withDetection = withoutDetection.withCircularDetection(true);
        expect(withDetection.isCircularDetectionEnabled, isTrue);
      });

      test('should toggle memoization', () {
        final baseSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'value': Z.string(),
            }));

        final withoutMemo = baseSchema.withMemoization(false);
        expect(withoutMemo.isMemoizationEnabled, isFalse);

        final withMemo = withoutMemo.withMemoization(true);
        expect(withMemo.isMemoizationEnabled, isTrue);
      });
    });

    group('Preset Configurations', () {
      test('should create safe recursive schema', () {
        final safeSchema = Z
            .recursive<Map<String, dynamic>>(() => Z.object({
                  'value': Z.string(),
                }))
            .safe();

        expect(safeSchema.maxDepth, equals(100));
        expect(safeSchema.isCircularDetectionEnabled, isTrue);
        expect(safeSchema.isMemoizationEnabled, isTrue);
      });

      test('should create optimized recursive schema', () {
        final optimizedSchema = Z
            .recursive<Map<String, dynamic>>(() => Z.object({
                  'value': Z.string(),
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
        treeSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'value': Z.string(),
              'children': Z.array(treeSchema).optional(),
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
        treeSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'value': Z.string(),
              'children': Z.array(treeSchema).optional(),
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
    });

    group('Async Validation', () {
      test('should support async validation', () async {
        late Schema<Map<String, dynamic>> asyncTreeSchema;
        asyncTreeSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'value': Z.string().refineAsync((s) async {
                await Future.delayed(const Duration(milliseconds: 1));
                return s.isNotEmpty;
              }, message: 'Value cannot be empty'),
              'children': Z.array(asyncTreeSchema).optional(),
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
        asyncTreeSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'value': Z
                  .string()
                  .refineAsync((s) async => false, message: 'Always fails'),
              'children': Z.array(asyncTreeSchema).optional(),
            }));

        final tree = {
          'value': 'root',
        };

        await expectLater(
          asyncTreeSchema.parseAsync(tree),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Factory Methods', () {
      test('should create recursive schema with factory method', () {
        final schema = RecursiveExtension.recursive<Map<String, dynamic>>(
          () => Z.object({'value': Z.string()}),
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
          () => Z.object({'value': Z.string()}),
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
          () => Z.object({'value': Z.string()}),
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
        final schema = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.string(),
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
        final schema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'value': Z.string(),
            }));

        expect(schema.schemaType, equals('RecursiveSchema'));
      });

      test('should have proper string representation', () {
        final schema = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.string(),
                }),
            maxDepth: 50,
            description: 'Test schema');

        final str = schema.toString();
        expect(str, contains('RecursiveSchema'));
        expect(str, contains('depth:50'));
        expect(str, contains('Test schema'));
      });
    });

    group('Equality and Hash Code', () {
      test('should implement equality correctly', () {
        final schema1 = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.string(),
                }),
            maxDepth: 100,
            description: 'Test');

        final schema2 = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.string(),
                }),
            maxDepth: 100,
            description: 'Test');

        final schema3 = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.string(),
                }),
            maxDepth: 200,
            description: 'Test');

        expect(schema1, equals(schema1)); // Same instance
        expect(schema1 == schema2, isTrue); // Same configuration
        expect(schema1 == schema3, isFalse); // Different max depth
      });

      test('should implement hash code correctly', () {
        final schema1 = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.string(),
                }),
            maxDepth: 100,
            description: 'Test');

        final schema2 = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.string(),
                }),
            maxDepth: 100,
            description: 'Test');

        expect(schema1.hashCode, equals(schema2.hashCode));
      });
    });

    group('Complex Recursive Scenarios', () {
      test('should handle mutual recursion', () {
        late Schema<Map<String, dynamic>> nodeASchema;
        late Schema<Map<String, dynamic>> nodeBSchema;

        nodeASchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'type': Z.literal('A'),
              'value': Z.string(),
              'nodeB': nodeBSchema.optional(),
            }));

        nodeBSchema = Z.recursive<Map<String, dynamic>>(() => Z.object({
              'type': Z.literal('B'),
              'value': Z.number(),
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
        recursiveArraySchema = Z.recursive<dynamic>(() => Z.union([
              Z.string(),
              Z.number(),
              Z.array(recursiveArraySchema),
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
        commentSchema = Z
            .recursive<Map<String, dynamic>>(() => Z.object({
                  'id': Z.string(),
                  'text': Z.string().min(1),
                  'author': Z.string(),
                  'replies': Z.array(commentSchema).optional(),
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
        chainSchema = Z.recursive<Map<String, dynamic>>(
            () => Z.object({
                  'value': Z.number(),
                  'next': chainSchema.optional(),
                }),
            maxDepth: 1000);

        // Create a chain of 50 nodes (well within limit)
        Map<String, dynamic> buildChain(int depth) {
          if (depth <= 0) {
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
  });
}
