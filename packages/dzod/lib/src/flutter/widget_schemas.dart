import 'package:flutter/material.dart';

import '../core/error.dart';
import '../core/schema.dart';
import '../core/validation_result.dart';

/// Schema for validating Flutter Color objects
class ColorSchema extends Schema<Color> {
  ColorSchema();

  @override
  ValidationResult<Color> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is Color) {
      return ValidationResult.success(input);
    }

    if (input is String) {
      try {
        // Try to parse hex color
        final hexColor = _parseHexColor(input);
        if (hexColor != null) {
          return ValidationResult.success(hexColor);
        }
      } catch (e) {
        // Continue to other parsing methods
      }

      try {
        // Try to parse named color
        final namedColor = _parseNamedColor(input);
        if (namedColor != null) {
          return ValidationResult.success(namedColor);
        }
      } catch (e) {
        // Continue to error
      }
    }

    if (input is int) {
      try {
        return ValidationResult.success(Color(input));
      } catch (e) {
        return ValidationResult.failure(ValidationErrorCollection([
          ValidationError(
            message: 'Invalid color value: $input',
            path: path,
            received: input,
            expected: 'Color',
          ),
        ]));
      }
    }

    return ValidationResult.failure(ValidationErrorCollection([
      ValidationError(
        message: 'Expected Color, String, or int, got ${input.runtimeType}',
        path: path,
        received: input,
        expected: 'Color',
      ),
    ]));
  }

  /// Validates that the color has a specific alpha value
  ColorSchema alpha(int alpha) {
    return _ColorSchemaWithAlpha(this, alpha);
  }

  /// Validates that the color has a minimum alpha value
  ColorSchema minAlpha(int minAlpha) {
    return _ColorSchemaWithMinAlpha(this, minAlpha);
  }

  /// Validates that the color has a maximum alpha value
  ColorSchema maxAlpha(int maxAlpha) {
    return _ColorSchemaWithMaxAlpha(this, maxAlpha);
  }

  /// Validates that the color is opaque (alpha = 255)
  ColorSchema opaque() {
    return alpha(255);
  }

  /// Validates that the color is transparent (alpha = 0)
  ColorSchema transparent() {
    return alpha(0);
  }

  Color? _parseHexColor(String hex) {
    hex = hex.trim();
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }

    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha if not present
    }

    if (hex.length == 8) {
      final value = int.tryParse(hex, radix: 16);
      if (value != null) {
        return Color(value);
      }
    }

    return null;
  }

  Color? _parseNamedColor(String name) {
    final colorMap = {
      'red': Colors.red,
      'green': Colors.green,
      'blue': Colors.blue,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'cyan': Colors.cyan,
      'teal': Colors.teal,
      'indigo': Colors.indigo,
      'brown': Colors.brown,
      'grey': Colors.grey,
      'gray': Colors.grey,
      'black': Colors.black,
      'white': Colors.white,
      'transparent': Colors.transparent,
    };

    return colorMap[name.toLowerCase()];
  }
}

class _ColorSchemaWithAlpha extends ColorSchema {
  final ColorSchema _base;
  final int _alpha;

  _ColorSchemaWithAlpha(this._base, this._alpha);

  @override
  ValidationResult<Color> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final color = result.data!;
    final alpha = (color.a * 255.0).round() & 0xff;
    if (alpha != _alpha) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Color alpha must be $_alpha, got $alpha',
          path: path,
          received: alpha,
          expected: '$_alpha',
        ),
      ]));
    }

    return ValidationResult.success(color);
  }
}

class _ColorSchemaWithMinAlpha extends ColorSchema {
  final ColorSchema _base;
  final int _minAlpha;

  _ColorSchemaWithMinAlpha(this._base, this._minAlpha);

  @override
  ValidationResult<Color> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final color = result.data!;
    final alpha = (color.a * 255.0).round() & 0xff;
    if (alpha < _minAlpha) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Color alpha must be at least $_minAlpha, got $alpha',
          path: path,
          received: alpha,
          expected: '>= $_minAlpha',
        ),
      ]));
    }

    return ValidationResult.success(color);
  }
}

class _ColorSchemaWithMaxAlpha extends ColorSchema {
  final ColorSchema _base;
  final int _maxAlpha;

  _ColorSchemaWithMaxAlpha(this._base, this._maxAlpha);

  @override
  ValidationResult<Color> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final color = result.data!;
    final alpha = (color.a * 255.0).round() & 0xff;
    if (alpha > _maxAlpha) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Color alpha must be at most $_maxAlpha, got $alpha',
          path: path,
          received: alpha,
          expected: '<= $_maxAlpha',
        ),
      ]));
    }

    return ValidationResult.success(color);
  }
}

/// Schema for validating Flutter EdgeInsets objects
class EdgeInsetsSchema extends Schema<EdgeInsets> {
  EdgeInsetsSchema();

  @override
  ValidationResult<EdgeInsets> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is EdgeInsets) {
      return ValidationResult.success(input);
    }

    if (input is double) {
      return ValidationResult.success(EdgeInsets.all(input));
    }

    if (input is int) {
      return ValidationResult.success(EdgeInsets.all(input.toDouble()));
    }

    if (input is Map<String, dynamic>) {
      try {
        final left = (input['left'] as num?)?.toDouble() ?? 0.0;
        final top = (input['top'] as num?)?.toDouble() ?? 0.0;
        final right = (input['right'] as num?)?.toDouble() ?? 0.0;
        final bottom = (input['bottom'] as num?)?.toDouble() ?? 0.0;

        return ValidationResult.success(
          EdgeInsets.fromLTRB(left, top, right, bottom),
        );
      } catch (e) {
        return ValidationResult.failure(ValidationErrorCollection([
          ValidationError(
            message: 'Invalid EdgeInsets map: $input',
            path: path,
            received: input,
            expected: 'EdgeInsets',
          ),
        ]));
      }
    }

    if (input is List<dynamic>) {
      try {
        if (input.length == 1) {
          final all = (input[0] as num).toDouble();
          return ValidationResult.success(EdgeInsets.all(all));
        } else if (input.length == 2) {
          final horizontal = (input[0] as num).toDouble();
          final vertical = (input[1] as num).toDouble();
          return ValidationResult.success(
            EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
          );
        } else if (input.length == 4) {
          final left = (input[0] as num).toDouble();
          final top = (input[1] as num).toDouble();
          final right = (input[2] as num).toDouble();
          final bottom = (input[3] as num).toDouble();
          return ValidationResult.success(
            EdgeInsets.fromLTRB(left, top, right, bottom),
          );
        }
      } catch (e) {
        return ValidationResult.failure(ValidationErrorCollection([
          ValidationError(
            message: 'Invalid EdgeInsets list: $input',
            path: path,
            received: input,
            expected: 'EdgeInsets',
          ),
        ]));
      }
    }

    return ValidationResult.failure(ValidationErrorCollection([
      ValidationError(
        message:
            'Expected EdgeInsets, double, int, Map, or List, got ${input.runtimeType}',
        path: path,
        received: input,
        expected: 'EdgeInsets',
      ),
    ]));
  }

  /// Validates that all edges have the same value
  EdgeInsetsSchema uniform() {
    return _EdgeInsetsSchemaUniform(this);
  }

  /// Validates that all edges are at least the given value
  EdgeInsetsSchema minAll(double minValue) {
    return _EdgeInsetsSchemaMinAll(this, minValue);
  }

  /// Validates that all edges are at most the given value
  EdgeInsetsSchema maxAll(double maxValue) {
    return _EdgeInsetsSchemaMaxAll(this, maxValue);
  }

  /// Validates that the total horizontal padding is within range
  EdgeInsetsSchema horizontalRange(double min, double max) {
    return _EdgeInsetsSchemaHorizontalRange(this, min, max);
  }

  /// Validates that the total vertical padding is within range
  EdgeInsetsSchema verticalRange(double min, double max) {
    return _EdgeInsetsSchemaVerticalRange(this, min, max);
  }
}

class _EdgeInsetsSchemaUniform extends EdgeInsetsSchema {
  final EdgeInsetsSchema _base;

  _EdgeInsetsSchemaUniform(this._base);

  @override
  ValidationResult<EdgeInsets> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final edges = result.data!;
    if (edges.left != edges.top ||
        edges.left != edges.right ||
        edges.left != edges.bottom) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message:
              'EdgeInsets must be uniform, got left: ${edges.left}, top: ${edges.top}, right: ${edges.right}, bottom: ${edges.bottom}',
          path: path,
          received: edges,
          expected: 'uniform EdgeInsets',
        ),
      ]));
    }

    return ValidationResult.success(edges);
  }
}

class _EdgeInsetsSchemaMinAll extends EdgeInsetsSchema {
  final EdgeInsetsSchema _base;
  final double _minValue;

  _EdgeInsetsSchemaMinAll(this._base, this._minValue);

  @override
  ValidationResult<EdgeInsets> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final edges = result.data!;
    if (edges.left < _minValue ||
        edges.top < _minValue ||
        edges.right < _minValue ||
        edges.bottom < _minValue) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'All EdgeInsets values must be at least $_minValue',
          path: path,
          received: edges,
          expected: '>= $_minValue',
        ),
      ]));
    }

    return ValidationResult.success(edges);
  }
}

class _EdgeInsetsSchemaMaxAll extends EdgeInsetsSchema {
  final EdgeInsetsSchema _base;
  final double _maxValue;

  _EdgeInsetsSchemaMaxAll(this._base, this._maxValue);

  @override
  ValidationResult<EdgeInsets> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final edges = result.data!;
    if (edges.left > _maxValue ||
        edges.top > _maxValue ||
        edges.right > _maxValue ||
        edges.bottom > _maxValue) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'All EdgeInsets values must be at most $_maxValue',
          path: path,
          received: edges,
          expected: '<= $_maxValue',
        ),
      ]));
    }

    return ValidationResult.success(edges);
  }
}

class _EdgeInsetsSchemaHorizontalRange extends EdgeInsetsSchema {
  final EdgeInsetsSchema _base;
  final double _min;
  final double _max;

  _EdgeInsetsSchemaHorizontalRange(this._base, this._min, this._max);

  @override
  ValidationResult<EdgeInsets> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final edges = result.data!;
    final horizontal = edges.left + edges.right;
    if (horizontal < _min || horizontal > _max) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message:
              'Horizontal padding must be between $_min and $_max, got $horizontal',
          path: path,
          received: horizontal,
          expected: 'between $_min and $_max',
        ),
      ]));
    }

    return ValidationResult.success(edges);
  }
}

class _EdgeInsetsSchemaVerticalRange extends EdgeInsetsSchema {
  final EdgeInsetsSchema _base;
  final double _min;
  final double _max;

  _EdgeInsetsSchemaVerticalRange(this._base, this._min, this._max);

  @override
  ValidationResult<EdgeInsets> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final edges = result.data!;
    final vertical = edges.top + edges.bottom;
    if (vertical < _min || vertical > _max) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message:
              'Vertical padding must be between $_min and $_max, got $vertical',
          path: path,
          received: vertical,
          expected: 'between $_min and $_max',
        ),
      ]));
    }

    return ValidationResult.success(edges);
  }
}

/// Schema for validating Flutter Duration objects
class DurationSchema extends Schema<Duration> {
  DurationSchema();

  @override
  ValidationResult<Duration> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is Duration) {
      return ValidationResult.success(input);
    }

    if (input is int) {
      return ValidationResult.success(Duration(milliseconds: input));
    }

    if (input is double) {
      return ValidationResult.success(Duration(milliseconds: input.round()));
    }

    if (input is String) {
      try {
        // Try to parse ISO 8601 duration
        final duration = _parseIsoDuration(input);
        if (duration != null) {
          return ValidationResult.success(duration);
        }
      } catch (e) {
        // Continue to error
      }
    }

    if (input is Map<String, dynamic>) {
      try {
        final days = (input['days'] as int?) ?? 0;
        final hours = (input['hours'] as int?) ?? 0;
        final minutes = (input['minutes'] as int?) ?? 0;
        final seconds = (input['seconds'] as int?) ?? 0;
        final milliseconds = (input['milliseconds'] as int?) ?? 0;
        final microseconds = (input['microseconds'] as int?) ?? 0;

        return ValidationResult.success(Duration(
          days: days,
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
          microseconds: microseconds,
        ));
      } catch (e) {
        return ValidationResult.failure(ValidationErrorCollection([
          ValidationError(
            message: 'Invalid Duration map: $input',
            path: path,
            received: input,
            expected: 'Duration',
          ),
        ]));
      }
    }

    return ValidationResult.failure(ValidationErrorCollection([
      ValidationError(
        message:
            'Expected Duration, int, double, String, or Map, got ${input.runtimeType}',
        path: path,
        received: input,
        expected: 'Duration',
      ),
    ]));
  }

  /// Validates that the duration is at least the given value
  DurationSchema min(Duration minDuration) {
    return _DurationSchemaMin(this, minDuration);
  }

  /// Validates that the duration is at most the given value
  DurationSchema max(Duration maxDuration) {
    return _DurationSchemaMax(this, maxDuration);
  }

  /// Validates that the duration is positive
  DurationSchema positive() {
    return _DurationSchemaPositive(this);
  }

  /// Validates that the duration is negative
  DurationSchema negative() {
    return _DurationSchemaNegative(this);
  }

  /// Validates that the duration is zero
  DurationSchema zero() {
    return _DurationSchemaZero(this);
  }

  Duration? _parseIsoDuration(String iso) {
    // Simple ISO 8601 duration parsing (PT1H30M for 1 hour 30 minutes)
    if (!iso.startsWith('PT')) {
      return null;
    }

    final content = iso.substring(2);
    int hours = 0;
    int minutes = 0;
    int seconds = 0;

    final hoursMatch = RegExp(r'(\d+)H').firstMatch(content);
    if (hoursMatch != null) {
      hours = int.parse(hoursMatch.group(1)!);
    }

    final minutesMatch = RegExp(r'(\d+)M').firstMatch(content);
    if (minutesMatch != null) {
      minutes = int.parse(minutesMatch.group(1)!);
    }

    final secondsMatch = RegExp(r'(\d+)S').firstMatch(content);
    if (secondsMatch != null) {
      seconds = int.parse(secondsMatch.group(1)!);
    }

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
}

class _DurationSchemaMin extends DurationSchema {
  final DurationSchema _base;
  final Duration _minDuration;

  _DurationSchemaMin(this._base, this._minDuration);

  @override
  ValidationResult<Duration> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final duration = result.data!;
    if (duration < _minDuration) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Duration must be at least $_minDuration, got $duration',
          path: path,
          received: duration,
          expected: '>= $_minDuration',
        ),
      ]));
    }

    return ValidationResult.success(duration);
  }
}

class _DurationSchemaMax extends DurationSchema {
  final DurationSchema _base;
  final Duration _maxDuration;

  _DurationSchemaMax(this._base, this._maxDuration);

  @override
  ValidationResult<Duration> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final duration = result.data!;
    if (duration > _maxDuration) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Duration must be at most $_maxDuration, got $duration',
          path: path,
          received: duration,
          expected: '<= $_maxDuration',
        ),
      ]));
    }

    return ValidationResult.success(duration);
  }
}

class _DurationSchemaPositive extends DurationSchema {
  final DurationSchema _base;

  _DurationSchemaPositive(this._base);

  @override
  ValidationResult<Duration> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final duration = result.data!;
    if (duration <= Duration.zero) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Duration must be positive, got $duration',
          path: path,
          received: duration,
          expected: 'positive Duration',
        ),
      ]));
    }

    return ValidationResult.success(duration);
  }
}

class _DurationSchemaNegative extends DurationSchema {
  final DurationSchema _base;

  _DurationSchemaNegative(this._base);

  @override
  ValidationResult<Duration> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final duration = result.data!;
    if (duration >= Duration.zero) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Duration must be negative, got $duration',
          path: path,
          received: duration,
          expected: 'negative Duration',
        ),
      ]));
    }

    return ValidationResult.success(duration);
  }
}

class _DurationSchemaZero extends DurationSchema {
  final DurationSchema _base;

  _DurationSchemaZero(this._base);

  @override
  ValidationResult<Duration> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final duration = result.data!;
    if (duration != Duration.zero) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Duration must be zero, got $duration',
          path: path,
          received: duration,
          expected: 'Duration.zero',
        ),
      ]));
    }

    return ValidationResult.success(duration);
  }
}

/// Schema for validating Flutter Size objects
class SizeSchema extends Schema<Size> {
  SizeSchema();

  @override
  ValidationResult<Size> validate(dynamic input,
      [List<String> path = const []]) {
    if (input is Size) {
      return ValidationResult.success(input);
    }

    if (input is double) {
      return ValidationResult.success(Size.square(input));
    }

    if (input is int) {
      return ValidationResult.success(Size.square(input.toDouble()));
    }

    if (input is List<dynamic> && input.length == 2) {
      try {
        final width = (input[0] as num).toDouble();
        final height = (input[1] as num).toDouble();
        return ValidationResult.success(Size(width, height));
      } catch (e) {
        return ValidationResult.failure(ValidationErrorCollection([
          ValidationError(
            message: 'Invalid Size list: $input',
            path: path,
            received: input,
            expected: 'Size',
          ),
        ]));
      }
    }

    if (input is Map<String, dynamic>) {
      try {
        final width = (input['width'] as num).toDouble();
        final height = (input['height'] as num).toDouble();
        return ValidationResult.success(Size(width, height));
      } catch (e) {
        return ValidationResult.failure(ValidationErrorCollection([
          ValidationError(
            message: 'Invalid Size map: $input',
            path: path,
            received: input,
            expected: 'Size',
          ),
        ]));
      }
    }

    return ValidationResult.failure(ValidationErrorCollection([
      ValidationError(
        message:
            'Expected Size, double, int, List, or Map, got ${input.runtimeType}',
        path: path,
        received: input,
        expected: 'Size',
      ),
    ]));
  }

  /// Validates that the size is a square
  SizeSchema square() {
    return _SizeSchemaSquare(this);
  }

  /// Validates that the width is at least the given value
  SizeSchema minWidth(double minWidth) {
    return _SizeSchemaMinWidth(this, minWidth);
  }

  /// Validates that the height is at least the given value
  SizeSchema minHeight(double minHeight) {
    return _SizeSchemaMinHeight(this, minHeight);
  }

  /// Validates that the width is at most the given value
  SizeSchema maxWidth(double maxWidth) {
    return _SizeSchemaMaxWidth(this, maxWidth);
  }

  /// Validates that the height is at most the given value
  SizeSchema maxHeight(double maxHeight) {
    return _SizeSchemaMaxHeight(this, maxHeight);
  }

  /// Validates that the aspect ratio is within range
  SizeSchema aspectRatio(double minRatio, double maxRatio) {
    return _SizeSchemaAspectRatio(this, minRatio, maxRatio);
  }
}

class _SizeSchemaSquare extends SizeSchema {
  final SizeSchema _base;

  _SizeSchemaSquare(this._base);

  @override
  ValidationResult<Size> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final size = result.data!;
    if (size.width != size.height) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message:
              'Size must be square, got width: ${size.width}, height: ${size.height}',
          path: path,
          received: size,
          expected: 'square Size',
        ),
      ]));
    }

    return ValidationResult.success(size);
  }
}

class _SizeSchemaMinWidth extends SizeSchema {
  final SizeSchema _base;
  final double _minWidth;

  _SizeSchemaMinWidth(this._base, this._minWidth);

  @override
  ValidationResult<Size> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final size = result.data!;
    if (size.width < _minWidth) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Width must be at least $_minWidth, got ${size.width}',
          path: path,
          received: size.width,
          expected: '>= $_minWidth',
        ),
      ]));
    }

    return ValidationResult.success(size);
  }
}

class _SizeSchemaMinHeight extends SizeSchema {
  final SizeSchema _base;
  final double _minHeight;

  _SizeSchemaMinHeight(this._base, this._minHeight);

  @override
  ValidationResult<Size> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final size = result.data!;
    if (size.height < _minHeight) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Height must be at least $_minHeight, got ${size.height}',
          path: path,
          received: size.height,
          expected: '>= $_minHeight',
        ),
      ]));
    }

    return ValidationResult.success(size);
  }
}

class _SizeSchemaMaxWidth extends SizeSchema {
  final SizeSchema _base;
  final double _maxWidth;

  _SizeSchemaMaxWidth(this._base, this._maxWidth);

  @override
  ValidationResult<Size> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final size = result.data!;
    if (size.width > _maxWidth) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Width must be at most $_maxWidth, got ${size.width}',
          path: path,
          received: size.width,
          expected: '<= $_maxWidth',
        ),
      ]));
    }

    return ValidationResult.success(size);
  }
}

class _SizeSchemaMaxHeight extends SizeSchema {
  final SizeSchema _base;
  final double _maxHeight;

  _SizeSchemaMaxHeight(this._base, this._maxHeight);

  @override
  ValidationResult<Size> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final size = result.data!;
    if (size.height > _maxHeight) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message: 'Height must be at most $_maxHeight, got ${size.height}',
          path: path,
          received: size.height,
          expected: '<= $_maxHeight',
        ),
      ]));
    }

    return ValidationResult.success(size);
  }
}

class _SizeSchemaAspectRatio extends SizeSchema {
  final SizeSchema _base;
  final double _minRatio;
  final double _maxRatio;

  _SizeSchemaAspectRatio(this._base, this._minRatio, this._maxRatio);

  @override
  ValidationResult<Size> validate(dynamic value,
      [List<String> path = const []]) {
    final result = _base.validate(value, path);
    if (!result.isSuccess) {
      return result;
    }

    final size = result.data!;
    final ratio = size.width / size.height;

    if (ratio < _minRatio || ratio > _maxRatio) {
      return ValidationResult.failure(ValidationErrorCollection([
        ValidationError(
          message:
              'Aspect ratio must be between $_minRatio and $_maxRatio, got $ratio',
          path: path,
          received: ratio,
          expected: 'between $_minRatio and $_maxRatio',
        ),
      ]));
    }

    return ValidationResult.success(size);
  }
}
