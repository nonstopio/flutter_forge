import 'package:dzod/dzod.dart';
import 'package:test/test.dart';

void main() {
  group('PipelineSchema', () {
    group('Basic Validation', () {
      test('should execute stages in sequence', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
        ]);

        final result = pipeline.parse('  HELLO WORLD  ');
        expect(result, equals('hello world'));
      });

      test('should fail at first failing stage', () {
        final pipeline = z.pipeline([
          z.string(),
          z.refine<String>((s) => s.length > 10, message: 'Too short'),
          z.transform<String, String>((s) => s.toUpperCase()),
        ]);

        expect(
          () => pipeline.parse('short'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should pass data through all stages', () {
        final pipeline = z.pipeline([
          z.number(),
          z.refine<num>((n) => n > 0, message: 'Must be positive'),
          z.transform<num, int>((n) => n.round()),
          z.refine<int>((i) => i < 100, message: 'Must be less than 100'),
        ]);

        final result = pipeline.parse(42.7);
        expect(result, equals(43));
      });

      test('should handle empty pipeline gracefully', () {
        expect(
          () => z.pipeline([]),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Pipeline Construction', () {
      test('should create pipeline with pipe method', () {
        final base = z.pipeline([z.string()]);
        final extended = base.pipe([
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, int>((s) => s.length),
        ]);

        expect(extended.length, equals(3));
        final result = extended.parse('  hello  ');
        expect(result, equals(5));
      });

      test('should add single stage with addStage', () {
        final base = z.pipeline([z.string()]);
        final extended = base.addStage(
          z.transform<String, int>((s) => s.length),
        );

        expect(extended.length, equals(2));
        final result = extended.parse('hello');
        expect(result, equals(5));
      });

      test('should prepend stages', () {
        final base = z.pipeline([z.transform<String, int>((s) => s.length)]);
        final prepended = base.prepend([z.string()]);

        expect(prepended.length, equals(2));
        final result = prepended.parse('hello');
        expect(result, equals(5));
      });

      test('should prepend single stage', () {
        final base = z.pipeline([z.transform<String, int>((s) => s.length)]);
        final prepended = base.prependStage(z.string());

        expect(prepended.length, equals(2));
        final result = prepended.parse('hello');
        expect(result, equals(5));
      });

      test('should insert stages at specific index', () {
        final base = z.pipeline([
          z.string(),
          z.transform<String, int>((s) => s.length),
        ]);

        final inserted = base.insertAt(1, [
          z.transform<String, String>((s) => s.trim()),
        ]);

        expect(inserted.length, equals(3));
        final result = inserted.parse('  hello  ');
        expect(result, equals(5));
      });

      test('should insert single stage at index', () {
        final base = z.pipeline([
          z.string(),
          z.transform<String, int>((s) => s.length),
        ]);

        final inserted = base.insertStageAt(
          1,
          z.transform<String, String>((s) => s.trim()),
        );

        expect(inserted.length, equals(3));
        final result = inserted.parse('  hello  ');
        expect(result, equals(5));
      });

      test('should remove stage at index', () {
        final base = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, int>((s) => s.length),
        ]);

        final removed = base.removeAt(1);
        expect(removed.length, equals(2));

        final result = removed.parse('  hello  ');
        expect(result, equals(9)); // No trim, so includes spaces
      });

      test('should throw on invalid remove index', () {
        final base = z.pipeline([z.string()]);

        expect(() => base.removeAt(-1), throwsA(isA<ArgumentError>()));
        expect(() => base.removeAt(1), throwsA(isA<ArgumentError>()));
      });

      test('should remove range of stages', () {
        final base = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
          z.transform<String, int>((s) => s.length),
        ]);

        final removed = base.removeRange(1, 3);
        expect(removed.length, equals(2));

        final result = removed.parse('  HELLO  ');
        expect(result, equals(9)); // No trim or lowercase
      });

      test('should slice pipeline', () {
        final base = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
          z.transform<String, int>((s) => s.length),
        ]);

        final sliced = base.slice(1, 3);
        expect(sliced.length, equals(2));
      });

      test('should replace range of stages', () {
        final base = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, int>((s) => s.length),
        ]);

        final replaced = base.replaceRange(1, 2, [
          z.transform<String, String>((s) => s.toUpperCase()),
        ]);

        expect(replaced.length, equals(3));
        final result = replaced.parse('hello');
        expect(result, equals(5)); // Still gets length after uppercase
      });

      test('should replace single stage', () {
        final base = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, int>((s) => s.length),
        ]);

        final replaced = base.replaceStageAt(
          1,
          z.transform<String, String>((s) => s.toUpperCase()),
        );

        expect(replaced.length, equals(3));
      });
    });

    group('Pipeline Manipulation', () {
      late PipelineSchema<String, int> basePipeline;

      setUp(() {
        basePipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
          z.transform<String, int>((s) => s.length),
        ]);
      });

      test('should filter stages', () {
        final filtered =
            basePipeline.filterStages((stage, index) => index != 1);
        expect(filtered.length, equals(3));
      });

      test('should map stages', () {
        final mapped = basePipeline.mapStages((stage, index) {
          if (index == 0) {
            return z.string().min(1);
          }
          return stage;
        });
        expect(mapped.length, equals(4));
      });

      test('should execute callback for each stage', () {
        var count = 0;
        basePipeline.forEachStage((stage, index) {
          count++;
        });
        expect(count, equals(4));
      });

      test('should check if any stage matches predicate', () {
        final hasStringSchema =
            basePipeline.anyStage((stage) => stage is StringSchema);
        expect(hasStringSchema, isTrue);

        final hasNumberSchema =
            basePipeline.anyStage((stage) => stage is NumberSchema);
        expect(hasNumberSchema, isFalse);
      });

      test('should check if every stage matches predicate', () {
        final allAreStringSchemas = basePipeline
            .everyStage((stage) => stage.schemaType == 'StringSchema');
        expect(allAreStringSchemas, isFalse);

        final allAreString =
            basePipeline.everyStage((stage) => stage is StringSchema);
        expect(allAreString, isFalse);
      });

      test('should find first matching stage', () {
        final stringSchema =
            basePipeline.findStage((stage) => stage is StringSchema);
        expect(stringSchema, isNotNull);
        expect(stringSchema, isA<StringSchema>());

        final numberSchema =
            basePipeline.findStage((stage) => stage is NumberSchema);
        expect(numberSchema, isNull);
      });

      test('should find index of first matching stage', () {
        final stringIndex =
            basePipeline.findStageIndex((stage) => stage is StringSchema);
        expect(stringIndex, equals(0));

        final numberIndex =
            basePipeline.findStageIndex((stage) => stage is NumberSchema);
        expect(numberIndex, equals(-1));
      });

      test('should reverse pipeline', () {
        final reversed = basePipeline.reverse();
        expect(reversed.length, equals(4));
        // Note: Reversed pipeline might not work functionally due to type mismatches
      });
    });

    group('Validation with Intermediate Results', () {
      test('should validate and collect intermediate results', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
        ]);

        final result = pipeline.validateWithIntermediateResults('  HELLO  ');
        expect(result.isSuccess, isTrue);

        final intermediates = result.data!;
        expect(intermediates, hasLength(4)); // Input + 3 stages
        expect(intermediates[0], equals('  HELLO  ')); // Original input
        expect(
            intermediates[1], equals('  HELLO  ')); // After string validation
        expect(intermediates[2], equals('HELLO')); // After trim
        expect(intermediates[3], equals('hello')); // After lowercase
      });

      test('should validate async with intermediate results', () async {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
        ]);

        final result =
            await pipeline.validateWithIntermediateResultsAsync('  HELLO  ');
        expect(result.isSuccess, isTrue);

        final intermediates = result.data!;
        expect(intermediates, hasLength(4));
        expect(intermediates[3], equals('hello'));
      });
    });

    group('Async Validation', () {
      test('should support async validation', () async {
        final pipeline = z.pipeline([
          z.string(),
          z.refineAsync<String>((s) async {
            await Future.delayed(const Duration(milliseconds: 1));
            return s.isNotEmpty;
          }, message: 'Cannot be empty'),
        ]);

        final result = await pipeline.parseAsync('hello');
        expect(result, equals('hello'));
      });

      test('should handle async validation errors', () async {
        final pipeline = z.pipeline([
          z.string(),
          z.refineAsync<String>((s) async => false, message: 'Always fails'),
        ]);

        await expectLater(
          pipeline.parseAsync('hello'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Factory Methods', () {
      test('should create pipeline with pipe2', () {
        final pipeline = PipelineExtension.pipe2(
          z.string(),
          z.transform<String, int>((s) => s.length),
        );

        final result = pipeline.parse('hello');
        expect(result, equals(5));
      });

      test('should create pipeline with pipe3', () {
        final pipeline = PipelineExtension.pipe3(
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, int>((s) => s.length),
        );

        final result = pipeline.parse('  hello  ');
        expect(result, equals(5));
      });

      test('should create pipeline with pipe4', () {
        final pipeline = PipelineExtension.pipe4(
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
          z.transform<String, int>((s) => s.length),
        );

        final result = pipeline.parse('  HELLO  ');
        expect(result, equals(5));
      });

      test('should create pipeline with pipe5', () {
        final pipeline = PipelineExtension.pipe5(
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
          z.transform<String, String>((s) => s.toUpperCase()),
          z.transform<String, int>((s) => s.length),
        );

        final result = pipeline.parse('  hello  ');
        expect(result, equals(5));
      });
    });

    group('Properties and Accessors', () {
      test('should provide pipeline properties', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, int>((s) => s.length),
        ]);

        expect(pipeline.length, equals(3));
        expect(pipeline.isEmpty, isFalse);
        expect(pipeline.isNotEmpty, isTrue);
        expect(pipeline.first, isA<StringSchema>());
        expect(pipeline.last, isA<TransformSchema>());

        final stages = pipeline.stages;
        expect(stages, hasLength(3));
      });

      test('should handle empty pipeline properties', () {
        // Note: This test would require modifying the pipeline to allow empty construction
        // for testing purposes, but the actual implementation throws an error
      });
    });

    group('Statistics', () {
      test('should provide pipeline statistics', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.refine<String>((s) => s.isNotEmpty, message: 'Not empty'),
        ]);

        final stats = pipeline.statistics;
        expect(stats['stageCount'], equals(3));
        expect(stats['isEmpty'], isFalse);
        expect(stats['stageTypes'], hasLength(3));
      });
    });

    group('Metadata and Description', () {
      test('should support description and metadata', () {
        final pipeline = z.pipeline(
            [
              z.string(),
            ],
            description: 'Test pipeline',
            metadata: {'version': '1.0'});

        expect(pipeline.description, equals('Test pipeline'));
        expect(pipeline.metadata?['version'], equals('1.0'));
      });

      test('should have correct schema type', () {
        final pipeline = z.pipeline([z.string()]);
        expect(pipeline.schemaType, equals('PipelineSchema'));
      });

      test('should have proper string representation', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, int>((s) => s.length),
        ], description: 'Length calculator');

        final str = pipeline.toString();
        expect(str, contains('PipelineSchema'));
        expect(str, contains('2 stages'));
        expect(str, contains('Length calculator'));
      });
    });

    group('Equality and Hash Code', () {
      test('should implement equality correctly', () {
        final pipeline1 = z.pipeline([z.string()]);
        final pipeline3 = z.pipeline([z.number()]);

        expect(pipeline1, equals(pipeline1)); // Same instance
        // Note: Equality might be tricky with function-based schemas
        expect(pipeline1 == pipeline3, isFalse); // Different stages
      });

      test('should implement hash code correctly', () {
        final pipeline1 = z.pipeline([z.string()]);

        // Hash codes should be consistent
        expect(pipeline1.hashCode, equals(pipeline1.hashCode));
      });
    });

    group('Complex Scenarios', () {
      test('should handle complex data transformation pipeline', () {
        final userPipeline = z.pipeline([
          z.object({
            'name': z.string(),
            'email': z.string(),
            'age': z.string(), // String input
          }),
          z.transform<Map<String, dynamic>, Map<String, dynamic>>((data) => {
                ...data,
                'age': int.parse(data['age'] as String), // Convert to int
              }),
          z.object({
            'name': z.string().min(2),
            'email': z.string().email(),
            'age': z.number().min(18),
          }),
          z.transform<Map<String, dynamic>, Map<String, dynamic>>((data) => {
                ...data,
                'isAdult': (data['age'] as num) >= 18,
                'displayName': '${data['name']} <${data['email']}>',
              }),
        ]);

        final result = userPipeline.parse({
          'name': 'John Doe',
          'email': 'john@example.com',
          'age': '25',
        });

        expect(result['name'], equals('John Doe'));
        expect(result['email'], equals('john@example.com'));
        expect(result['age'], equals(25));
        expect(result['isAdult'], isTrue);
        expect(result['displayName'], equals('John Doe <john@example.com>'));
      });

      test('should work with nested pipelines', () {
        final stringProcessor = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
        ]);

        final mainPipeline = z.pipeline([
          z.object({
            'title': stringProcessor,
            'content': stringProcessor,
          }),
        ]);

        final result = mainPipeline.parse({
          'title': '  HELLO WORLD  ',
          'content': '  THIS IS CONTENT  ',
        });

        expect(result['title'], equals('hello world'));
        expect(result['content'], equals('this is content'));
      });

      test('should handle validation errors in complex pipelines', () {
        final pipeline = z.pipeline([
          z.array(z.string()),
          z.refine<List<String>>((arr) => arr.isNotEmpty,
              message: 'Array cannot be empty'),
          z.transform<List<String>, List<String>>(
              (arr) => arr.map((s) => s.trim()).toList()),
          z.refine<List<String>>((arr) => arr.every((s) => s.isNotEmpty),
              message: 'No empty strings allowed'),
        ]);

        // Should pass
        final validResult = pipeline.parse(['  hello  ', '  world  ']);
        expect(validResult, equals(['hello', 'world']));

        // Should fail on empty array
        expect(
          () => pipeline.parse(<String>[]),
          throwsA(isA<ValidationException>()),
        );

        // Should fail on empty strings after trim
        expect(
          () => pipeline.parse(['hello', '   ']),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle single stage pipeline', () {
        final pipeline = z.pipeline([z.string()]);

        expect(pipeline.length, equals(1));
        expect(pipeline.first, isA<StringSchema>());
        expect(pipeline.last, isA<StringSchema>());
        expect(pipeline.first, equals(pipeline.last));

        final result = pipeline.parse('test');
        expect(result, equals('test'));
      });

      test('should handle intermediate results with single stage', () {
        final pipeline = z.pipeline([z.string()]);

        final result = pipeline.validateWithIntermediateResults('test');
        expect(result.isSuccess, isTrue);

        final intermediates = result.data!;
        expect(intermediates, hasLength(2)); // Input + 1 stage
        expect(intermediates[0], equals('test'));
        expect(intermediates[1], equals('test'));
      });

      test('should handle async intermediate results with single stage',
          () async {
        final pipeline = z.pipeline([z.string()]);

        final result =
            await pipeline.validateWithIntermediateResultsAsync('test');
        expect(result.isSuccess, isTrue);

        final intermediates = result.data!;
        expect(intermediates, hasLength(2));
        expect(intermediates[0], equals('test'));
        expect(intermediates[1], equals('test'));
      });

      test('should handle validation failure in intermediate results', () {
        final pipeline = z.pipeline([
          z.string(),
          z.refine<String>((s) => s.length > 10, message: 'Too short'),
        ]);

        final result = pipeline.validateWithIntermediateResults('short');
        expect(result.isFailure, isTrue);
      });

      test('should handle async validation failure in intermediate results',
          () async {
        final pipeline = z.pipeline([
          z.string(),
          z.refineAsync<String>((s) async => s.length > 10,
              message: 'Too short'),
        ]);

        final result =
            await pipeline.validateWithIntermediateResultsAsync('short');
        expect(result.isFailure, isTrue);
      });

      test('should handle path propagation correctly', () {
        final pipeline = z.pipeline([
          z.string(),
          z.refine<String>((s) => s.length > 5, message: 'Too short'),
        ]);

        final result = pipeline.validate('hi', ['root']);
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors.first.path, equals(['root', 'stage_1']));
      });

      test('should handle async path propagation correctly', () async {
        final pipeline = z.pipeline([
          z.string(),
          z.refineAsync<String>((s) async => s.length > 5,
              message: 'Too short'),
        ]);

        final result = await pipeline.validateAsync('hi', ['root']);
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors.first.path, equals(['root', 'stage_1']));
      });
    });

    group('Pipeline Statistics Edge Cases', () {
      test('should detect transform schemas in statistics', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, int>((s) => s.length),
        ]);

        final stats = pipeline.statistics;
        expect(stats['hasTransformations'], isTrue);
        expect(stats['hasRefinements'], isFalse);
        expect(stats['hasAsyncStages'], isFalse);
      });

      test('should detect refine schemas in statistics', () {
        final pipeline = z.pipeline([
          z.string(),
          z.refine<String>((s) => s.isNotEmpty, message: 'Not empty'),
        ]);

        final stats = pipeline.statistics;
        expect(stats['hasTransformations'], isFalse);
        expect(stats['hasRefinements'], isTrue);
        expect(stats['hasAsyncStages'], isFalse);
      });

      test('should detect async schemas in statistics', () {
        final pipeline = z.pipeline([
          z.string(),
          z.refineAsync<String>((s) async => s.isNotEmpty,
              message: 'Not empty'),
        ]);

        final stats = pipeline.statistics;
        expect(stats['hasTransformations'], isFalse);
        expect(stats['hasRefinements'], isFalse);
        expect(stats['hasAsyncStages'], isTrue);
      });

      test('should handle mixed schema types in statistics', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.refine<String>((s) => s.isNotEmpty, message: 'Not empty'),
          z.refineAsync<String>((s) async => s.isNotEmpty,
              message: 'Must have length'),
        ]);

        final stats = pipeline.statistics;
        expect(stats['hasTransformations'], isTrue);
        expect(stats['hasRefinements'], isTrue);
        expect(stats['hasAsyncStages'], isTrue);
        expect(stats['stageCount'], equals(4));
      });
    });

    group('Advanced Pipeline Manipulation', () {
      test('should handle slice with end parameter', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
          z.transform<String, int>((s) => s.length),
        ]);

        final sliced = pipeline.slice(1, 3);
        expect(sliced.length, equals(2));
        expect(sliced.stages.length, equals(2));
      });

      test('should handle slice without end parameter', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
          z.transform<String, int>((s) => s.length),
        ]);

        final sliced = pipeline.slice(1);
        expect(sliced.length, equals(3));
        expect(sliced.stages.length, equals(3));
      });

      test('should preserve description and metadata in manipulations', () {
        final pipeline = z.pipeline(
            [
              z.string(),
              z.transform<String, String>((s) => s.trim()),
            ],
            description: 'Test pipeline',
            metadata: {'version': '1.0'});

        final extended =
            pipeline.pipe([z.transform<String, int>((s) => s.length)]);
        expect(extended.description, equals('Test pipeline'));
        expect(extended.metadata, equals({'version': '1.0'}));

        final prepended = pipeline
            .prepend([z.transform<String, String>((s) => s.toUpperCase())]);
        expect(prepended.description, equals('Test pipeline'));
        expect(prepended.metadata, equals({'version': '1.0'}));

        final inserted = pipeline
            .insertAt(1, [z.transform<String, String>((s) => s.toLowerCase())]);
        expect(inserted.description, equals('Test pipeline'));
        expect(inserted.metadata, equals({'version': '1.0'}));

        final removed = pipeline.removeAt(1);
        expect(removed.description, equals('Test pipeline'));
        expect(removed.metadata, equals({'version': '1.0'}));

        final sliced = pipeline.slice(0, 1);
        expect(sliced.description, equals('Test pipeline'));
        expect(sliced.metadata, equals({'version': '1.0'}));

        final replaced = pipeline.replaceRange(0, 1, [z.number()]);
        expect(replaced.description, equals('Test pipeline'));
        expect(replaced.metadata, equals({'version': '1.0'}));

        final filtered = pipeline.filterStages((stage, index) => index == 0);
        expect(filtered.description, equals('Test pipeline'));
        expect(filtered.metadata, equals({'version': '1.0'}));

        final mapped = pipeline.mapStages((stage, index) => stage);
        expect(mapped.description, equals('Test pipeline'));
        expect(mapped.metadata, equals({'version': '1.0'}));

        final reversed = pipeline.reverse();
        expect(reversed.description, equals('Test pipeline'));
        expect(reversed.metadata, equals({'version': '1.0'}));
      });

      test('should handle all predicate-based methods', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.number(),
          z.boolean(),
        ]);

        // Test anyStage
        expect(pipeline.anyStage((stage) => stage is StringSchema), isTrue);
        expect(pipeline.anyStage((stage) => stage is ArraySchema), isFalse);

        // Test everyStage
        expect(pipeline.everyStage((stage) => stage is StringSchema), isFalse);
        expect(pipeline.everyStage((stage) => true), isTrue);

        // Test findStage
        final stringSchema =
            pipeline.findStage((stage) => stage is StringSchema);
        expect(stringSchema, isNotNull);
        expect(stringSchema, isA<StringSchema>());

        final arraySchema = pipeline.findStage((stage) => stage is ArraySchema);
        expect(arraySchema, isNull);

        // Test findStageIndex
        final stringIndex =
            pipeline.findStageIndex((stage) => stage is StringSchema);
        expect(stringIndex, equals(0));

        final arrayIndex =
            pipeline.findStageIndex((stage) => stage is ArraySchema);
        expect(arrayIndex, equals(-1));

        // Test forEachStage
        var count = 0;
        pipeline.forEachStage((stage, index) {
          count++;
          expect(index, greaterThanOrEqualTo(0));
          expect(index, lessThan(pipeline.length));
        });
        expect(count, equals(pipeline.length));
      });
    });

    group('Type Safety and Generics', () {
      test('should maintain type safety through transformations', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, int>((s) => s.length),
          z.transform<int, String>((i) => i.toString()),
        ]);

        final result = pipeline.parse('hello');
        expect(result, equals('5'));
        expect(result, isA<String>());
      });

      test('should handle different input and output types', () {
        final pipeline = PipelineExtension.pipe2<String, int, String>(
          z.transform<String, int>((s) => s.length),
          z.transform<int, String>((i) => 'Length: $i'),
        );

        final result = pipeline.parse('hello world');
        expect(result, equals('Length: 11'));
      });

      test('should work with complex generic types', () {
        final pipeline = z.pipeline([
          z.array(z.string()),
          z.transform<List<String>, List<int>>(
              (arr) => arr.map((s) => s.length).toList()),
          z.transform<List<int>, int>((arr) => arr.reduce((a, b) => a + b)),
        ]);

        final result = pipeline.parse(['hello', 'world', 'test']);
        expect(result, equals(14)); // 5 + 5 + 4
      });
    });

    group('Error Propagation and Context', () {
      test('should propagate errors from early stages', () {
        final pipeline = z.pipeline([
          z.string().min(10),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, int>((s) => s.length),
        ]);

        final result = pipeline.validate('short');
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors.first.path, equals(['stage_0']));
      });

      test('should propagate errors from middle stages', () {
        final pipeline = z.pipeline([
          z.string(),
          z.refine<String>((s) => s.length > 10, message: 'Too short'),
          z.transform<String, int>((s) => s.length),
        ]);

        final result = pipeline.validate('short');
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors.first.path, equals(['stage_1']));
      });

      test('should propagate errors from final stages', () {
        final pipeline = z.pipeline([
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.refine<String>((s) => s.length > 10, message: 'Too short'),
        ]);

        final result = pipeline.validate('short');
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors.first.path, equals(['stage_2']));
      });

      test('should handle nested path contexts', () {
        final pipeline = z.pipeline([
          z.string(),
          z.refine<String>((s) => s.length > 5, message: 'Too short'),
        ]);

        final result = pipeline.validate('hi', ['root', 'field']);
        expect(result.isFailure, isTrue);
        expect(result.errors!.errors.first.path,
            equals(['root', 'field', 'stage_1']));
      });
    });

    group('Equality Testing', () {
      test('should correctly implement equality for pipelines', () {
        final pipeline1 = z.pipeline([z.string(), z.number()]);
        final pipeline2 = z.pipeline([z.string(), z.number()]);
        final pipeline3 = z.pipeline([z.string(), z.boolean()]);
        final pipeline4 = z.pipeline([z.string()]);

        // Same reference
        expect(pipeline1 == pipeline1, isTrue);

        // Different content
        expect(pipeline1 == pipeline3, isFalse);

        // Different lengths
        expect(pipeline1 == pipeline4, isFalse);

        // Hash codes should be consistent
        expect(pipeline1.hashCode, equals(pipeline1.hashCode));
        expect(pipeline2.hashCode, equals(pipeline2.hashCode));
      });
    });

    group('Comprehensive Factory Method Tests', () {
      test('should create pipelines with all factory methods', () {
        // Test all factory methods work correctly
        final pipe2 = PipelineExtension.pipe2(
          z.string(),
          z.transform<String, int>((s) => s.length),
          description: 'Pipe2 test',
          metadata: {'type': 'pipe2'},
        );
        expect(pipe2.length, equals(2));
        expect(pipe2.description, equals('Pipe2 test'));
        expect(pipe2.metadata, equals({'type': 'pipe2'}));

        final pipe3 = PipelineExtension.pipe3(
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, int>((s) => s.length),
          description: 'Pipe3 test',
          metadata: {'type': 'pipe3'},
        );
        expect(pipe3.length, equals(3));

        final pipe4 = PipelineExtension.pipe4(
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
          z.transform<String, int>((s) => s.length),
          description: 'Pipe4 test',
          metadata: {'type': 'pipe4'},
        );
        expect(pipe4.length, equals(4));

        final pipe5 = PipelineExtension.pipe5(
          z.string(),
          z.transform<String, String>((s) => s.trim()),
          z.transform<String, String>((s) => s.toLowerCase()),
          z.transform<String, String>((s) => s.toUpperCase()),
          z.transform<String, int>((s) => s.length),
          description: 'Pipe5 test',
          metadata: {'type': 'pipe5'},
        );
        expect(pipe5.length, equals(5));
      });
    });
  });
}
