import '../../core/schema.dart';
import '../../core/validation_result.dart';

/// Schema for multi-stage validation with chaining support
///
/// A pipeline schema allows you to chain multiple schemas together where
/// the output of one schema becomes the input of the next. This is useful
/// for complex transformations and validations that need to happen in stages.
///
/// Example:
/// ```dart
/// final pipeline = z.pipeline([
///   z.string(),
///   z.transform((s) => s.trim()),
///   z.transform((s) => s.toLowerCase()),
///   z.refine((s) => s.isNotEmpty, message: 'Cannot be empty'),
/// ]);
/// ```
class PipelineSchema<TInput, TOutput> extends Schema<TOutput> {
  final List<Schema<dynamic>> _stages;

  /// Creates a pipeline schema with multiple validation/transformation stages
  ///
  /// [stages] is the list of schemas to apply in sequence
  const PipelineSchema(
    this._stages, {
    super.description,
    super.metadata,
  });

  @override
  ValidationResult<TOutput> validate(dynamic input,
      [List<String> path = const []]) {
    dynamic currentValue = input;
    List<String> currentPath = path;

    for (int i = 0; i < _stages.length; i++) {
      final stage = _stages[i];
      final stagePath = [...currentPath, 'stage_$i'];

      final result = stage.validate(currentValue, stagePath);
      if (result.isFailure) {
        return ValidationResult.failure(result.errors!);
      }

      currentValue = result.data;
    }

    return ValidationResult.success(currentValue as TOutput);
  }

  @override
  Future<ValidationResult<TOutput>> validateAsync(dynamic input,
      [List<String> path = const []]) async {
    dynamic currentValue = input;
    List<String> currentPath = path;

    for (int i = 0; i < _stages.length; i++) {
      final stage = _stages[i];
      final stagePath = [...currentPath, 'stage_$i'];

      final result = await stage.validateAsync(currentValue, stagePath);
      if (result.isFailure) {
        return ValidationResult.failure(result.errors!);
      }

      currentValue = result.data;
    }

    return ValidationResult.success(currentValue as TOutput);
  }

  /// Gets the list of stages in this pipeline
  List<Schema<dynamic>> get stages => List.unmodifiable(_stages);

  /// Gets the number of stages in this pipeline
  int get length => _stages.length;

  /// Checks if the pipeline is empty
  bool get isEmpty => _stages.isEmpty;

  /// Checks if the pipeline is not empty
  bool get isNotEmpty => _stages.isNotEmpty;

  /// Gets the first stage of the pipeline
  Schema<dynamic>? get first => _stages.isEmpty ? null : _stages.first;

  /// Gets the last stage of the pipeline
  Schema<dynamic>? get last => _stages.isEmpty ? null : _stages.last;

  /// Creates a new pipeline with additional stages appended
  PipelineSchema<TInput, TNewOutput> pipe<TNewOutput>(
      List<Schema<dynamic>> additionalStages) {
    return PipelineSchema<TInput, TNewOutput>(
      [..._stages, ...additionalStages],
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a new pipeline with a single stage appended
  PipelineSchema<TInput, TNewOutput> addStage<TNewOutput>(
      Schema<TNewOutput> stage) {
    return pipe<TNewOutput>([stage]);
  }

  /// Creates a new pipeline with stages prepended
  PipelineSchema<TNewInput, TOutput> prepend<TNewInput>(
      List<Schema<dynamic>> prependStages) {
    return PipelineSchema<TNewInput, TOutput>(
      [...prependStages, ..._stages],
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a new pipeline with a single stage prepended
  PipelineSchema<TNewInput, TOutput> prependStage<TNewInput>(
      Schema<TNewInput> stage) {
    return prepend<TNewInput>([stage]);
  }

  /// Creates a new pipeline with stages inserted at a specific index
  PipelineSchema<TInput, TOutput> insertAt(
      int index, List<Schema<dynamic>> stagesToInsert) {
    final newStages = [..._stages];
    newStages.insertAll(index, stagesToInsert);
    return PipelineSchema<TInput, TOutput>(
      newStages,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a new pipeline with a stage inserted at a specific index
  PipelineSchema<TInput, TOutput> insertStageAt(
      int index, Schema<dynamic> stage) {
    return insertAt(index, [stage]);
  }

  /// Creates a new pipeline with a stage removed at a specific index
  PipelineSchema<TInput, TOutput> removeAt(int index) {
    if (index < 0 || index >= _stages.length) {
      throw ArgumentError('Index $index is out of range');
    }
    final newStages = [..._stages];
    newStages.removeAt(index);
    return PipelineSchema<TInput, TOutput>(
      newStages,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a new pipeline with a range of stages removed
  PipelineSchema<TInput, TOutput> removeRange(int start, int end) {
    final newStages = [..._stages];
    newStages.removeRange(start, end);
    return PipelineSchema<TInput, TOutput>(
      newStages,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a new pipeline with only a subset of stages
  PipelineSchema<TInput, TOutput> slice(int start, [int? end]) {
    final actualEnd = end ?? _stages.length;
    final slicedStages = _stages.sublist(start, actualEnd);
    return PipelineSchema<TInput, TOutput>(
      slicedStages,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a new pipeline with stages replaced at a specific range
  PipelineSchema<TInput, TOutput> replaceRange(
      int start, int end, List<Schema<dynamic>> replacementStages) {
    final newStages = [..._stages];
    newStages.replaceRange(start, end, replacementStages);
    return PipelineSchema<TInput, TOutput>(
      newStages,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a new pipeline with a specific stage replaced
  PipelineSchema<TInput, TOutput> replaceStageAt(
      int index, Schema<dynamic> newStage) {
    return replaceRange(index, index + 1, [newStage]);
  }

  /// Creates a new pipeline with stages filtered by a predicate
  PipelineSchema<TInput, TOutput> filterStages(
      bool Function(Schema<dynamic> stage, int index) predicate) {
    final filteredStages = <Schema<dynamic>>[];
    for (int i = 0; i < _stages.length; i++) {
      if (predicate(_stages[i], i)) {
        filteredStages.add(_stages[i]);
      }
    }
    return PipelineSchema<TInput, TOutput>(
      filteredStages,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a new pipeline with stages mapped by a transformer
  PipelineSchema<TInput, TOutput> mapStages(
      Schema<dynamic> Function(Schema<dynamic> stage, int index) mapper) {
    final mappedStages = <Schema<dynamic>>[];
    for (int i = 0; i < _stages.length; i++) {
      mappedStages.add(mapper(_stages[i], i));
    }
    return PipelineSchema<TInput, TOutput>(
      mappedStages,
      description: description,
      metadata: metadata,
    );
  }

  /// Executes a callback for each stage without modifying the pipeline
  void forEachStage(void Function(Schema<dynamic> stage, int index) callback) {
    for (int i = 0; i < _stages.length; i++) {
      callback(_stages[i], i);
    }
  }

  /// Checks if any stage matches a predicate
  bool anyStage(bool Function(Schema<dynamic> stage) predicate) {
    return _stages.any(predicate);
  }

  /// Checks if every stage matches a predicate
  bool everyStage(bool Function(Schema<dynamic> stage) predicate) {
    return _stages.every(predicate);
  }

  /// Finds the first stage that matches a predicate
  Schema<dynamic>? findStage(bool Function(Schema<dynamic> stage) predicate) {
    for (final stage in _stages) {
      if (predicate(stage)) return stage;
    }
    return null;
  }

  /// Finds the index of the first stage that matches a predicate
  int findStageIndex(bool Function(Schema<dynamic> stage) predicate) {
    for (int i = 0; i < _stages.length; i++) {
      if (predicate(_stages[i])) return i;
    }
    return -1;
  }

  /// Creates a new pipeline with stages reversed
  PipelineSchema<TInput, TOutput> reverse() {
    return PipelineSchema<TInput, TOutput>(
      _stages.reversed.toList(),
      description: description,
      metadata: metadata,
    );
  }

  /// Validates input through all stages and collects intermediate results
  ValidationResult<List<dynamic>> validateWithIntermediateResults(dynamic input,
      [List<String> path = const []]) {
    final results = <dynamic>[input];
    dynamic currentValue = input;
    List<String> currentPath = path;

    for (int i = 0; i < _stages.length; i++) {
      final stage = _stages[i];
      final stagePath = [...currentPath, 'stage_$i'];

      final result = stage.validate(currentValue, stagePath);
      if (result.isFailure) {
        return ValidationResult.failure(result.errors!);
      }

      currentValue = result.data;
      results.add(currentValue);
    }

    return ValidationResult.success(results);
  }

  /// Validates input through all stages asynchronously and collects intermediate results
  Future<ValidationResult<List<dynamic>>> validateWithIntermediateResultsAsync(
      dynamic input,
      [List<String> path = const []]) async {
    final results = <dynamic>[input];
    dynamic currentValue = input;
    List<String> currentPath = path;

    for (int i = 0; i < _stages.length; i++) {
      final stage = _stages[i];
      final stagePath = [...currentPath, 'stage_$i'];

      final result = await stage.validateAsync(currentValue, stagePath);
      if (result.isFailure) {
        return ValidationResult.failure(result.errors!);
      }

      currentValue = result.data;
      results.add(currentValue);
    }

    return ValidationResult.success(results);
  }

  /// Gets statistics about the pipeline
  Map<String, dynamic> get statistics => {
        'stageCount': _stages.length,
        'stageTypes': _stages.map((s) => s.runtimeType.toString()).toList(),
        'isEmpty': isEmpty,
        'hasTransformations': anyStage((s) => s is TransformSchema),
        'hasRefinements': anyStage((s) => s is RefineSchema),
        'hasAsyncStages': anyStage(
            (s) => s is AsyncRefineSchema || s is AsyncTransformSchema),
      };

  @override
  String get schemaType => 'PipelineSchema';

  @override
  String toString() {
    final desc = description != null ? ' ($description)' : '';
    return 'PipelineSchema<$TInput -> $TOutput>(${_stages.length} stages)$desc';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PipelineSchema<TInput, TOutput> &&
        other._stages.length == _stages.length &&
        _listEquals(other._stages, _stages);
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        _stages.length,
        _stages.map((s) => s.hashCode).fold<int>(0, (a, b) => a ^ b),
      );

  /// Helper method to compare lists for equality
  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Factory methods for creating pipeline schemas
extension PipelineExtension on Schema {
  /// Creates a pipeline schema from multiple stages
  static PipelineSchema<TInput, TOutput> pipeline<TInput, TOutput>(
    List<Schema<dynamic>> stages, {
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    if (stages.isEmpty) {
      throw ArgumentError('Pipeline must have at least one stage');
    }
    return PipelineSchema<TInput, TOutput>(
      stages,
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a simple pipeline with two stages
  static PipelineSchema<TInput, TOutput> pipe2<TInput, TMiddle, TOutput>(
    Schema<TMiddle> first,
    Schema<TOutput> second, {
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return PipelineSchema<TInput, TOutput>(
      [first, second],
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a pipeline with three stages
  static PipelineSchema<TInput, TOutput> pipe3<TInput, T1, T2, TOutput>(
    Schema<T1> first,
    Schema<T2> second,
    Schema<TOutput> third, {
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return PipelineSchema<TInput, TOutput>(
      [first, second, third],
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a pipeline with four stages
  static PipelineSchema<TInput, TOutput> pipe4<TInput, T1, T2, T3, TOutput>(
    Schema<T1> first,
    Schema<T2> second,
    Schema<T3> third,
    Schema<TOutput> fourth, {
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return PipelineSchema<TInput, TOutput>(
      [first, second, third, fourth],
      description: description,
      metadata: metadata,
    );
  }

  /// Creates a pipeline with five stages
  static PipelineSchema<TInput, TOutput> pipe5<TInput, T1, T2, T3, T4, TOutput>(
    Schema<T1> first,
    Schema<T2> second,
    Schema<T3> third,
    Schema<T4> fourth,
    Schema<TOutput> fifth, {
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return PipelineSchema<TInput, TOutput>(
      [first, second, third, fourth, fifth],
      description: description,
      metadata: metadata,
    );
  }
}
